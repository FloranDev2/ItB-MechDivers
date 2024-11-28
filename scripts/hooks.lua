----------------------------------------------- IMPORTS -----------------------------------------------

local mod = modApi:getCurrentMod() --same, but better (thx Lemonymous!)
local scriptPath = mod.scriptPath


----------------------------------------------- MISSION / GAME FUNCTIONS -----------------------------------------------

local function missionData()
    local mission = GetCurrentMission()

    if mission.truelch_MechDivers == nil then
        mission.truelch_MechDivers = {}
    end

    if mission.truelch_MechDivers.DeadMechs == nil then
        mission.truelch_MechDivers.DeadMechs = {}
    end

    return mission.truelch_MechDivers
end


----------------------------------------------- MISC -----------------------------------------------

local function GetRandomPoint()
    local points = {}

    for j = 0, 7 do
        for i = 0, 7 do
            local curr = Point(i, j)
            if not Board:IsBlocked(curr, PATH_PROJECTILE) then
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
    --pawn:Retreat()
    --pawn:Kill()
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
    --Env test (doesn' work yet)
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
        --V1
        --[[
        LOG("Revive loop:")
        for _, pawnType in pairs(missionData().DeadMechs) do
            local randPoint = GetRandomPoint()
            LOG("pawnType type: "..type(pawnType))
            LOG("pawnType: "..pawnType)
            local newMech = PAWN_FACTORY:CreatePawn(pawnType)
            newMech:SetMech() --this doesn't seem to work here
            Board:SpawnPawn(pawnType, randPoint)
        end

        --Clear dead mech list (simplest way)
        missionData().DeadMechs = {}
        ]]

        --V2
        --There must be a simpler way to look for Mechs
        for j = 0, 7 do
            for i = 0, 7 do
                local pawn = Board:GetPawn()
                --if pawn ~= nil and pawn:IsMech() and pawn:IsInvisible() then
                if pawn ~= nil and pawn:IsMech() and pawn:GetSpace() == Point(-1, -1) then
                    LOG(" ----------------- here")
                    local randPoint = GetRandomPoint()
                    pawn:SetSpace(randPoint)
                end
            end
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
        if IsPassiveSkill("truelch_Reinforcements_Passive_A") or IsPassiveSkill("truelch_Reinforcements_Passive") then
            Board:RemovePawn(pawn)
            local randPoint = GetRandomPoint()
            local pawnType = pawn:GetType() --or this? Edit: at least this works
            local newMech = PAWN_FACTORY:CreatePawn(pawnType) --this works! And also have the correct palette (idk how, but that's great)
            newMech:SetMech()
            Board:SpawnPawn(newMech, randPoint)
        elseif IsPassiveSkill("truelch_Reinforcements_Passive") then            
            Board:RemovePawn(pawn)
            --V1: Wait for next player turn
            --Edit: the pawn spawned next turn failed to become a Mech
            --table.insert(missionData().DeadMechs, pawn:GetType())

            --V2: Create it now, but hide it until next turn (or move it to (-1, -1))
            local pawnType = pawn:GetType()
            local newMech = PAWN_FACTORY:CreatePawn(pawnType)
            newMech:SetMech()
            local id = Board:SpawnPawn(newMech, randPoint) --is the int returned the id of the spawned pawn?

            LOG(" ----------- id: "..tostring(id))

            local spawned = Board:GetPawn(id)
            --spawned:SetInvisible(true)
            spawned:SetSpace(-1, -1)
        end
    end
end

----------------------------------------------- HOOKS / EVENTS SUBSCRIPTION -----------------------------------------------

local function EVENT_onModsLoaded()
    modApi:addNextTurnHook(HOOK_onNextTurnHook)
    modapiext:addPawnKilledHook(HOOK_onPawnKilled)
end

modApi.events.onModsLoaded:subscribe(EVENT_onModsLoaded)