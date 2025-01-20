----------------------------------------------- IMPORTS -----------------------------------------------

local mod = modApi:getCurrentMod()
local scriptPath = mod.scriptPath

local truelch_divers_fmwApi = require(scriptPath.."fmw/api") --that's what I needed!
--LOG("hooks - truelch_divers_fmwApi: "..tostring(truelch_divers_fmwApi))


----------------------------------------------- MISSION / GAME FUNCTIONS -----------------------------------------------

local function isGame()
    return true
        and Game ~= nil
        and GAME ~= nil
end

local function isMission()
    local mission = GetCurrentMission()

    return true
        and isGame()
        and mission ~= nil
        and mission ~= Mission_Test
end

local function missionData()
    local mission = GetCurrentMission()

    if mission.truelch_MechDivers == nil then
        mission.truelch_MechDivers = {}
    end

    if mission.truelch_MechDivers.deadMechs == nil then
        mission.truelch_MechDivers.deadMechs = {}
    end

    if mission.truelch_MechDivers.isRespawnUsed == nil then
        mission.truelch_MechDivers.isRespawnUsed = false
    end

    --This needs to be put in game data because transitioning from final mission first to second phase will erase mission data (!)
    --[[
    if mission.truelch_MechDivers.secPartCheck == nil then
        mission.truelch_MechDivers.secPartCheck = false
        --LOG("[A] mission.truelch_MechDivers.secPartCheck == nil -> secPartCheck = false")
    end
    ]]

    return mission.truelch_MechDivers
end

local function gameData()
    if GAME.truelch_MechDivers == nil then
        GAME.truelch_MechDivers = {}
    end

    if GAME.truelch_MechDivers.secPartCheck == nil then
        GAME.truelch_MechDivers.secPartCheck = false
    end

    return GAME.truelch_MechDivers
end

----------------------------------------------- MISC -----------------------------------------------

local function GetRandomPoint()
    local points = {}

    for j = 0, 7 do
        for i = 0, 7 do
            local curr = Point(i, j)
            if not Board:IsBlocked(curr, PATH_PROJECTILE)
                and not Board:IsPod(curr)
                and not Board:IsTerrain(curr, TERRAIN_HOLE)
                and not Board:IsTerrain(curr, TERRAIN_WATER) --works with lava? and acid water?
                and not Board:IsTerrain(curr, TERRAIN_LAVA) then
                    points[#points + 1] = curr
            end
        end
    end

    if #points > 0 then
        return points[math.random(1, #points)]
    else
        LOG("Couldn't find a fitting point!")
        return nil
    end
end

local function isStratagemWeapon(weapon)
    if type(weapon) == 'table' then
        weapon = weapon.__Id
    end
    return string.find(weapon, "truelch_Stratagem") ~= nil
end

local function computeRespawn(pawn)
    --LOG("computeRespawn()...")

    if pawn == nil then
        --LOG("... pawn is nil!")
        return
    end

    truelch_divers_fmwApi:ForceFMWInit(pawn:GetId())
end

----------------------------------------------- HOOKS -----------------------------------------------

local function HOOK_onNextTurnHook()
    --LOG("HOOK_onNextTurnHook() -> secPartCheck: "..tostring(gameData().secPartCheck))

    if gameData().secPartCheck then
        --LOG("HOOK_onNextTurnHook - missionData().secPartCheck")
        for _, id in ipairs(extract_table(Board:GetPawns(TEAM_PLAYER))) do
            local pawn = Board:GetPawn(id)
            if pawn ~= nil and pawn:IsMech() then
                --LOG(string.format("mech: %s, at: %s, id: %s", pawn:GetType(), pawn:GetSpace():GetString(), tostring(pawn:GetId())))
                if pawn:GetSpace() == Point(-1, -1) then
                    --Get one of the second phase deploy points. If it's not available, get a random pos

                    local newPos = nil
                    local secDepPoints = { Point(2, 3), Point(2, 4), Point(3, 3), Point(3, 4) }
                    for _, curr in ipairs(secDepPoints) do
                        if not Board:IsBlocked(curr, PATH_PROJECTILE) then
                            newPos = curr
                        end
                    end

                    if newPos == nil then
                        newPos = GetRandomPoint() --safety, but should NEVER happen
                    end

                    --LOG(" -> relocated to: "..newPos:GetString())
                    pawn:SetSpace(newPos)
                end
            end
        end
        gameData().secPartCheck = false
        --LOG("[B] HOOK_onNextTurnHook() and secPartCheck was true -> secPartCheck = false")
        return
    end

    if Game:GetTeamTurn() == TEAM_PLAYER and IsPassiveSkill("truelch_Reinforcements_Passive") then
        --local board_size = Board:GetSize()
        --LOG("New turn, let's take a look at pawns:")
        --for j = 0, board_size.y - 1 do
        --    for i = 0, board_size.x - 1 do

        --For pawns that dies in a "standard way"
        for j = 0, 7 do
            for i = 0, 7 do
                local pawn = Board:GetPawn(Point(i, j))
                if pawn ~= nil then
                    --LOG(string.format(" -> Pawn: %s", pawn:GetMechName()))
                    if pawn:IsMech() and pawn:IsDead() then
                        if not missionData().isRespawnUsed then
                            local pawnType = pawn:GetType()
                            --LOG(string.format(" ---> Found a dead pawn: %s", pawn:GetMechName()))

                            --Remove old
                            Board:RemovePawn(pawn) --doesn't work if the unit died in a chasm

                            --Create new
                            local randPoint = GetRandomPoint()
                            local newMech = PAWN_FACTORY:CreatePawn(pawnType)
                            newMech:SetMech()
                            Board:SpawnPawn(newMech, randPoint)

                            computeRespawn(newMech)

                            --New: respawn limited to 1 per mission
                            missionData().isRespawnUsed = true
                        else
                            --TODO: some feedback here?
                        end
                    end
                end
            end
        end

        --For pawns that dies in a chasm
        for _, pawn in pairs(missionData().deadMechs) do
            local randPoint = GetRandomPoint()
            pawn:SetSpace(randPoint) --this doesn't do a cool drop anim though
            computeRespawn(pawn)
            --drop anim: take a look at candy island's candy goos
            --or lemon's geysers
        end
    end
end


--[[
Unpowered? And with upgrade, can be used right away
Ok so idk if I should move that to:
- a passive (-> that sounds better, plus I can upgrade)
- a trait for the other 2 mechs
--local pawnType = _G[pawn:GetType()] --this?
After 3 deaths or so, the Mechs no longer respawn.
]]
local HOOK_onPawnKilled = function(mission, pawn)
    if isMission() and pawn:IsMech() then
        if IsPassiveSkill("truelch_Reinforcements_Passive_A") then
            Board:RemovePawn(pawn)
            local randPoint = GetRandomPoint()
            local pawnType = pawn:GetType() --or this? Edit: at least this works
            local newMech = PAWN_FACTORY:CreatePawn(pawnType) --this works! And also have the correct palette (idk how, but that's great)
            newMech:SetMech()
            Board:SpawnPawn(newMech, randPoint)

            computeRespawn(newMech)

        elseif IsPassiveSkill("truelch_Reinforcements_Passive") then
            --LOG("HOOK_onPawnKilled -> truelch_Reinforcements_Passive")
            --Check terrain if chasm because in that case my current logic doesn't work
            local terrain = Board:GetTerrain(pawn:GetSpace()) --terrain: 9 -> chasm
            --LOG("terrain: "..tostring(terrain))
            if terrain == 9 then --Chasm, I should have used TERRAIN_HOLE I guess
                local randPoint = GetRandomPoint()
                local pawnType = pawn:GetType()
                local newMech = PAWN_FACTORY:CreatePawn(pawnType)
                newMech:SetMech()
                Board:SpawnPawn(newMech, randPoint)
                local spawned = Board:GetPawn(randPoint)

                computeRespawn(spawned)

                table.insert(missionData().deadMechs, spawned)
                spawned:SetSpace(Point(-1, -1))

                Board:RemovePawn(pawn) --if this happens last turn, it might cause a problem?
            end
        end
    end
end

local HOOK_onMissionNextPhaseCreated = function(prevMission, nextMission)
    --LOG("HOOK_onMissionNextPhaseCreated - Left mission "..prevMission.ID..", going into "..nextMission.ID.." -> secPartCheck = true")
    --No unit yet at this moment
    gameData().secPartCheck = true
end



----------------------------------------------- HOOKS / EVENTS SUBSCRIPTION -----------------------------------------------

local function EVENT_onModsLoaded()
    modApi:addNextTurnHook(HOOK_onNextTurnHook)
    modapiext:addPawnKilledHook(HOOK_onPawnKilled)
    modApi:addMissionNextPhaseCreatedHook(HOOK_onMissionNextPhaseCreated)

end

modApi.events.onModsLoaded:subscribe(EVENT_onModsLoaded)