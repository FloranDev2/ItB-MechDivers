-------------------- IMPORTS --------------------

local this = {}
local mod = mod_loader.mods[modApi.currentMod]
local scriptPath = mod.scriptPath
local resourcePath = mod.resourcePath

--FMW
local truelch_divers_fmw = require(scriptPath.."fmw/FMW") --not needed?
local truelch_divers_fmwApi = require(scriptPath.."fmw/api") --that's what I needed!

-------------------- TEST --------------------

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
	aFM_icon = "img/modes/icon_mode1.png",
	--Test Inactive
	--aFM_active = true,
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
	aFM_icon = "img/modes/icon_mode2.png",
}


-------------------- MODE 3 --------------------

truelch_StratagemMode3 = truelch_StratagemMode1:new{
	aFM_name = "Mode 3",
	aFM_desc = "Mode 3 desc.",
	aFM_icon = "img/modes/icon_mode3.png",
}


-------------------- MODE 4 --------------------

truelch_StratagemMode4 = truelch_StratagemMode1:new{
	aFM_name = "Mode 4",
	aFM_desc = "Mode 4 desc.",
	aFM_icon = "img/modes/icon_mode4.png",
}


-------------------- MODE 5 --------------------

truelch_StratagemMode5 = truelch_StratagemMode1:new{
	aFM_name = "Mode 5",
	aFM_desc = "Mode 5 desc.",
	aFM_icon = "img/modes/icon_mode5.png",
}

-------------------- MODE 6 --------------------

truelch_StratagemMode6 = truelch_StratagemMode1:new{
	aFM_name = "Mode 6",
	aFM_desc = "Mode 6 desc.",
	aFM_icon = "img/modes/icon_mode6.png",
}


-------------------- WEAPON --------------------

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
	if Game:GetTeamTurn() ~= TEAM_PLAYER or truelch_stratagem_flag == false then
		return
	end

	truelch_stratagem_flag = false

	LOG("---------> Computing Stratagems...")

	local size = Board:GetSize()
	for j = 0, size.y do
		for i = 0, size.x do
			local pawn = Board:GetPawn(Point(i, j))
			if pawn ~= nil and pawn:IsMech() then
				local weapons = pawn:GetPoweredWeapons()
				local p = pawn:GetId()
				for weaponIdx = 0, 2 do
					local fmw = truelch_divers_fmwApi:GetSkill(p, weaponIdx, false)
					if fmw ~= nil then
						local weapon = weapons[weaponIdx]

						if type(weapon) == 'table' then
							weapon = weapon.__Id
						end --if type(weapon) == 'table' then

						if isStratagemWeapon(weapon) then
							fmw:FM_SetActive(p, "truelch_StratagemMode3", false)
						end
					end
				end
			end
		end
	end
end

local function EVENT_onModsLoaded()
    modApi:addMissionStartHook(HOOK_onMissionStarted)
    modApi:addNextTurnHook(HOOK_onNextTurn)
end

modApi.events.onModsLoaded:subscribe(EVENT_onModsLoaded)

return this


