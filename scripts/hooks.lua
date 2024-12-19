----------------------------------------------- IMPORTS -----------------------------------------------

local mod = modApi:getCurrentMod()
local scriptPath = mod.scriptPath


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

    return mission.truelch_MechDivers
end


----------------------------------------------- MISC -----------------------------------------------

local function GetRandomPoint()
    local points = {}

    for j = 0, 7 do
        for i = 0, 7 do
            local curr = Point(i, j)
            if not Board:IsBlocked(curr, PATH_PROJECTILE) and not Board:IsPod(curr) then
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

----------------------------------------------- HOOKS -----------------------------------------------

local function TestDisappearAppear(pawn)
    --Disappear effect

    --Appear effect

    --TMP stuff
    --pawn:SetHealth()
end

local function TestKillAndRetreat(pawn)
    pawn:Retreat()
    pawn:Kill()
end

local function TestInvisible(pawn)
    --Board:AddAlert(pawn:GetSpace(), "DEMOCRACY")
    pawn:SetInvisible(true)
end

--The spawned unit cannot be a Mech. It'd crash the game
local function TestSpawnPawn(pawn)
    randPoint = GetRandomPoint()
    local Tank = PAWN_FACTORY:CreatePawn("TankMech")
    --Tank:SetMech() --crashes the game!
    Board:SpawnPawn(Tank, randPoint)
end

local function TestBackUpStuff(pawn)
    Board:AddEffect(SpaceDamage(pawn:GetSpace(), -10))
    local randPoint = GetRandomPoint()
    if randPoint ~= nil then
        pawn:SetSpace(randPoint)
    end
end

local function TestEnv(pawn)
    --Env test (doesn't work yet)
    local randPoint = GetRandomPoint()
    Board:AddAlert(randPoint, "Env here")
    ---Board:MarkSpaceImage(randPoint, "combat/tile_icon/tile_truelch_drop.png", GL_Color(255, 226, 88, 0.75))
    Board:MarkSpaceImage(randPoint, "combat/tile_icon/tile_airstrike.png", GL_Color(255, 226, 88, 0.75))
    Board:MarkSpaceDesc(randPoint, "air_strike", EFFECT_DEADLY)

end

--[[
Multiple issues though:
- it won't display health when hovered with the mouse
- its sprite will be displayed behind some terrain elements while it should be in front
-> These two issues are fixed when backing out
- The Mech no longer die to chasms until reload
]]
local function TestFishFromChasm(pawn)
    --Fishing mechs from chasms (https://discord.com/channels/417639520507527189/418142041189646336/1311122351651557478)
    local randPoint = GetRandomPoint()
    pawn:SetHealth(1)
    Board:RemovePawn(pawn)
    Board:AddPawn(pawn, randPoint)
end

local function HOOK_onNextTurnHook()
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
                    LOG(string.format(" -> Pawn: %s", pawn:GetMechName()))
                    if --[[pawn ~= nil and]] pawn:IsMech() and pawn:IsDead() then
                        local pawnType = pawn:GetType()
                        LOG(string.format(" ---> Found a dead pawn: %s", pawn:GetMechName()))

                        --Remove old
                        Board:RemovePawn(pawn) --doesn't work if the unit died in a chasm

                        --Create new
                        local randPoint = GetRandomPoint()
                        local newMech = PAWN_FACTORY:CreatePawn(pawnType)
                        newMech:SetMech()
                        Board:SpawnPawn(newMech, randPoint)
                    end
                end
            end
        end

        --For pawns that dies in a chasm
        for _, pawn in pairs(missionData().deadMechs) do
            --LOG("------------ here")
            --[[
            --Play anim
            local dropAnim = SpaceDamage(loc, 0)
            dropAnim.sAnimation = "truelch_anim_pod_land"
            effect:AddDamage(dropAnim)
            ]]

            local randPoint = GetRandomPoint()
            pawn:SetSpace(randPoint) --this doesn't do a cool drop anim though
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
    --LOG("------------ HOOK_onPawnKilled")
    if isMission() and pawn:IsMech() then
        if IsPassiveSkill("truelch_Reinforcements_Passive_A") --[[or IsPassiveSkill("truelch_Reinforcements_Passive")]] then
            --LOG("------------ upgraded")

            --TODO: play EXPLO anim
            local anim = SpaceDamage(pawn:GetSpace(), 0)
            anim.sAnimation = "img/effects/timetravel.png"
            Board:AddEffect(anim)

            Board:RemovePawn(pawn)
            local randPoint = GetRandomPoint()
            local pawnType = pawn:GetType() --or this? Edit: at least this works
            local newMech = PAWN_FACTORY:CreatePawn(pawnType) --this works! And also have the correct palette (idk how, but that's great)
            newMech:SetMech()
            Board:SpawnPawn(newMech, randPoint)
        elseif IsPassiveSkill("truelch_Reinforcements_Passive") then
            --Check terrain if chasm because in that case my current logic doesn't work
            --if Board:G
            local terrain = Board:GetTerrain(pawn:GetSpace()) --terrain: 9 -> chasm
            --LOG("terrain: "..tostring(terrain))
            if terrain == 9 then
                local randPoint = GetRandomPoint()
                local pawnType = pawn:GetType()
                local newMech = PAWN_FACTORY:CreatePawn(pawnType)
                newMech:SetMech()
                Board:SpawnPawn(newMech, randPoint)
                local spawned = Board:GetPawn(randPoint)
                table.insert(missionData().deadMechs, spawned)
                spawned:SetSpace(Point(-1, -1))

                Board:RemovePawn(pawn)
            end
        end
    end
end


----------------------------------------------- HOOKS / EVENTS SUBSCRIPTION -----------------------------------------------

local function EVENT_onModsLoaded()
    modApi:addNextTurnHook(HOOK_onNextTurnHook)
    modapiext:addPawnKilledHook(HOOK_onPawnKilled)
end

modApi.events.onModsLoaded:subscribe(EVENT_onModsLoaded)