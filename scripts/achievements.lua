local mod = modApi:getCurrentMod()
local squad = "truelch_MechDivers"

-- --- CONSTANT VARIABLES --- --
--local DEAD_MECHS_GOAL = 6
local ROBOTS_KILL_GOAL = 10

-- -- ADD ACHIEVEMENTS --- --
local achievements = {
	truelch_DropKill = modApi.achievements:add{
		id = "truelch_DropKill",
		name = "I'm doing my part!",
		tooltip = "Kill an enemy with a drop pod.",
		image = mod.resourcePath.."img/achievements/truelch_DropKill.png",
		squad = squad,
	},
	truelch_RespawnAbuse = modApi.achievements:add{
		id = "truelch_RespawnAbuse",
		name = "Extraordinary Patriotism",
		--tooltip = "Have "..tostring(DEAD_MECHS_GOAL).." Mechs die in a mission.",
		tooltip = "Have a new Mech spawn for each mission of your run.",
		image = mod.resourcePath.."img/achievements/truelch_RespawnAbuse.png",
		squad = squad,
	},
	truelch_KillRobots = modApi.achievements:add{
		id = "truelch_KillRobots",
		name = "Remember Malevelon Creek",
		tooltip = "Kill "..tostring(ROBOTS_KILL_GOAL).." Robots in a game. (ally robots also count)",
		image = mod.resourcePath.."img/achievements/truelch_KillRobots.png",
		squad = squad,
	}
}

--- HELPER FUNCTIONS ---
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

local function isSquad()
	return true
		and isGame()
		and GAME.additionalSquadData.squad == squad
end

--- COMPLETE ACHIEVEMENT ---
function truelch_completeDropKill(isDebug)
	if isDebug then
		LOG("truelch_completeDropKill()")
		Board:AddAlert(Point(4, 4), "Drop Kill completed!")
	else
		if not achievements.truelch_DropKill:isComplete() then
			achievements.truelch_DropKill:addProgress{ complete = true }
		end
	end
end

function truelch_completeRespawnAbuse(isDebug)
	if isDebug then
		LOG("truelch_completeRespawnAbuse()")
		Board:AddAlert(Point(4, 4), "Respawn Abuse completed!")
	else
		if not achievements.truelch_RespawnAbuse:isComplete() then
			achievements.truelch_RespawnAbuse:addProgress{ complete = true }
		end
	end
end

function truelch_completeKillRobots(isDebug)
	if isDebug then
		LOG("truelch_completeKillRobots()")
		Board:AddAlert(Point(4, 4), "Kill Robots completed!")
	else
		if not achievements.truelch_KillRobots:isComplete() then
			achievements.truelch_KillRobots:addProgress{ complete = true }
		end
	end
end


--- DATA ---
local function missionData()
    local mission = GetCurrentMission()

    if mission.truelch_MechDivers == nil then
        mission.truelch_MechDivers = {}
    end

    if mission.truelch_MechDivers.isRespawnUsed == nil then
        mission.truelch_MechDivers.isRespawnUsed = false
    end

    return mission.truelch_MechDivers
end

local function gameData()
	if GAME.truelch_MechDivers == nil then
		GAME.truelch_MechDivers = {}
	end

	if GAME.truelch_MechDivers.achievementData == nil then
		GAME.truelch_MechDivers.achievementData = {}
	end

	return GAME.truelch_MechDivers.achievementData
end

local function achievementData()
	--using mission will cause an error on island menu while looking in achievements tooltips
	local game = gameData()

	if game.truelch_MechDivers == nil then
		game.truelch_MechDivers = {}
	end

	if game.truelch_MechDivers.achievementData == nil then
		game.truelch_MechDivers.achievementData = {}
	end

	--Initializing other data here
	--[[
	if game.truelch_MechDivers.achievementData.mechsKilled == nil then
		game.truelch_MechDivers.achievementData.mechsKilled = 0
	end
	]]

	if game.truelch_MechDivers.achievementData.botsKilled == nil then
		game.truelch_MechDivers.achievementData.botsKilled = 0
	end

	if game.truelch_MechDivers.achievementData.isRespawnAchvStillOk == nil then
		game.truelch_MechDivers.achievementData.isRespawnAchvStillOk = true
	end

	--Return
	return game.truelch_MechDivers.achievementData
end

--- MISC FUNCTIONS ---
--Units that are bot but don't have DefaultFaction == FACTION_BOTS:
moreBots = { "tosx_mission_IceHulk" }
function isBot(pawn)
	if pawn == nil then
		return false
	end

	if _G[pawn:GetType()].DefaultFaction == FACTION_BOTS then
		return true
	end

	for _, bot in ipairs(moreBots) do
		if pawn:GetType() == bot then
			LOG(pawn:GetType().." is counted as a bot!")
			return true
		end
	end

	return false
end

--- TOOLTIP ---
local getTooltip = achievements.truelch_RespawnAbuse.getTooltip
achievements.truelch_RespawnAbuse.getTooltip = function(self)
	local result = getTooltip(self)

	local status = ""

	--No need to check if we're in a mission
	--[[
	if isMission() and not achievements.truelch_RespawnAbuse:isComplete() then
		status = "\nMartyrs: "..tostring(achievementData().mechsKilled.." / "..tostring(DEAD_MECHS_GOAL))
	end
	]]

	--Can also be helpful to know if the passive if up even though you're not looking for the achievement.
	if isMission() --[[and not achievements.truelch_RespawnAbuse:isComplete()]] then
		status = status.."\nHas Mech respawned this mission? "..tostring(missionData().isRespawnUsed)
		status = status.."\nIs this achievement still doable? "..tostring(achievementData().isRespawnAchvStillOk)
	end

	result = result..status

	return result
end

local getTooltip = achievements.truelch_KillRobots.getTooltip
achievements.truelch_KillRobots.getTooltip = function(self)
	local result = getTooltip(self)

	local status = ""

	if isGame() and not achievements.truelch_KillRobots:isComplete() then
		status = "\nBots democratized: "..tostring(achievementData().botsKilled.." / "..tostring(ROBOTS_KILL_GOAL))
	end

	result = result..status

	return result
end

--- HOOKS ---
local HOOK_onPawnKilled = function(mission, pawn)
	if not isSquad() or not isMission() then return end

	if isBot(pawn) then
		achievementData().botsKilled = achievementData().botsKilled + 1

		--Reached goal?
		if achievementData().botsKilled >= ROBOTS_KILL_GOAL then
			truelch_completeKillRobots()
		end
	end

	--[[
	if pawn:IsMech() then
		achievementData().mechsKilled = achievementData().mechsKilled + 1
		if achievementData().mechsKilled >= DEAD_MECHS_GOAL then
			truelch_completeRespawnAbuse()
		end
	end
	]]
end

--[[
local HOOK_onMissionStarted = function(mission)
	local exit = false
		or isSquad() == false
		or isMission() == false

	if exit then
		return
	end

	achievementData().mechsKilled = 0
end

local HOOK_onNextPhaseCreated = function(prevMission, nextMission)
	local exit = false
		or isSquad() == false
		or isMission() == false

	if exit then
		return
	end

	achievementData().mechsKilled = 0
end
]]


local HOOK_onMissionEnded = function(mission)
	local exit = false
		or isSquad() == false

	if exit then
		return
	end

	--Compute
	achievementData().isRespawnAchvStillOk = achievementData().isRespawnAchvStillOk and missionData().isRespawnUsed
end

-- --- EVENTS --- --
modApi.events.onGameVictory:subscribe(function(difficulty, islandsSecured, squad_id)
	local exit = false
		or isSquad() == false

	if exit then
		return
	end
	
	if achievementData().botsKilled >= ROBOTS_KILL_GOAL then
		truelch_completeKillRobots()
	end

	if achievementData().isRespawnAchvStillOk then
		truelch_completeRespawnAbuse()
	end
end)

--Inspired from my previous work:
local function EVENT_onModsLoaded()
	modapiext:addPawnKilledHook(HOOK_onPawnKilled)
	--modApi:addMissionStartHook(HOOK_onMissionStarted)
	--modApi:addMissionNextPhaseCreatedHook(HOOK_onNextPhaseCreated)
	modApi:addMissionEndHook(HOOK_onMissionEnded)
end

modApi.events.onModsLoaded:subscribe(EVENT_onModsLoaded)