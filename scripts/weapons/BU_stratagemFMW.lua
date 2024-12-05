-------------------- IMPORTS --------------------

local this = {}
local mod = mod_loader.mods[modApi.currentMod]
local scriptPath = mod.scriptPath
local resourcePath = mod.resourcePath

--FMW
local truelch_divers_fmw = require(scriptPath.."fmw/FMW") --not needed?
local truelch_divers_fmwApi = require(scriptPath.."fmw/api") --that's what I needed!

-------------------- TEST --------------------

--[[
description = "???"
local function getStratagemFMWDescription()
	return description
end

local function getStratagemFMWIcon()
    return "weapons/truelch_stratagem.png"
end
]]

local function isStratagemWeapon(weapon)
    if type(weapon) == 'table' then
        weapon = weapon.__Id
    end
    return string.find(weapon, "truelch_Stratagem") ~= nil
end


-------------------- MODE 1 --------------------

truelch_StratagemMode1 = {
	aFM_name = "Mode 1",
	aFM_desc = "Mode 1 desc.",
	aFM_icon = "img/modes/icon_minigun.png",
}

CreateClass(truelch_StratagemMode1)

function truelch_StratagemMode1:targeting(point)
	local points = {}
	for j = 0, 7 do
		for i = 0, 7 do
			points[#points+1] = Point(i, j)
		end
	end
	return points
end

function truelch_StratagemMode1:fire(p1, p2, se)
end


-------------------- MODE 2 --------------------

truelch_StratagemMode2 = truelch_StratagemMode1:new{
	aFM_name = "Mode 2",
	aFM_desc = "Mode 2 desc.",
	aFM_icon = "img/modes/icon_rocket_pod.png",
}


-------------------- MODE 3 --------------------

truelch_StratagemMode3 = truelch_StratagemMode1:new{
	aFM_name = "Mode 3",
	aFM_desc = "Mode 3 desc.",
	aFM_icon = "img/modes/icon_rocket_pod.png",
}


-------------------- MODE 4 --------------------

truelch_StratagemMode4 = truelch_StratagemMode1:new{
	aFM_name = "Mode 4",
	aFM_desc = "Mode 4 desc.",
	aFM_icon = "img/modes/icon_rocket_pod.png",
}


-------------------- MODE 5 --------------------

truelch_StratagemMode5 = truelch_StratagemMode1:new{
	aFM_name = "Mode 5",
	aFM_desc = "Mode 5 desc.",
	aFM_icon = "img/modes/icon_rocket_pod.png",
}

-------------------- MODE 6 --------------------

truelch_StratagemMode6 = truelch_StratagemMode1:new{
	aFM_name = "Mode 6",
	aFM_desc = "Mode 6 desc.",
	aFM_icon = "img/modes/icon_rocket_pod.png",
}


-------------------- WEAPON --------------------
--[[
    local description = "Free action."..
        "\nRequest a supply pod for next turn to an empty tile. Any unit under the drop zone will die."..
        "\n\nNote: for technical reasons, you need to unselect and select again the unit to use a newly acquired weapon."
]]



truelch_StratagemFMW = aFM_WeaponTemplate:new{
	--Infos
	Name = "Stratagems",
	Description = "DESCRIPTION",
	Class = "", --Changed from Prime to Any
	Rarity = 1,
	PowerCost = 1,

	--Art
	Icon = "weapons/truelch_stratagem.png",
	UpShot = "effects/truelch_shotup_stratagem_ball.png",

    --FMW
	aFM_ModeList = {
		"truelch_StratagemMode1", 
		"truelch_StratagemMode2",
		"truelch_StratagemMode3",
		"truelch_StratagemMode4",
		"truelch_StratagemMode5",
		"truelch_StratagemMode6"
	},
	aFM_ModeSwitchDesc = "Click to change mode.",
}

function truelch_StratagemFMW:GetTargetArea(point)
	local pl = PointList()
	local currentMode = _G[self:FM_GetMode(point)]
    
	if self:FM_CurrentModeReady(point) then
		local points = currentMode:targeting(point)
		for _, p in ipairs(points) do
			pl:push_back(p)
		end
	end

	return pl
end

function truelch_StratagemFMW:GetSkillEffect(p1, p2)
	local se = SkillEffect()
	local currentMode = self:FM_GetMode(p1)
	
	if self:FM_CurrentModeReady(p1) then
		_G[currentMode]:fire(p1, p2, se)
	end

	LOG("truelch_StratagemFMW:GetSkillEffect - description: "..description)

	return se
end


----------------------------------------------- HOOKS / EVENTS SUBSCRIPTION -----------------------------------------------

local truelch_stratagem_flag = false

--TODO: final mission second phase
local HOOK_onMissionStarted = function(mission)
	--LOG("truelch_StratagemFMW -> HOOK_onMissionStarted")
	truelch_stratagem_flag = true
end

local HOOK_onNextTurn = function(mission)
	--LOG("HOOK_onNextTurn - Currently it is turn of team: " .. Game:GetTeamTurn())

	if Game:GetTeamTurn() ~= TEAM_PLAYER or truelch_stratagem_flag == false then
		return
	end

	truelch_stratagem_flag = false

	LOG("---------> Computing Stratagems...")

	--local fmw = truelch_divers_fmwApi:GetSkill(p, weaponIdx, false)

	local size = Board:GetSize()
	for j = 0, size.y do
		for i = 0, size.x do
			--LOG(debug.traceback())
			--LOG(" ------> "..Point(i, j):GetString())
			local pawn = Board:GetPawn(Point(i, j))
			if pawn ~= nil and pawn:IsMech() then
				LOG("pawn: "..pawn:GetMechName())
				local weapons = pawn:GetPoweredWeapons()
				local p = pawn:GetId()
				--LOG("p: "..tostring(p))
				for weaponIdx = 0, 2 do
					LOG(" -> weaponIdx: "..tostring(weaponIdx))
					local fmw = truelch_divers_fmwApi:GetSkill(p, weaponIdx, false)
					--LOG(" -> fmw: "..tostring(fmw))
					if fmw ~= nil then
						LOG("fmw!")
						local weapon = weapons[weaponIdx]

						if type(weapon) == 'table' then
							weapon = weapon.__Id
						end --if type(weapon) == 'table' then

						LOG("here! -> weapon: "..weapon)

						if isStratagemWeapon(weapon) then
							LOG(" ---> attempting disable mode 3")
							--Test disabling mode 3
							fmw:FM_DisableMode(p, "truelch_StratagemMode3") --doesn't work
							LOG(" ---> after mode 3 disabled")
						end
					end --if fmw ~= nil then
				end --weaponIdx = 0, 2 do
			end --if pawn ~= nil and pawn:IsMech() then
		end --for i = 0, size.x do
	end --for j = 0, size.y do
end --local HOOK_onNextTurn = function(mission)

local function EVENT_onModsLoaded()
    modApi:addMissionStartHook(HOOK_onMissionStarted)
    modApi:addNextTurnHook(HOOK_onNextTurn)
end

modApi.events.onModsLoaded:subscribe(EVENT_onModsLoaded)

return this


