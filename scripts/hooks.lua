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

local function Test1()
    
end

local function Test2()

end

local HOOK_onPawnKilled = function(mission, pawn)
    if isMission() and pawn:IsMech() then

        --Disappear effect

        --Appear effect

        --TMP stuff
        --pawn:SetHealth()


        Board:AddEffect(SpaceDamage(pawn:GetSpace(), -10))
        --Unpowered? And with upgrade, can be used right away

        local randPoint = GetRandomPoint()
        if randPoint ~= nil then
            pawn:SetSpace(randPoint)
        end

        --Test 2
        randPoint = GetRandomPoint()
        local Tank = PAWN_FACTORY:CreatePawn("TankMech")
        Tank:SetMech()
        Board:SpawnPawn(Tank, randPoint)
                
    end
end

----------------------------------------------- HOOKS / EVENTS SUBSCRIPTION -----------------------------------------------

local function EVENT_onModsLoaded()
    modapiext:addPawnKilledHook(HOOK_onPawnKilled)
end

modApi.events.onModsLoaded:subscribe(EVENT_onModsLoaded)