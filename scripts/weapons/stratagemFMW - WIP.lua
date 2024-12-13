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

local function gameData()
	if GAME.truelch_MechDivers == nil then
		GAME.truelch_MechDivers = {}
	end

	if GAME.truelch_MechDivers.stratagems == nil then
		GAME.truelch_MechDivers.stratagems = {}
	end

	return GAME.truelch_MechDivers
end

--Still local because AddScript() isn't calling it directly
local function missionData()
    local mission = GetCurrentMission()

    if mission.truelch_MechDivers == nil then
        mission.truelch_MechDivers = {}
    end

    if mission.truelch_MechDivers.hellPods == nil then
        mission.truelch_MechDivers.hellPods = {}
    end

    return mission.truelch_MechDivers
end

-------------------- TEST --------------------

local truelch_stratagem_flag = false --moved this here

local function isStratagemWeapon(weapon)
    if type(weapon) == 'table' then
        weapon = weapon.__Id
    end
    return string.find(weapon, "truelch_Stratagem") ~= nil
end

--Warning: this is a global function. Hence the very specific name.
function truelch_MechDivers_AddPodData(point, item)
	table.insert(missionData().hellPods, { point, item })
end

---------------------------------------------------------
-------------------- SUPPORT WEAPONS --------------------
---------------------------------------------------------

-------------------- MODE 1: MG-43 Machine Gun --------------------
truelch_Mg43Mode = {
	aFM_name = "Call-in a Machine Gun",
	aFM_desc = "Free action."..
		"\nCall-in a pod containing a MG-43 Machine Gun that shoots a pushing projectile that deals 1 damage."..
		"\nShoots a second pushing projectile just before the enemies act if the Mech used half movement."..
		"\nShoots a third projectile after enemies actions if the Mech stayed immobile.",
	aFM_icon = "img/modes/icon_mg43.png",

	aFM_limited = 1,

	UpShot = "effects/truelch_shotup_stratagem_ball.png",
	Range = 2,
	Item = "truelch_Item_WeaponPod_Mg43",
}

CreateClass(truelch_Mg43Mode)

function truelch_Mg43Mode:targeting(point)
	local points = {}

	--Check if it's not already a point in the mission data!

    for j = -self.Range, self.Range do
        for i = -self.Range, self.Range do
            local curr = point + Point(i, j)

        	local isHellPodPoint = false
        	if isMission() then
				for _, hellPod in pairs(missionData().hellPods) do
					if hellPod[1] == curr then
						isHellPodPoint = true
						break
					end
				end
			end

            local isItem = Board:GetItem(curr) == nil
            
            if curr ~= point and
            	Board:IsValid(curr) and
            	not Board:IsBlocked(curr, PATH_PROJECTILE) and
                not Board:IsPod(curr) and
                isItem == false and
                isHellPodPoint == false then
                points[#points+1] = curr
            end
        end
    end

	return points
end



function truelch_Mg43Mode:fire(p1, p2, se)
    local damage = SpaceDamage(p2, 0)
    --damage.sAnimation = "truelch_anim_pod_land" --just to test the anim!
    --damage.sItem = self.Item --just for test, need to comment it again
    --damage.sImageMark = "combat/blue_stratagem_grenade.png"
    --damage.sPawn = "truelch_Amg43MachineGunSentry"
    se:AddArtillery(damage, self.UpShot)

    --Free action
    se:AddScript([[
        Pawn:SetActive(true)
    ]])

    if not Board:IsTipImage() and isMission() then
    	--Note: AddScript need to call a global function (so, a function without "local in front")
    	--These functions need to have a very specific name (prefixed with modder's username for example)
    	--to not accidentally override other function elsewhere with the same name.
    	--I've decided to not use missionData() directly here and rather use an intermediate function for that reason.
    	--Also, improvement: use string format
    	--Thx tosx and Metalocif for the help!
	    se:AddScript([[truelch_MechDivers_AddPodData(]]..p2:GetString()..[[,"]]..self.Item..[[")]])
	end
end


-------------------- MODE 2: APW-1 Anti-Materiel Rifle --------------------
truelch_Apw1Mode = truelch_Mg43Mode:new{
	aFM_name = "Call-in a Sniper Rifle",
	aFM_desc = "Free action."..
		"\nCall-in a pod containing a APW-1 Anti-Materiel Rifle."..
		"It shoots projectiles with a minimum range of 2 that deals heavy damage and pull.",
	aFM_icon = "img/modes/icon_apw1.png",

	--aFM_limited = 1, --no need to re-define this

	Item = "truelch_Item_WeaponPod_Apw1",
}


-------------------- MODE 3: FLAM-40 Flamethrower --------------------
truelch_Flam40Mode = truelch_Mg43Mode:new{
	aFM_name = "Call-in a Flamethrower",
	aFM_desc = "Free action."..
		"\nCall-in a pod containing a FLAM-40 Flamethrower."..
		"Ignite the target tile and pull inward an adjacent tile.",
	aFM_icon = "img/modes/icon_flam40.png",

	--aFM_limited = 1, --no need to re-define this

	Item = "truelch_Item_WeaponPod_Flam40",
}


-------------------- MODE 4: RS-422 Railgun --------------------
truelch_Rs422Mode = truelch_Mg43Mode:new{
	aFM_name = "Call-in a Railgun",
	aFM_desc = "Free action."..
		"\nCall-in a pod containing a RS-422 Railgun."..
		"\nIt channels a powerful attack that can be released next turn."..
		"\nThe channeling does a push effect.",
	aFM_icon = "img/modes/icon_mode4.png",

	aFM_limited = 1,
}

-----------------------------------------------------
-------------------- DEPLOYABLES --------------------
-----------------------------------------------------

-------------------- MODE 5: A/MG Machine Gun Sentry --------------------
truelch_MgSentryMode = truelch_Mg43Mode:new{
	aFM_name = "Call-in a Machine Gun Sentry",
	aFM_desc = "Drop an A/MG Machine Gun Sentry."..
		"\nIt shoots projectiles with a minimum range of 2 that deals heavy damage and pull.",
	aFM_icon = "img/modes/icon_apw1.png",

	--aFM_limited = 1, --no need to re-define this

	--Item = "truelch_Item_WeaponPod_Apw1",
	Pawn = "truelch_Amg43MachineGunSentry",
}

function truelch_MgSentryMode:fire(p1, p2, se)
    local damage = SpaceDamage(p2, 0)    
    se:AddArtillery(damage, self.UpShot, FULL_DELAY)

    local dropAnim = SpaceDamage(p2, 0)
    dropAnim.sAnimation = "truelch_anim_pod_land"
    se:AddDamage(dropAnim)

    se:AddDelay(1.9)
    local spawn = SpaceDamage(p2, 0)
    spawn.sPawn = "truelch_Amg43MachineGunSentry"
    se:AddDamage(spawn)
end

truelch_MgSentryMode = truelch_Mg43Mode:new{
	aFM_name = "Call-in a Machine Gun Sentry",
	aFM_desc = "Drop an A/MG Machine Gun Sentry."..
		"\n(...)",
	aFM_icon = "img/modes/icon_apw1.png",
	Pawn = "truelch_Amg43MachineGunSentry_Weapon",
}

function truelch_MgSentryMode:fire(p1, p2, se)
    local damage = SpaceDamage(p2, 0)    
    se:AddArtillery(damage, self.UpShot, FULL_DELAY)

    local dropAnim = SpaceDamage(p2, 0)
    dropAnim.sAnimation = "truelch_anim_pod_land"
    se:AddDamage(dropAnim)

    se:AddDelay(1.9)
    local spawn = SpaceDamage(p2, 0)
    spawn.sPawn = self.Pawn
    se:AddDamage(spawn)
end

-------------------- MODE 6: A/MG Machine Gun Sentry --------------------
truelch_MortarSentryMode = truelch_MgSentryMode:new{
	aFM_name = "Call-in a Mortar Sentry",
	aFM_desc = "Drop an AA/M-12 Mortar Sentry."..
		"\n(...)",
	aFM_icon = "img/modes/icon_apw1.png",
	Pawn = "truelch_Am12MortarSentry_Weapon",
}

-------------------- MODE 7: A/ARC-3 Tesla Tower --------------------
truelch_TeslaTowerMode = truelch_MgSentryMode:new{
	aFM_name = "Call-in a Tesla Tower",
	aFM_desc = "Drop an A/ARC-3 Tesla Tower."..
		"\n(...)",
	aFM_icon = "img/modes/icon_apw1.png",
	Pawn = "truelch_TeslaTower",
}

-------------------- MODE 8: Guard Dog --------------------
truelch_GuardDogMode = truelch_MgSentryMode:new{
	aFM_name = "Release a Guard Dog",
	aFM_desc = "AX/AR-23 'Guard Dog'."..
		"\n(...)",
	aFM_icon = "img/modes/icon_apw1.png",

	--aFM_limited = 1, --no need to re-define this

	--Item = "truelch_Item_WeaponPod_Apw1",
	Pawn = "truelch_Amg43MachineGunSentry",
}



-----------------------------------------------------
-------------------- AIR STRIKES --------------------
-----------------------------------------------------
--Airstrikes after Mechs' turn but before Vek act. If the Shuttle Mech is in range, it can fires the effect itself, making it instant.

-------------------- MODE 9: Eagle Napalm Airstrike --------------------
truelch_NapalmAirstrikeMode = truelch_Mg43Mode:new{
	aFM_name = "Napalm Airstrike",
	aFM_desc = "(TODO)",
	aFM_icon = "img/modes/icon_apw1.png",

	aFM_twoClick = true, --!!!!

	MinRange = 1,
	MaxRange = 3,
}

function truelch_NapalmAirstrikeMode:targeting(point)
	local points = {}

    for dir = DIR_START, DIR_END do
    	for i = 1, 7 do
    		local curr = point + DIR_VECTORS[dir]*i
    		points[#points+1] = curr
    		if not Board:IsValid(curr) then
    			break
    		end
    	end
    end

	return points
end

function truelch_NapalmAirstrikeMode:fire(p1, p2, se)    
    local pawn = Board:GetPawn(p2)

    if pawn ~= nil and pawn:GetType() == "truelch_EagleMech" then
    	LOG("------------ is Shuttle Mech!")
    end
end

function truelch_NapalmAirstrikeMode:second_targeting(p1, p2) 
    --return Ranged_TC_BounceShot.GetSecondTargetArea(Ranged_TC_BounceShot, p1, p2)
    local ret = PointList()

    local isShuttle = IsPawnSpace(p2) and Board:GetPawn(p2):GetType() == "truelch_EagleMech"

	for dir = DIR_START, DIR_END do
		for i = self.MinRange, self.MaxRange do
			local curr = p2 + DIR_VECTORS[dir]*i
			if not isShuttle or not Board:IsBlocked(curr, PATH_PROJECTILE) then
				ret:push_back(curr)
			end
		end
	end

    return ret
end

function truelch_NapalmAirstrikeMode:second_fire(p1, p2, p3)
    --return Ranged_TC_BounceShot.GetFinalEffect(Ranged_TC_BounceShot, p1, p2, p3)
    local ret = SkillEffect()

    local isShuttle = IsPawnSpace(p2) and Board:GetPawn(p2):GetType() == "truelch_EagleMech"

    --Shuttle's move
    if isShuttle then
		local move = PointList()
		move:push_back(p2)
		move:push_back(p3)
		ret:AddBounce(p2, 2)
		ret:AddLeap(move, 0.25)

		--Instant damage effect
	else
    	--Queued effect

    end

    return ret
end

---------------------------------------------------------
-------------------- ORBITAL STRIKES --------------------
---------------------------------------------------------
--Orbital strikes effects will happen AFTER Vek act.


------------------------------------------------
-------------------- WEAPON --------------------
------------------------------------------------

truelch_StratagemFMW = aFM_WeaponTemplate:new{
	--Infos
	Name = "Stratagems",
	Description = "Calls-in pods, airstrikes or deployables."..
		"\nA random stratagem is added at the start of a mission."..
		"\nWeapons acquired by stratagems are removed at the end of the mission."..
		"\nSome stratagems are free actions (generally the calls for weapons)."..
		"\nIf you have a Shuttle Mech in range, the call-in can be instant. (airstrikes and weapons drops)",
	Class = "",
	TwoClick = true, --!!!!
	Rarity = 1,
	PowerCost = 1,
	--Limited = 1, --what happens if I use the vanilla limited here?

	--Art
	Icon = "weapons/truelch_stratagem.png",
	UpShot = "effects/truelch_shotup_stratagem_ball.png",

    --FMW
	aFM_ModeList = {
		--Weapons
		--"truelch_Mg43Mode",   --Call-in MG-43 Machine Gun
		--"truelch_Apw1Mode",   --Call-in a APW-1 Anti-Materiel Rifle (Sniper)
		--"truelch_Flam40Mode", --Call-in a FLAM-40 Flamethrower
		--"truelch_Rs422Mode",  --Call-in a RS-422 Railgun (Channeling weapon)

		--Deployables
		"truelch_MgSentryMode",
		"truelch_MortarSentryMode",
		"truelch_TeslaTowerMode",
		--"truelch_GuardDogMode",

		--Air strikes
		"truelch_NapalmAirstrikeMode", --
		--"truelch_StratagemMode6",
		--Orbital strikes
		--Turrets and Drones
	},
	aFM_ModeSwitchDesc = "Click to change mode.",

	--Upgrades
	Upgrades = 2,
	UpgradeCost = { 3, 2 },
}

Weapon_Texts.truelch_StratagemFMW_Upgrade1 = "Veteran Stratagems"
Weapon_Texts.truelch_StratagemFMW_Upgrade2 = "+1 Stratagem"

truelch_StratagemFMW_A = truelch_StratagemFMW:new{
    UpgradeDescription = "Upgrade the stratagems.",
}

truelch_StratagemFMW_B = truelch_StratagemFMW:new{
    --UpgradeDescription = "Increase by 1 the max amount of stratagem and the stratagems acquired at the start of a mission.",
    UpgradeDescription = "+1 stratagem acquired at the start of each mission",
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

function truelch_StratagemFMW:IsTwoClickException(p1, p2)
	return not _G[self:FM_GetMode(p1)].aFM_twoClick 
end

function truelch_StratagemFMW:GetSecondTargetArea(p1, p2)
	local currentShell = _G[self:FM_GetMode(p1)]
    local pl = PointList()
    
	if self:FM_CurrentModeReady(p1) and currentShell.aFM_twoClick then 
		pl = currentShell:second_targeting(p1, p2)
	end
    
    return pl 
end

function truelch_StratagemFMW:GetFinalEffect(p1, p2, p3) 
    local se = SkillEffect()
	local currentShell = _G[self:FM_GetMode(p1)]

	if self:FM_CurrentModeReady(p1) and currentShell.aFM_twoClick then 
		se = currentShell:second_fire(p1, p2, p3)  
	end
    
    return se 
end


----------------------------------------------- HOOKS / EVENTS SUBSCRIPTION -----------------------------------------------


local truelch_statagemNames = {
	--Weapons
	"Call-in a Machine Gun",
	"Call-in a Sniper Rifle",
	"Call-in a Flamethrower",
	"Call-in a Railgun",

	--Deployables
	"Deploy a MG Sentry",
	"Deploy a Mortar Sentry",
	"Deploy a Tesla Tower",
	"Unleash Guard Dog",

	--Airstrikes
	"Napalm Airstrike",
	--"Mode6",

	--Orbital strikes

	--Deployables (turrets, drones)

	--Misc (shield?)
}

--TODO: final mission second phase
local HOOK_onMissionStarted = function(mission)
	--LOG("truelch_StratagemFMW -> HOOK_onMissionStarted")
	truelch_stratagem_flag = true
end

local testMode = true

local HOOK_onNextTurn = function(mission)
	if Game:GetTeamTurn() ~= TEAM_PLAYER or truelch_stratagem_flag == false then
		return
	end

	truelch_stratagem_flag = false

	if testMode then return end

	local size = Board:GetSize()
	for j = 0, size.y do
		for i = 0, size.x do
			local pawn = Board:GetPawn(Point(i, j))
			if pawn ~= nil and pawn:IsMech() then
				local weapons = pawn:GetPoweredWeapons()
				local p = pawn:GetId()
				--for weaponIdx = 0, 2 do --rather 1 -> 2 (or even to 3 with an additionnal weapon)
				for weaponIdx = 1, 3 do
					local fmw = truelch_divers_fmwApi:GetSkill(p, weaponIdx, false)
					if fmw ~= nil then
						local weapon = weapons[weaponIdx]
						if type(weapon) == 'table' then
							weapon = weapon.__Id
						end

						if isStratagemWeapon(weapon) then
							local list = {}
							--LOG(" --------- StratagemFMW found! Mode list:")
							for k, mode in pairs(_G[weapon].aFM_ModeList) do
								--LOG(string.format("k: %s, mode: %s", tostring(k), tostring(mode)))
								if gameData().stratagems[p] ~= nil and list_contains(gameData().stratagems[p], mode) then
									LOG(" -> This is an active mode in the game data!")
									fmw:FM_SetActive(p, mode, true)
								else
									fmw:FM_SetActive(p, mode, false)
									table.insert(list, {mode, k})
								end
							end

							local randIndex = math.random(#list)
							--LOG("randIndex: "..tostring(randIndex))
							local randMode = list[randIndex][1]
							local index = list[randIndex][2]	

							--Enable
							fmw:FM_SetActive(p, randMode, true)

							--Set mode to the last added
							fmw:FM_SetMode(p, randMode)

							--Add to game data
							if gameData().stratagems[p] == nil then
								gameData().stratagems[p] = {}
							end							
							table.insert(gameData().stratagems[p], randMode)

							Board:AddAlert(pawn:GetSpace(), tostring(truelch_statagemNames[index]).." added")
						end
					end
				end
			end
		end
	end
end

--This causes a crash
--[[
local incr = 0.01
local alpha = 0.5
]]
local HOOK_onMissionUpdate = function(mission)
	if not isMission() then return end

    --Alpha
    --[[
    alpha = alpha + incr
    if alpha > 1 then
    	alpha = 1
    	incr = -0.01
    elseif alpha < 0 then
    	alpha = 0
    	incr = 0.01
    end
    ]]

    --Loop
	for _, hellPod in pairs(missionData().hellPods) do
    	--Retrieve data
        local loc = hellPod[1]
        local item = hellPod[2]

        --thx tosx and Metalocif!
		Board:MarkSpaceImage(loc, "combat/tile_icon/tile_truelch_drop.png", GL_Color(255, 180, 0, 0.75))
		--Board:MarkSpaceImage(loc, "combat/tile_icon/tile_truelch_drop.png", GL_Color(255, 180, 0, alpha))
		Board:MarkSpaceDesc(loc, "hell_drop")
	end
end

local function EVENT_onModsLoaded()
    modApi:addMissionStartHook(HOOK_onMissionStarted)
    modApi:addNextTurnHook(HOOK_onNextTurn)
    modApi:addMissionUpdateHook(HOOK_onMissionUpdate)
end

modApi.events.onModsLoaded:subscribe(EVENT_onModsLoaded)

return this