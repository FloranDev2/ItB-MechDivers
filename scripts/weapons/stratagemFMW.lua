-------------------- IMPORTS --------------------

local this = {}
local mod = mod_loader.mods[modApi.currentMod]
local scriptPath = mod.scriptPath
local resourcePath = mod.resourcePath

--FMW
local truelch_divers_fmw = require(scriptPath.."fmw/FMW") --not needed?
local truelch_divers_fmwApi = require(scriptPath.."fmw/api") --that's what I needed!


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

    --Position, Item Name
    if mission.truelch_MechDivers.hellPods == nil then
        mission.truelch_MechDivers.hellPods = {}
    end

    return mission.truelch_MechDivers
end

-------------------- TEST --------------------

local function isStratagemWeapon(weapon)
    if type(weapon) == 'table' then
        weapon = weapon.__Id
    end
    return string.find(weapon, "truelch_Stratagem") ~= nil
end

---------------------------------------------------------
-------------------- SUPPORT WEAPONS --------------------
---------------------------------------------------------

-------------------- MODE 1: MG-43 Machine Gun --------------------

truelch_StratagemMode1 = {
	aFM_name = "Call-in Machine Gun",
	aFM_desc = "Free action."..
		"\nCall-in a pod containing a MG-43 Machine Gun that shoot a pushing projectile that deal 1 damage."..
		"\nShoot a second pushing projectile just before the enemies act if the Mech used half movement."..
		"\nShoot a third projectile after enemies actions if the Mech stayed immobile.",
	aFM_icon = "img/modes/icon_mg43.png",

	UpShot = "effects/truelch_shotup_stratagem_ball.png",
	Range = 2,
	Item = "truelch_Item_WeaponPod_Flam40", --in the end, I need to not spawn this directly
}

CreateClass(truelch_StratagemMode1)

function truelch_StratagemMode1:targeting(point)
	local points = {}

    for j = -self.Range, self.Range do
        for i = -self.Range, self.Range do
            local curr = point + Point(i, j)
            local isItem = Board:GetItem(curr) == nil
            if curr ~= point and Board:IsValid(curr) and not Board:IsBlocked(curr, PATH_PROJECTILE) and
                not Board:IsPod(curr) and isItem == false then
                points[#points+1] = curr
            end
        end
    end

	return points
end

function truelch_StratagemMode1:fire(p1, p2, se)
    local damage = SpaceDamage(p2, 0)
    --damage.sItem = self.Item
    --TODO: add mark
    --damage.sImageMark = "" --TODO
    se:AddArtillery(damage, self.UpShot)

    --TODO: add Board Anim

    --Free action
    se:AddScript([[
        Pawn:SetActive(true)
    ]])

    if not Board:IsTipImage() and isMission() then
    	LOG("------------- Attempting to add in the mission data...")
	    --I do need to add stuff in mission data, at least for the pseudo "ENV" effect

	    --V1: test
	    if missionData() ~= nil then
	    	LOG(" -> missionData() ok")
	    	if missionData().hellPods ~= nil then
	    		LOG(" -> missionData().hellPods ok")
	    	else
	    		LOG(" -> missionData().hellPods is nil!")
	    	end
	    else
	    	LOG(" -> missionData() is nil!")
	    end

	    --missionData().hellPods[#missionData().hellPods+1] = { p2, self.Item } --this causes an error
	    table.insert(missionData().hellPods, { p2, self.Item })

	    --V2: real thing (but not working yet)
	    --se:AddScript([[
	    --    missionData().hellPods[]]..tostring(#missionData().hellPods+1)..[[] = {]]..p2:GetString()..[[,]]..self.Item..[[}
	    --]])

	    --se:AddScript([[
	    --    table.insert(missionData().hellPods, { ]]..p2:GetString()..[[,]]..self.Item..[[ } )
	    --]])

	    LOG("------------- After -> loop:")
        for _, hellPod in pairs(missionData().hellPods) do
        	LOG("-> elem")
	        local loc = hellPod[1]
	        LOG("A")
	        local item = hellPod[2]
	        LOG("B")
	        LOG(" ---> loc: "..loc:GetString()..", item: "..item)
    	end
	end
end


-------------------- MODE 2: APW-1 Anti-Materiel Rifle --------------------

truelch_StratagemMode2 = truelch_StratagemMode1:new{
	aFM_name = "Call-in a Sniper Rifle",
	aFM_desc = "Free action."..
		"\nCall-in a pod containing a APW-1 Anti-Materiel Rifle."..
		"It shoots projectiles with a minimum range of 2 that deals heavy damage and pull.",
	aFM_icon = "img/modes/icon_apw1.png",
}


-------------------- MODE 3: FLAM-40 Flamethrower --------------------

truelch_StratagemMode3 = truelch_StratagemMode1:new{
	aFM_name = "Call-in a Flamethrower",
	aFM_desc = "Free action."..
		"\nCall-in a pod containing a FLAM-40 Flamethrower."..
		"Ignite the target tile and pull inward an adjacent tile.",
	aFM_icon = "img/modes/icon_flam40.png",
}


-------------------- MODE 4: RS-422 Railgun --------------------

truelch_StratagemMode4 = truelch_StratagemMode1:new{
	aFM_name = "Call-in a RS-422 Railgun",
	aFM_desc = "Free action."..
		"\nCall-in a pod containing a RS-422 Railgun."..
		"\nIt channels a powerful attack that can be released next turn."..
		"\nThe channeling does a push effect.",
	aFM_icon = "img/modes/icon_mode4.png",
}


-----------------------------------------------------
-------------------- AIR STRIKES --------------------
-----------------------------------------------------

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
	Description = "Calls-in pods, airstrikes or deployables."..
		"\nA random stratagem is added at the start of a mission."..
		"\nWeapons acquired by stratagems are removed at the end of the mission."..
		"\nSome stratagems are free actions (generally the calls for weapons)."..
		"\nIf you have a Shuttle Mech in range, the call-in can be instant. (airstrikes and weapons drops)",
	Class = "",
	Rarity = 1,
	PowerCost = 1,

	--Art
	Icon = "weapons/truelch_stratagem.png",
	UpShot = "effects/truelch_shotup_stratagem_ball.png",

    --FMW
	aFM_ModeList = {
		--Weapons
		"truelch_StratagemMode1", --Call-in MG-43 Machine Gun
		"truelch_StratagemMode2", --Call-in a APW-1 Anti-Materiel Rifle (Sniper)
		"truelch_StratagemMode3", --Call-in a FLAM-40 Flamethrower
		"truelch_StratagemMode4", --Call-in a ??? (channeling weapon)
		--Air strikes
		"truelch_StratagemMode5",
		"truelch_StratagemMode6",
		--Orbital strikes
		--Turrets
		--Drones
		--Misc
	},
	aFM_ModeSwitchDesc = "Click to change mode.",

	--Upgrades
	Upgrades = 2,
	UpgradeCost = { 1, 1 },
}

Weapon_Texts.truelch_StratagemFMW_Upgrade1 = "Veteran stratagems"
Weapon_Texts.truelch_StratagemFMW_Upgrade2 = "+1 Stratagems"

truelch_StratagemFMW_A = truelch_StratagemFMW:new{
    UpgradeDescription = "Give access to more powerful stratagems.",
}

truelch_StratagemFMW_B = truelch_StratagemFMW:new{
    UpgradeDescription = "Increase by 1 the max amount of stratagem and the stratagems acquired at the start of a mission.",
}

truelch_StratagemFMW_AB = truelch_StratagemFMW:new{
    --Nothing? Can I remove it then?
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
						end

						if isStratagemWeapon(weapon) then
							--TODO: set mode to the first available stratagem mode
							--[[
							fmw:FM_SetActive(p, "truelch_StratagemMode1", false)
							fmw:FM_SetActive(p, "truelch_StratagemMode3", false)
							fmw:FM_SetActive(p, "truelch_StratagemMode5", false)
							fmw:FM_SetActive(p, "truelch_StratagemMode6", false)
							]]
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