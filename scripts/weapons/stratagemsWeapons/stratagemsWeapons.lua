----------------------------------------------- MISSION / GAME FUNCTIONS -----------------------------------------------

local function isGame()
    return true
        and Game ~= nil
        and GAME ~= nil
end

local function gameData()
    if GAME.truelch_MechDivers == nil then
        GAME.truelch_MechDivers = {}
    end

    --Acquired stratagems
    if GAME.truelch_MechDivers.Stratagems == nil then
        GAME.truelch_MechDivers.Stratagems = {}
    end

    return GAME.truelch_MechDivers
end

local function isMission()
    local mission = GetCurrentMission()

    return true
        and isGame()
        and mission ~= nil
        and mission ~= Mission_Test
end

--[[
local function missionData()
    local mission = GetCurrentMission()

    if mission.truelch_MechDivers == nil then
        mission.truelch_MechDivers = {}
    end

    --Acquired stratagems
    if mission.truelch_MechDivers.Stratagems == nil then
        mission.truelch_MechDivers.Stratagems = {}
    end

    return mission.truelch_MechDivers
end
]]


----------------------------------------------- UTILITY FUNCTIONS -----------------------------------------------

local stratagemWeapons = {
    "truelch_mg43MachineGun",
}

local function isStratagemWeapon(weaponId)
    if type(weaponId) == 'table' then
        weaponId = weaponId.__Id
    end

    for _, stratagemWeapon in pairs(stratagemWeapons) do
        if weaponId == stratagemWeapon then
            return true
        end
    end

    return false
end


----------------------------------------------- SUPPORT WEAPONS -----------------------------------------------

--Description = "A machine gun designed for stationary use. Trades higher power for increased recoil and reduced accuracy.",
--Class = "Any", --Actually need to not specify a class so that I can AddWeapon

--Can we have upgraded drop weapons?
truelch_mg43MachineGun = TankDefault:new {
	--Infos
	Name = "MG-43 Machine Gun",
	Description = "Shoot a pushing projectile. Shoot again at the start of next turn if the Mech moved 1 tile or less.", --or didn't use ALL its move?
	PowerCost = 0, --Can I also remove this?

	--Art
	Icon = "weapons/brute_tankmech.png",
	Sound = "/general/combat/explode_small",
	LaunchSound = "/weapons/modified_cannons",
	ImpactSound = "/impact/generic/explosion",

	--Gameplay
	Damage = 1,
	ZoneTargeting = ZONE_DIR,
	Explosion = "",
	Push = 1,

	TipImage = StandardTips.Ranged,
}


truelch_testQueueWeapon = Skill:new {
    --Infos
    Name = "MG-43 Machine Gun",
    Description = "Shoot a pushing projectile. Shoot again at the start of next turn if the Mech moved 1 tile or less.", --or didn't use ALL its move?
    PowerCost = 0, --Can I also remove this?
    --Art
    Icon = "weapons/brute_tankmech.png",

    --TipImage = StandardTips.Ranged,
}


----------------------------------------------- SUPPORT WEAPONS -----------------------------------------------



----------------------------------------------- HOOKS -----------------------------------------------


local function HOOK_onNextTurnHook()
    --if Game:GetTeamTurn() == TEAM_PLAYER then
	if Game:GetTeamTurn() == TEAM_ENEMY then --might be even more funny
        --Going through all mechs like this instead of 0 -> 1 because freshly spawned Mech don't have 0 - 2 ids
        for j = 0, 7 do
        	for i = 0, 7 do
        		local pawn = Board:GetPawn(Point(i, j))
        		if pawn ~= nil then
        		end
        	end
        end
    end
end

local HOOK_onSkillEnd = function(mission, pawn, weaponId, p1, p2)
	--if not isMission() then return end
	

	--if 
end

local HOOK_onMissionEnded = function(mission)
    LOG("Mission end!")
    --Destroy all stratagem weapons

    --Look through all Mechs. Remember, respawned Mechs aren't in 0 - 2 index range
    
end

----------------------------------------------- HOOKS / EVENTS SUBSCRIPTION -----------------------------------------------

local function EVENT_onModsLoaded()
    modApi:addNextTurnHook(HOOK_onNextTurnHook)
    modapiext:addSkillEndHook(HOOK_onSkillEnd)
    modApi:addMissionEndHook(HOOK_onMissionEnded)
end

modApi.events.onModsLoaded:subscribe(EVENT_onModsLoaded)