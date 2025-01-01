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

    if mission.truelch_MechDivers.airstrikes == nil then
    	mission.truelch_MechDivers.airstrikes = {}
    end

    if mission.truelch_MechDivers.orbitalStrikes == nil then
    	mission.truelch_MechDivers.orbitalStrikes = {}
    end

    return mission.truelch_MechDivers
end

-------------------- TEST --------------------

local truelch_stratagem_flag = false --moved this here

local function isStratagemWeapon(weapon)
    if type(weapon) == 'table' then
        weapon = weapon.__Id
    end
    local isStratagemWeapon = string.find(weapon, "truelch_Stratagem") ~= nil
    --LOG("weapon: "..weapon.." -> is stratagem weapon? "..tostring(isStratagemWeapon))
    --return string.find(weapon, "truelch_Stratagem") ~= nil
    return isStratagemWeapon
end

--Warning: this is a global function. Hence the very specific name.
function truelch_MechDivers_AddPodData(point, item)
	table.insert(missionData().hellPods, { point, item })
end

--id: 0: Napalm
--Or I could just pass the mode name?
function truelch_MechDivers_AddAirstrike(point, dir, id)
	--LOG(string.format("truelch_MechDivers_AddAirstrike(point: %s, dir: %s, id: %s)", point:GetString(), tostring(dir), tostring(id)))
	table.insert(missionData().airstrikes, { point, dir, id })
end

function truelch_MechDivers_AddOrbitalStrike(point, dir, id)
	--LOG(string.format("truelch_MechDivers_AddOrbitalStrike(point: %s, dir: %s, id: %s)", point:GetString(), tostring(dir), tostring(id)))
	table.insert(missionData().orbitalStrikes, { point, dir, id })
end

--Happens before Vek actions
local function resolveAirstrikes()
	--LOG("resolveAirstrikes()")
	--Loop
	for _, airstrike in pairs(missionData().airstrikes) do
		local se = SkillEffect()

		--LOG("----------> airstrike")
		local point = airstrike[1]
		local dir   = airstrike[2]
		local id    = airstrike[3]

		--LOG(string.format(" --- Airstrike: point: %s, dir: %s, id: %s", point:GetString(), tostring(dir), tostring(id)))

		se:AddSound("/weapons/airstrike") --almost forgot that!

		--Airstrike anim		
		if dir == 0 or dir == 2 then
			se:AddReverseAirstrike(point, "effects/truelch_eagle.png")
		else
			se:AddAirstrike(point, "effects/truelch_eagle.png")
		end		

		if id == 0 then
			--LOG(" --- Napalm airstrike!")
			----- NAPALM AIRSTRIKE -----
			--LOG("----- NAPALM AIRSTRIKE -----")

			--Center
			local curr = point
			--LOG("curr: "..curr:GetString())
			local damage = SpaceDamage(curr, 0)
			damage.iFire = EFFECT_CREATE
			se:AddDamage(damage)
			se:AddBounce(curr, 2)

			--Forward, left, right			
			local dirOffsets = {0, -1, 1} 
			for _, offset in ipairs(dirOffsets) do
				local curr = point + DIR_VECTORS[(dir + offset)% 4]
				--LOG("curr: "..curr:GetString())
				local damage = SpaceDamage(curr, 0)
				damage.iFire = EFFECT_CREATE
				se:AddDamage(damage)
				se:AddBounce(curr, 2)
			end
			--LOG(" --- End")
		elseif id == 1 then
			----- SMOKE AIRSTRIKE -----
			--LOG("----- SMOKE AIRSTRIKE -----")
			local curr = point
			--LOG("curr: "..curr:GetString())
			local damage = SpaceDamage(curr, 0)
			damage.iSmoke = EFFECT_CREATE				
			se:AddDamage(damage)
			se:AddBounce(curr, 2)

			--Forward, left, right
			local dirOffsets = {0, -1, 1} 
			for _, offset in ipairs(dirOffsets) do
				local curr = point + DIR_VECTORS[(dir + offset)% 4]
				--LOG("curr: "..curr:GetString())
				local damage = SpaceDamage(curr, 0)
				damage.iSmoke = EFFECT_CREATE				
				se:AddDamage(damage)
				se:AddBounce(curr, 2)
			end
		elseif id == 2 then
			----- 500KG BOMB -----
			--LOG("----- 500KG BOMB -----")
			--Delay
			se:AddDelay(0.05)

			--Bomb fall + explosion anim
			local bombAnim = SpaceDamage(point, 0)
			bombAnim.sAnimation = "truelch_500kg"
			se:AddDamage(bombAnim)

			--Delay
			se:AddDelay(0.5)

			--Board shake
			se:AddBoardShake(2)

			--Center
			local damage = SpaceDamage(point, 4)
			--damage.sAnimation = "ExploArt3" --TODO
			se:AddDamage(damage)
			se:AddBounce(point, 3)

			--Adjacent
			for dir = DIR_START, DIR_END do
				local curr = point + DIR_VECTORS[dir]
				local damage = SpaceDamage(curr, 2)
				--damage.sAnimation = "ExploArt1"
				--Does it have a dir?
				damage.sAnimation = "exploout2_" --Replacement proposed by Metalocif
				se:AddDamage(damage)
				se:AddBounce(curr, 1)
			end
		end

		Board:AddEffect(se) --this
	end	

	--Clear airstrikes data
	missionData().airstrikes = {}
end

local function rippleEffect(point)
	--Ripple effect
	local ripple = SkillEffect()
	--[[
	<center> (ring1) {ring2} [ring3]	
	                 {0,  2}
	        {-1,  1} (0,  1) {1,  1}
	{-2, 0} (-1,  0) <0,  0> (1,  0) {2,  0}
	        {-1, -1} (0, -1) {1, -1}
	                 {0,  2}
	]]

	--V1
	ring1 = { Point(0, 1), Point(-1, 0), Point(1, 0), Point(0, -1) }
	ring2 = { Point(0, 2), Point(-1, 1), Point(1, 1), Point(-2, 0), Point(2, 0), Point(-1, -1), Point(1, -1), Point(0, 2) }

	--Center
	ripple:AddBounce(point, 5)

	ripple:AddDelay(0.2)

	--1
	for _, offset in pairs(ring1) do
		local curr = point + offset
		if Board:IsValid(curr) then
			ripple:AddBounce(point + offset, 3)
		end
		--Negative bounce for center?
	end

	ripple:AddDelay(0.2)

	--2
	for _, offset in pairs(ring2) do
		local curr = point + offset
		if Board:IsValid(curr) then
			ripple:AddBounce(point + offset, 1)
		end
		--Negative bounce for ring1?
	end

	--3?

	--V2
	--[[
	doneList = { point }
	todoList = {}
	for i = 1, 3 do
		local bounce = 5 - i

		for _, pos in pairs(todoList) do
			--

			--Add adjacent tiles to todo list if they aren't already in the todo or done list:
			for dir = DIR_START, DIR_END do
				local curr = pos + DIR_VECTORS[dir]
				if not list_contains(doneList, curr) and list_contains(todoList, curr) then
					table.insert(todoList, p)
				end
			end

			--Remove from todo list
		end
	end
	]]

	--Add effect to Board
	Board:AddEffect(ripple)
end

--Happens AFTER enemies' actions
local function resolveOrbitalStrikes()
	--LOG("resolveOrbitalStrikes()")
	--Loop
	for _, orbitalStrike in pairs(missionData().orbitalStrikes) do
		--LOG("-> orbital strike")

		local se = SkillEffect()

		local point = orbitalStrike[1]
		local dir   = orbitalStrike[2] --not used
		local id    = orbitalStrike[3]

		--LOG(string.format(" --- point: %s, dir: %s, id: %s", point:GetString(), tostring(dir), tostring(id)))

		if id == 0 then
			----- ORIBTAL PRECISION STRIKE -----
			--LOG("Orbital precision strike")			

			--Center
			local damage = SpaceDamage(point, DAMAGE_DEATH)
			damage.iCrack = EFFECT_CREATE
			--damage.sAnimation = "ExploArt2" --TMP
			damage.sAnimation = "truelch_anim_orbital_laser"
			damage.sSound = "/weapons/burst_beam"
			Board:AddEffect(damage)

			rippleEffect(point)

			local damage = SpaceDamage(point, DAMAGE_DEATH)
			--damage.iCrack = EFFECT_CREATE
			Board:AddEffect(damage)

		--elseif id == 1 then
			----- ??? -----
		end
	end

	--Clear orbital strikes data
	missionData().orbitalStrikes = {}
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

	aFM_twoClick = false,
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
    damage.sImageMark = "combat/blue_stratagem_grenade.png"
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
	Item = "truelch_Item_WeaponPod_Apw1",
}


-------------------- MODE 3: FLAM-40 Flamethrower --------------------
truelch_Flam40Mode = truelch_Mg43Mode:new{
	aFM_name = "Call-in a Flamethrower",
	aFM_desc = "Free action."..
		"\nCall-in a pod containing a FLAM-40 Flamethrower."..
		"Ignite the target tile and pull inward an adjacent tile.",
	aFM_icon = "img/modes/icon_flam40.png",
	Item = "truelch_Item_WeaponPod_Flam40",
}


-------------------- MODE 4: RS-422 Railgun --------------------
truelch_Rs422Mode = truelch_Mg43Mode:new{
	aFM_name = "Call-in a Railgun",
	aFM_desc = "Free action."..
		"\nCall-in a pod containing a RS-422 Railgun."..
		"\nIt channels a powerful attack that can be released next turn."..
		"\nThe channeling does a push effect.",
	aFM_icon = "img/modes/icon_rs422.png",

	aFM_limited = 1,

	Item = "truelch_Item_WeaponPod_Rs422",
}

-----------------------------------------------------
-------------------- DEPLOYABLES --------------------
-----------------------------------------------------

-------------------- MODE 5: A/MG Machine Gun Sentry --------------------
truelch_MgSentryMode = truelch_Mg43Mode:new{
	aFM_name = "Call-in a Machine Gun Sentry",
	aFM_desc = "Drop an A/MG Machine Gun Sentry."..
		"\nIt shoots projectiles with a minimum range of 2 that deals heavy damage and pull.",
	aFM_icon = "img/modes/icon_mg_sentry.png",
	--aFM_limited = 1, --no need to re-define this
	Pawn = "truelch_Amg43MachineGunSentry",
}

function truelch_MgSentryMode:fire(p1, p2, se)
    local damage = SpaceDamage(p2, 0)    
    se:AddArtillery(damage, self.UpShot, FULL_DELAY)

    local dropAnim = SpaceDamage(p2, 0)
    --dropAnim.sAnimation = "truelch_anim_pod_land"
    dropAnim.sAnimation = "truelch_anim_pod_land_2"
    se:AddDamage(dropAnim)

    se:AddDelay(1.9)
    local spawn = SpaceDamage(p2, 0)
    spawn.sPawn = self.Pawn
    se:AddDamage(spawn)
end

-------------------- MODE 6: AA/M-12 Mortar Sentry --------------------
truelch_MortarSentryMode = truelch_MgSentryMode:new{
	aFM_name = "Call-in a Mortar Sentry",
	aFM_desc = "Drop an AA/M-12 Mortar Sentry."..
		"\n(...)",
	aFM_icon = "img/modes/icon_mortar_sentry.png",
	Pawn = "truelch_Am12MortarSentry", --"truelch_Am12MortarSentry_Weapon"
}

-------------------- MODE 7: A/ARC-3 Tesla Tower --------------------
truelch_TeslaTowerMode = truelch_MgSentryMode:new{
	aFM_name = "Call-in a Tesla Tower",
	aFM_desc = "Drop an A/ARC-3 Tesla Tower."..
		"\n(...)",
	aFM_icon = "img/modes/icon_tesla_tower.png",
	Pawn = "truelch_TeslaTower", --"truelch_TeslaTower"
}

-------------------- MODE 8: Guard Dog --------------------
truelch_GuardDogMode = truelch_MgSentryMode:new{
	aFM_name = "Release a Guard Dog",
	aFM_desc = "AX/AR-23 'Guard Dog'.".. --don't know if '' can work as a replacement to "" inside a string
		"\n(...)",
	aFM_icon = "img/modes/icon_guard_dog.png",
	Pawn = "truelch_GuardDog", --TODO
}

function truelch_GuardDogMode:fire(p1, p2, se)
    local damage = SpaceDamage(p2, 0)
    se:AddArtillery(damage, "effects/truelch_mg_drone_shotup.png", FULL_DELAY)

    local spawn = SpaceDamage(p2, 0)
    spawn.sPawn = self.Pawn
    se:AddDamage(spawn)
end




-----------------------------------------------------
-------------------- AIR STRIKES --------------------
-----------------------------------------------------
--Airstrikes after Mechs' turn but before Vek act. If the Shuttle Mech is in range, it can fires the effect itself, making it instant.

-------------------- MODE 9: Napalm Airstrike --------------------
truelch_NapalmAirstrikeMode = truelch_Mg43Mode:new{
	aFM_name = "Napalm Airstrike",
	aFM_desc = "Ignite 4 tiles in an arrow shapes."..
		"\nYou can first target a Shuttle Mech to do the strike instantly."..
		"\nOtherwise, the strike is released just before the Vek act", --wait, it actually doesn't change anything then?
	aFM_icon = "img/modes/icon_napalm_airstrike.png",
	aFM_twoClick = true, --!!!!
	MinRange = 1,
	MaxRange = 3,
	AirstrikeAnim = "units/mission/bomber_1.png", --TODO
	FakeMark = "combat/icons/icon_napalm_airstrike.png",
}

--[[
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
]]

function truelch_NapalmAirstrikeMode:targeting(point)
	local points = {}

    for j = -self.Range, self.Range do
        for i = -self.Range, self.Range do
            local curr = point + Point(i, j)            
            if curr ~= point then
                points[#points+1] = curr
            end
        end
    end

	return points
end

function truelch_NapalmAirstrikeMode:fire(p1, p2, se)
    local damage = SpaceDamage(p2, 0)    
    se:AddArtillery(damage, self.UpShot, FULL_DELAY) --useless here?

    local pawn = Board:GetPawn(p2)
    if pawn ~= nil and pawn:GetType() == "truelch_EagleMech" then
    	--LOG("------------ is Shuttle Mech!")

    	--Fake damage (just for test)
    	local damage = SpaceDamage(p2, 0)
    	--damage.sImageMark = "combat/icons/icon_napalm_airstrike.png"
    	se:AddDamage(damage)
    else
		local damage = SpaceDamage(p2, 0)
		damage.sImageMark = self.FakeMark
    	se:AddDamage(damage)
    end
end

function truelch_NapalmAirstrikeMode:second_targeting(p1, p2) 
    local ret = PointList()
    local isShuttle = Board:IsPawnSpace(p2) and Board:GetPawn(p2):GetType() == "truelch_EagleMech"

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
	--LOG("truelch_NapalmAirstrikeMode:second_fire")
    local ret = SkillEffect()

    local damage = SpaceDamage(p2, 0)    
    ret:AddArtillery(damage, self.UpShot, FULL_DELAY)

    local isShuttle = Board:IsPawnSpace(p2) and Board:GetPawn(p2):GetType() == "truelch_EagleMech"
    local dir = GetDirection(p3 - p2)

    --Shuttle's move
    if isShuttle then
    	--Shuttle move
		local move = PointList()
		move:push_back(p2)
		move:push_back(p3)
		ret:AddBounce(p2, 2)
		ret:AddLeap(move, 0.25)

		--Instant damage effect
		--Center
		local damage = SpaceDamage(p2, 0)
		damage.iFire = EFFECT_CREATE
		ret:AddDamage(damage)

		--Forward, left, right
		local dirOffsets = {0, -1, 1}
		for _, offset in ipairs(dirOffsets) do
			local curr = p2 + DIR_VECTORS[(dir + offset)% 4]
			local damage = SpaceDamage(curr, 0)
			damage.iFire = EFFECT_CREATE
			ret:AddDamage(damage)
		end

	else
		--Fake marks

		--Center
		local damage = SpaceDamage(p2, 0)		
		damage.sImageMark = self.FakeMark
		ret:AddDamage(damage)

		--Forward, left, right		
		local dirOffsets = {0, -1, 1} 
		for _, offset in ipairs(dirOffsets) do
			local curr = p2 + DIR_VECTORS[(dir + offset)% 4]
			local damage = SpaceDamage(curr, 0)
			damage.sImageMark = self.FakeMark
			ret:AddDamage(damage)
		end

		--Add Airstrike
		ret:AddScript(string.format("truelch_MechDivers_AddAirstrike(%s, %s, 0)", p2:GetString(), tostring(dir)))
    end

    return ret
end

-------------------- MODE 10: Smoke Airstrike --------------------
truelch_SmokeAirstrikeMode = truelch_NapalmAirstrikeMode:new{
	aFM_name = "Smoke Airstrike",
	aFM_desc = "Smoke 4 tiles in an arrow shapes."..
		"\nYou can first target a Shuttle Mech to do the strike instantly."..
		"\nOtherwise, the strike is released just before the Vek act", --wait, it actually doesn't change anything then?
	aFM_icon = "img/modes/icon_smoke_airstrike.png",
	FakeMark = "combat/icons/icon_smoke_airstrike.png",
}

function truelch_SmokeAirstrikeMode:second_fire(p1, p2, p3)
    local ret = SkillEffect()

    local damage = SpaceDamage(p2, 0)    
    ret:AddArtillery(damage, self.UpShot, FULL_DELAY)

    local isShuttle = Board:IsPawnSpace(p2) and Board:GetPawn(p2):GetType() == "truelch_EagleMech"
    local dir = GetDirection(p3 - p2)

    --Shuttle's move
    if isShuttle then
    	--Shuttle move
		local move = PointList()
		move:push_back(p2)
		move:push_back(p3)
		ret:AddBounce(p2, 2)
		ret:AddLeap(move, 0.25)

		--Instant damage effect
		--Center
		local damage = SpaceDamage(p2, 0)
		damage.iSmoke = EFFECT_CREATE
		ret:AddDamage(damage)

		--Forward, left, right		
		local dirOffsets = {0, -1, 1} 
		for _, offset in ipairs(dirOffsets) do
			local curr = p2 + DIR_VECTORS[(dir + offset)% 4]
			local damage = SpaceDamage(curr, 0)
			damage.iSmoke = EFFECT_CREATE
			ret:AddDamage(damage)
		end

	else
		--Fake marks
		
		--Center
		local damage = SpaceDamage(p2, 0)		
		damage.sImageMark = self.FakeMark
		ret:AddDamage(damage)

		--Forward, left, right		
		local dirOffsets = {0, -1, 1} 
		for _, offset in ipairs(dirOffsets) do
			local curr = p2 + DIR_VECTORS[(dir + offset)% 4]
			local damage = SpaceDamage(curr, 0)
			damage.sImageMark = self.FakeMark
			ret:AddDamage(damage)
		end

		--point, dir, id (1 = Smoke Airstrike)
		ret:AddScript(string.format("truelch_MechDivers_AddAirstrike(%s, %s, 1)", p2:GetString(), tostring(dir)))
    end

    return ret
end

-------------------- MODE 11: 500kg Bomb Airstrike --------------------
truelch_500kgAirstrikeMode = truelch_NapalmAirstrikeMode:new{
	aFM_name = "500kg Bomb",
	aFM_desc = "Call-in for an airstrike, dropping a 500kg bomb on the targeted tile, dealing 4 damage in the center and 2 damage on adjacent tiles."..
		"\nYou can first target a Shuttle Mech to do the strike instantly."..
		"\nOtherwise, the strike is released just before the Vek act", --wait, it actually doesn't change anything then?
	aFM_icon = "img/modes/icon_500kg_airstrike.png",
	aFM_twoClick = true, --we actually need it for (potential) shuttle move. Maybe I can do a TC exception?
	MinRange = 1,
	MaxRange = 3,
	AirstrikeAnim = "units/mission/bomber_1.png", --TODO
}

--TC wasn't necessary
--Oh, it was, for the shuttle move!
--Maybe I should write a TC exception for the case we don't target shuttle at p2
function truelch_500kgAirstrikeMode:fire(p1, p2, se)
    local damage = SpaceDamage(p2, 0)    
    se:AddArtillery(damage, self.UpShot, FULL_DELAY)

    local pawn = Board:GetPawn(p2)
    if pawn ~= nil and pawn:GetType() == "truelch_EagleMech" then
    	local damage = SpaceDamage(p2, 0)
    	se:AddDamage(damage)
    else
		local damage = SpaceDamage(p2, 0)
		damage.sImageMark = "combat/icons/icon_500kg_inner.png"
    	se:AddDamage(damage)
    end
end

function truelch_500kgAirstrikeMode:second_targeting(p1, p2) 
    local ret = PointList()
    local isShuttle = Board:IsPawnSpace(p2) and Board:GetPawn(p2):GetType() == "truelch_EagleMech"

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

function truelch_500kgAirstrikeMode:second_fire(p1, p2, p3)
	--LOG("truelch_NapalmAirstrikeMode:second_fire")
    local ret = SkillEffect()

	local damage = SpaceDamage(p2, 0)    
    ret:AddArtillery(damage, self.UpShot, FULL_DELAY)

    local isShuttle = Board:IsPawnSpace(p2) and Board:GetPawn(p2):GetType() == "truelch_EagleMech"
    local dir = GetDirection(p3 - p2)

    --Shuttle's move
    if isShuttle then
    	--Shuttle move
		local move = PointList()
		move:push_back(p2)
		move:push_back(p3)
		ret:AddBounce(p2, 2)
		ret:AddLeap(move, 0.25)

		--Anim
		local bombAnim = SpaceDamage(p2, 0)
		bombAnim.sAnimation = "truelch_500kg"
		ret:AddDamage(bombAnim)

		ret:AddDelay(0.5)

		--Board shake
		ret:AddBoardShake(2)

		--Center
		local damage = SpaceDamage(p2, 4)
		ret:AddDamage(damage)
		ret:AddBounce(p2, 3)

		--Adjacent
		for dir = DIR_START, DIR_END do
			local curr = p2 + DIR_VECTORS[dir]
			local damage = SpaceDamage(curr, 2)
			damage.sAnimation = "exploout2_"..dir
			ret:AddDamage(damage)
			ret:AddBounce(curr, 1)
		end

	else
		--Fake Mark

		--Center
		local damage = SpaceDamage(p2, 0)
		damage.sImageMark = "combat/icons/icon_500kg_inner.png"
		ret:AddDamage(damage)

		for dir = DIR_START, DIR_END do		
			local curr = p2 + DIR_VECTORS[dir]
			local damage = SpaceDamage(curr, 0)
			damage.sImageMark = "combat/icons/icon_500kg_outer.png"
			ret:AddDamage(damage)
		end

		ret:AddScript(string.format("truelch_MechDivers_AddAirstrike(%s, %s, 2)", p2:GetString(), tostring(dir)))
    end

    return ret
end



---------------------------------------------------------
-------------------- ORBITAL STRIKES --------------------
---------------------------------------------------------
--Orbital strikes effects will happen AFTER Vek act.

-------------------- MODE 12: Orbital Strike --------------------
--truelch_OrbitalPrecisionStrikeMode = truelch_NapalmAirstrikeMode:new{
truelch_OrbitalPrecisionStrikeMode = truelch_NapalmAirstrikeMode:new{
	aFM_name = "Orbital Precision Strike",
	aFM_desc = "Command a precision orbital strike that'll kill anything below."..
		"\nOrbital strikes happen after enemy turn, so you'll need to anticipate enemies' movement!",
	aFM_icon = "img/modes/icon_orbital_precision_strike.png",
	aFM_twoClick = false,
	Anim = "", --TODO
}

--[[
function truelch_OrbitalPrecisionStrikeMode:targeting(point)
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
]]

function truelch_OrbitalPrecisionStrikeMode:fire(p1, p2, se)
	local damage = SpaceDamage(p2, 0)    
    se:AddArtillery(damage, self.UpShot, FULL_DELAY)

	--Fake Mark
	local damage = SpaceDamage(p2, 0)
	damage.sImageMark = "combat/icons/icon_orbital_precision_strike.png"
	se:AddDamage(damage)

	--dir might not be used
	--point, dir, id
	se:AddScript(string.format("truelch_MechDivers_AddOrbitalStrike(%s, -1, 0)", p2:GetString()))
end


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
		"truelch_Mg43Mode",   --Call-in MG-43 Machine Gun
		"truelch_Apw1Mode",   --Call-in a APW-1 Anti-Materiel Rifle (Sniper)
		"truelch_Flam40Mode", --Call-in a FLAM-40 Flamethrower
		"truelch_Rs422Mode",  --Call-in a RS-422 Railgun (Channeling weapon)

		--Deployables
		"truelch_MgSentryMode",
		"truelch_MortarSentryMode",
		"truelch_TeslaTowerMode",
		"truelch_GuardDogMode",

		--Air strikes
		"truelch_NapalmAirstrikeMode",
		"truelch_SmokeAirstrikeMode",
		"truelch_500kgAirstrikeMode",

		--Orbital strikes
		"truelch_OrbitalPrecisionStrikeMode",
	},
	aFM_ModeSwitchDesc = "Click to change mode.",

	--Upgrades
	Upgrades = 1,
	UpgradeCost = { 2 --[[, 3]] },

	--TipImage
	TipIndex = 0,
	TipImage = {
		Unit   = Point(2, 1),
		Target = Point(2, 3),
		Second_Origin = Point(2, 1),
		Second_Target = Point(2, 3),
	}
}

Weapon_Texts.truelch_StratagemFMW_Upgrade1 = "+1 Stratagem"
--Weapon_Texts.truelch_StratagemFMW_Upgrade2 = "Veteran Stratagems" --Will be done in the future

truelch_StratagemFMW_A = truelch_StratagemFMW:new{
	UpgradeDescription = "+1 stratagem acquired at the start of each mission",    
}

--[[
truelch_StratagemFMW_B = truelch_StratagemFMW:new{
    UpgradeDescription = "Upgrade the stratagems.",
}

truelch_StratagemFMW_AB = truelch_StratagemFMW:new{
    --Nothing? Can I remove it then?
}
]]

function truelch_StratagemFMW:GetTargetArea_TipImage()
	local ret = PointList()
	for j = 0, 7 do
		for i = 0, 7 do
			ret:push_back(Point(i, j))
		end
	end
    return ret
end

function truelch_StratagemFMW:GetTargetArea_Normal(point)
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

function truelch_StratagemFMW:GetTargetArea(point)
	if not Board:IsTipImage() then
		return self:GetTargetArea_Normal(point)
	else
		return self:GetTargetArea_TipImage()
	end
end

function truelch_StratagemFMW:GetSkillEffect_TipImage()
	local ret = SkillEffect()
	--Nothing?
	return ret
end

function truelch_StratagemFMW:GetFinalEffect_TipImage()
	local ret = SkillEffect()

	--LOG("truelch_StratagemFMW:GetFinalEffect_TipImage() -> self.TipIndex: "..tostring(self.TipIndex))

	local p1 = Point(2, 1)
	local p2 = Point(2, 3)

	if self.TipIndex == 0 then
		--LOG("self.TipIndex == 0 -------------- A")
		self.TipIndex = 1
		--LOG("self.TipIndex == 0 -------------- B")
		local pawn = Board:GetPawn(Point(2, 3))
		--LOG("self.TipIndex == 0 -------------- C")
		if pawn ~= nil then
			--LOG("self.TipIndex == 0 -------------- C bis pawn ~= nil")
			pawn:SetSpace(Point(2, 1))
			--LOG("----------------- pawn id: "..tostring(pawn:GetId())) --93?!
		end
		--LOG("self.TipIndex == 0 -------------- D")
    	local damage = SpaceDamage(p2, 0)
    	--LOG("self.TipIndex == 0 -------------- E")
    	--damage.sImageMark = "combat/blue_stratagem_grenade.png" --doesn't show up in the tip image
	    ret:AddArtillery(p1, damage, "effects/truelch_shotup_stratagem_ball.png", FULL_DELAY)    
	    --LOG("self.TipIndex == 0 -------------- F")
	    local dropAnim = SpaceDamage(p2, 0)
	    --LOG("self.TipIndex == 0 -------------- G")
	    dropAnim.sAnimation = "truelch_anim_pod_land_2"
	    --LOG("self.TipIndex == 0 -------------- H")
	    ret:AddDamage(dropAnim)
	    --LOG("self.TipIndex == 0 -------------- I")
	elseif self.TipIndex == 1 then
		self.TipIndex = 2
		Board:SetItem(p2, "truelch_Item_WeaponPod_Mg43")
		ret:AddMove(Board:GetPath(p1, Point(2, 3), PATH_GROUND), FULL_DELAY)
	elseif self.TipIndex == 2 then
		--LOG("self.TipIndex == 2 -------------- A")
		self.TipIndex = 0
		--LOG("self.TipIndex == 2 -------------- B")
		local pawn = Board:GetPawn(Point(2, 1))
		if pawn ~= nil then
			pawn:SetSpace(Point(2, 3))
		else
			--LOG("------------- pawn is nil!!")
		end
		--LOG("self.TipIndex == 2 -------------- C")
		
		--LOG("self.TipIndex == 2 -------------- D")
		Board:AddAlert(Point(2, 3), "WEAPON ACQUIRED") --I want to make this happen AFTER move.
		--LOG("self.TipIndex == 2 -------------- E")
	end

	--LOG("truelch_StratagemFMW:GetFinalEffect_TipImage() - END")

	return ret
end

function truelch_StratagemFMW:GetSkillEffect_Normal(p1, p2)
	local se = SkillEffect()
	local currentMode = self:FM_GetMode(p1)
	
	if self:FM_CurrentModeReady(p1) then
		_G[currentMode]:fire(p1, p2, se)
	end

	return se
end


function truelch_StratagemFMW:GetSkillEffect(p1, p2)
	--LOG("truelch_StratagemFMW:GetSkillEffect")
	if not Board:IsTipImage() then
		return self:GetSkillEffect_Normal(p1, p2)
	else
		return self:GetSkillEffect_TipImage(--[[p1, p2]])
	end
end

function truelch_StratagemFMW:IsTwoClickException(p1, p2)
	return not _G[self:FM_GetMode(p1)].aFM_twoClick
end


function truelch_StratagemFMW:GetSecondTargetArea(p1, p2)

	if not Board:IsTipImage() then
		local currentShell = _G[self:FM_GetMode(p1)]
	    local pl = PointList()
	    
		if self:FM_CurrentModeReady(p1) and currentShell.aFM_twoClick then 
			pl = currentShell:second_targeting(p1, p2)
		end
	    
	    return pl
	else
		return self:GetTargetArea_TipImage()
	end
end



function truelch_StratagemFMW:GetFinalEffect_Normal(p1, p2, p3)
    local se = SkillEffect()
	local currentShell = _G[self:FM_GetMode(p1)]

	if self:FM_CurrentModeReady(p1) and currentShell.aFM_twoClick then 
		se = currentShell:second_fire(p1, p2, p3)  
	end
    
    return se
end

function truelch_StratagemFMW:GetFinalEffect(p1, p2, p3)
	if not Board:IsTipImage() then
		return self:GetFinalEffect_Normal(p1, p2, p3)
	else
		return self:GetFinalEffect_TipImage(--[[p1, p2, p3]])
	end
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
	"Smoke Airstrike",
	"500kg Airstrike",

	--Orbital strikes
	"Orbital Precision Strike",

	--Misc (shield?)
}

--TODO: final mission second phase
local HOOK_onMissionStarted = function(mission)
	--LOG("truelch_StratagemFMW -> HOOK_onMissionStarted")
	truelch_stratagem_flag = true
end

local function computeStratagems()
	--LOG("computeStratagems()")
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
									--LOG(" -> This is an active mode in the game data!")
									fmw:FM_SetActive(p, mode, true)
								else
									fmw:FM_SetActive(p, mode, false)
									table.insert(list, {mode, k})
								end
							end

							local stratIncr = 1 --amount of Stratagem modes added at the start of the mission (+2 with an upgrade)
							if weapon == "truelch_StratagemFMW_A" or weapon == "truelch_StratagemFMW_AB" then
								stratIncr = 2
							end

							for i = 1, stratIncr do
								--TODO: check if the list count > 0
								--TODO: max amount of stratagems
								--LOG("i: "..tostring(i).." / stratIncr: "..tostring(stratIncr)..", list size: "..tostring(#list))

								local randIndex = math.random(#list)
								--LOG("randIndex: "..tostring(randIndex))
								local randMode = list[randIndex][1]
								local index = list[randIndex][2]

								--Enable
								fmw:FM_SetActive(p, randMode, true)

								--Set mode to the last added
								fmw:FM_SetMode(p, randMode)

								table.remove(list, randIndex)

								--Add to game data
								if gameData().stratagems[p] == nil then
									gameData().stratagems[p] = {}
								end							
								table.insert(gameData().stratagems[p], randMode)
							end

							--Board:AddAlert(pawn:GetSpace(), tostring(truelch_statagemNames[index]).." added")
						end
					end
				end
			end
		end
	end
end

local testMode = true

local HOOK_onNextTurn = function(mission)
	if Game:GetTeamTurn() ~= TEAM_PLAYER then
		if truelch_stratagem_flag == true and not testMode then
			truelch_stratagem_flag = false
			computeStratagems()
		end
		--Resolve orbital strikes here
		resolveOrbitalStrikes()
	end	
end

local HOOK_onPreEnv = function(mission)
	--LOG("HOOK_onPreEnv")
	resolveAirstrikes()
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

    --Hell Pods
	for _, hellPod in pairs(missionData().hellPods) do
    	--Retrieve data
        local loc = hellPod[1]
        local item = hellPod[2]

        --thx tosx and Metalocif!
		Board:MarkSpaceImage(loc, "combat/tile_icon/tile_truelch_drop.png", GL_Color(255, 180, 0, 0.75))
		--Board:MarkSpaceImage(loc, "combat/tile_icon/tile_truelch_drop.png", GL_Color(255, 180, 0, alpha))
		Board:MarkSpaceDesc(loc, "hell_drop")
	end

	--Air strikes
	for _, airstrike in pairs(missionData().airstrikes) do
		local point = airstrike[1]
		local dir   = airstrike[2]
		local id    = airstrike[3]

		local icon = "combat/tile_icon/tile_truelch_drop.png" --default
		local desc = "hell_drop" --default

		if id == 0 then
			--Napalm Airstrike

			--Center
			Board:MarkSpaceImage(point, "combat/tile_icon/tile_truelch_napalm_airstrike.png", GL_Color(255, 180, 0, 0.75))
			Board:MarkSpaceDesc(point, "airstrike_napalm")

			--Front, left, right
			local dirOffsets = {0, -1, 1}
			for _, offset in ipairs(dirOffsets) do
				local curr = point + DIR_VECTORS[(dir + offset)% 4]
				Board:MarkSpaceImage(curr, "combat/tile_icon/tile_truelch_napalm_airstrike.png", GL_Color(255, 180, 0, 0.75))
				Board:MarkSpaceDesc(curr, "airstrike_napalm")
			end
		elseif id == 1 then
			--Smoke Airstrike

			--Center
			Board:MarkSpaceImage(point, "combat/tile_icon/tile_truelch_smoke_airstrike.png", GL_Color(255, 180, 0, 0.75))
			Board:MarkSpaceDesc(point, "airstrike_smoke")

			--Front, left, right
			local dirOffsets = {0, -1, 1}
			for _, offset in ipairs(dirOffsets) do
				local curr = point + DIR_VECTORS[(dir + offset)% 4]
				Board:MarkSpaceImage(curr, "combat/tile_icon/tile_truelch_smoke_airstrike.png", GL_Color(255, 180, 0, 0.75))
				Board:MarkSpaceDesc(curr, "airstrike_smoke")
			end
		elseif id == 2 then
			--500kg Bomb
			icon = "combat/tile_icon/tile_truelch_500kg_airstrike.png"
			desc = "airstrike_napalm"

			--Center
			Board:MarkSpaceImage(point, "combat/tile_icon/tile_truelch_500kg_airstrike.png", GL_Color(255, 180, 0, 0.75))
			Board:MarkSpaceDesc(point, "airstrike_500_center")

			--Outer
			for dir = DIR_START, DIR_END do
				local curr = point + DIR_VECTORS[dir]
				Board:MarkSpaceImage(curr, "combat/tile_icon/tile_truelch_500kg_airstrike.png", GL_Color(255, 180, 0, 0.75))
				Board:MarkSpaceDesc(curr, "airstrike_500_outer")
			end

		end
	end

	--Orbital strikes
		for _, orbitalStrike in pairs(missionData().orbitalStrikes) do
			local point = orbitalStrike[1]
			--local dir = orbitalStrike[2] --not used
			local id = orbitalStrike[3]

			if id == 0 then
				--Orbital strike
				Board:MarkSpaceImage(point, "combat/tile_icon/tile_truelch_orbital_precision_strike.png", GL_Color(255, 180, 0, 0.75))
				Board:MarkSpaceDesc(point, "orbital_precision_strike")
			end
		end
end

local function debugGameData()
	for i, stratagem in pairs(gameData().stratagems) do
		LOG(string.format("stratagem[%s]: %s", tostring(i), tostring(stratagem[i])))
	end
end

local HOOK_onSkillEnd = function(mission, pawn, weaponId, p1, p2)
    if type(weaponId) == 'table' then
        weaponId = weaponId.__Id
    end

    local p = pawn:GetId()

    --LOG("=========== BEFORE ===========")
    --debugGameData()

    local weapons = pawn:GetPoweredWeapons()

    local fmw
    for weaponIdx = 1, 3 do
    	local fmw = truelch_divers_fmwApi:GetSkill(p, weaponIdx, false)
    	weapon = weapons[weaponIdx]

    	--LOG(string.format("weaponIdx: %s, weaponId: %s, weapon: %s, fmw: %s", tostring(weaponIdx), tostring(weaponId), tostring(weapon), tostring(fmw)))

    	if fmw ~= nil and isStratagemWeapon(weaponId) and weapon == weaponId then
    		local mode = fmw:FM_GetMode(p)
    		--LOG(" ---> here, mode: "..tostring(mode))
    		for i, stratagem in pairs(gameData().stratagems) do
    			--if gameData().stratagems[p][i] == mode then
				if stratagem[i] == mode then
    				--LOG(" ------> HERE!!!!")
    				table.remove(gameData().stratagems[p], i)
    			end
			end
    	end
	end

    --LOG("=========== AFTER ===========")
    --debugGameData()
end


local function EVENT_onModsLoaded()
    modApi:addMissionStartHook(HOOK_onMissionStarted)
    modApi:addNextTurnHook(HOOK_onNextTurn)
    modApi:addPreEnvironmentHook(HOOK_onPreEnv)
    modApi:addMissionUpdateHook(HOOK_onMissionUpdate)
    modapiext:addSkillEndHook(HOOK_onSkillEnd)
end

modApi.events.onModsLoaded:subscribe(EVENT_onModsLoaded)

return this