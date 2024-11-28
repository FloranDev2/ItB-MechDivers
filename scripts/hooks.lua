----------------------------------------------- IMPORTS -----------------------------------------------
local mod = modApi:getCurrentMod() --same, but better (thx Lemonymous!)
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

local function isMissionBoard()
    return true
        and isMission()
        and Board ~= nil
        and Board:IsTipImage() == false
end

local function isGameData()
    return true
        and GAME ~= nil
        and GAME.truelch_MechDivers ~= nil
end

local function gameData()
    if GAME.truelch_MechDivers == nil then
        GAME.truelch_MechDivers = {}
    end

    return GAME.truelch_MechDivers
end

local function missionData()
    local mission = GetCurrentMission()

    if mission.truelch_MechDivers == nil then
        mission.truelch_MechDivers = {}
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

--[[
Unpowered? And with upgrade, can be used right away
Ok so idk if I should move that to:
- a passive (-> that sounds better, plus I can upgrade)
- a trait for the other 2 mechs
]]
local HOOK_onPawnKilled = function(mission, pawn)
    if isMission() and pawn:IsMech() and IsPassiveSkill("truelch_Reinforcements_Passive") then
        Board:RemovePawn(pawn)
        local randPoint = GetRandomPoint()
        --local pawnType = _G[self:GetType()]
        local newMech = PAWN_FACTORY:CreatePawn("TankMech")
        newMech:SetMech() --IT WORKS NOW, YEEEHAAA
        Board:SpawnPawn(newMech, randPoint)

    end
end

----------------------------------------------- HOOKS / EVENTS SUBSCRIPTION -----------------------------------------------

local function EVENT_onModsLoaded()
    modapiext:addPawnKilledHook(HOOK_onPawnKilled)
end

modApi.events.onModsLoaded:subscribe(EVENT_onModsLoaded)