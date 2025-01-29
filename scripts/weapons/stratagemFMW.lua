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

local truelch_max_strat = 2 --when not upgraded

local truelch_stratagem_flag = false --moved this here

--WHY WHY WHY WHY WHY
local truelch_strat_p1
local truelch_strat_p2


--[[
Arguments:
	se: SkillEffect
	point: Point
	dir: integer telling the direction (from 0 to 3)
	isAirstrike: boolean telling if it's an instant effect (no plane icon) or delayed (with plane icon)
Return value: (boolean)
	return true if it should override vanilla icon, false otherwise
]]
local function computeSmokeIcon(se, point, dir, isAirstrike)
	local pushedPawn = Board:GetPawn(point)
	local next = point + DIR_VECTORS[dir]
	if isAirstrike then
		--Airstrike
		if pushedPawn ~= nil  then
			if not pushedPawn:IsPushable() then
				--Guard
				local damage = SpaceDamage(point, 0)
				damage.sImageMark = "combat/icons/truelch_airstrike_smoke_push_guard_"..tostring(dir)..".png"
				se:AddDamage(damage)
			elseif Board:IsBlocked(next, PATH_PROJECTILE) then
				--Push blocked
				local damage = SpaceDamage(point, 0)
				damage.sImageMark = "combat/icons/truelch_airstrike_smoke_push_blocked_"..tostring(dir)..".png"
				se:AddDamage(damage)
			else
				--Regular push
				local damage = SpaceDamage(point, 0)
				damage.sImageMark = "combat/icons/truelch_airstrike_smoke_push_"..tostring(dir)..".png"
				se:AddDamage(damage)
			end
		else
			--Off
			local damage = SpaceDamage(point, 0)
			damage.sImageMark = "combat/icons/truelch_airstrike_smoke_push_off_"..tostring(dir)..".png"
			se:AddDamage(damage)
		end
	else
		--Just smoke icon with other information (push, off, guard, etc.)
		if pushedPawn ~= nil  then
			if not pushedPawn:IsPushable() then
				--Guard
				local damage = SpaceDamage(point, 0)
				damage.sImageMark = "combat/icons/truelch_smoke_push_guard_"..tostring(dir)..".png"
				se:AddDamage(damage)
			elseif Board:IsBlocked(next, PATH_PROJECTILE) then
				--Push blocked
				local damage = SpaceDamage(point, 0)
				damage.sImageMark = "combat/icons/truelch_smoke_push_blocked_"..tostring(dir)..".png"
				se:AddDamage(damage)
			else
				--Regular push
				local damage = SpaceDamage(point, 0)
				damage.sImageMark = "combat/icons/truelch_smoke_push_"..tostring(dir)..".png"
				se:AddDamage(damage)
			end
		else
			--Off
			local damage = SpaceDamage(point, 0)
			damage.sImageMark = "combat/icons/truelch_smoke_push_off_"..tostring(dir)..".png"
			se:AddDamage(damage)
		end
	end

	--In any case, we want to override icon
	return true
end

--[[
Arguments:
	se: SkillEffect
	point: Point
	dir: integer telling the direction (from 0 to 3)
	isAirstrike: boolean telling if it's an instant effect (no plane icon) or delayed (with plane icon)
Return value: (boolean)
	return true if it should override vanilla icon, false otherwise
]]
local function computeNapalmIcon(se, point, dir, isAirstrike)
	local pushedPawn = Board:GetPawn(point)
	local next = point + DIR_VECTORS[dir]
	if isAirstrike then
		--Airstrike
		if pushedPawn ~= nil  then
			if not pushedPawn:IsPushable() then
				--Guard
				local damage = SpaceDamage(point, 0)
				damage.sImageMark = "combat/icons/truelch_airstrike_fire_push_guard_"..tostring(dir)..".png"
				se:AddDamage(damage)
			elseif Board:IsBlocked(next, PATH_PROJECTILE) then
				--Push blocked
				local damage = SpaceDamage(point, 0)
				damage.sImageMark = "combat/icons/truelch_airstrike_fire_push_blocked_"..tostring(dir)..".png"
				se:AddDamage(damage)
			else
				--Regular push
				local damage = SpaceDamage(point, 0)
				damage.sImageMark = "combat/icons/truelch_airstrike_fire_push_"..tostring(dir)..".png"
				se:AddDamage(damage)
			end
		else
			--Off
			local damage = SpaceDamage(point, 0)
			damage.sImageMark = "combat/icons/truelch_airstrike_fire_push_off_"..tostring(dir)..".png"
			se:AddDamage(damage)
		end
		return true
	else
		--This is handled by vanilla game already...
		return false
	end
end


local function isShuttle(point)
	return Board:IsPawnSpace(point) and Board:GetPawn(point):GetType() == "truelch_EagleMech"
end

local function isStratagemWeapon(weapon)
    if type(weapon) == 'table' then weapon = weapon.__Id end
    return string.find(weapon, "truelch_Stratagem") ~= nil
end

--Warning: this is a global function. Hence the very specific name.
function truelch_MechDivers_AddPodData(point, item)
	--LOG(string.format("truelch_MechDivers_AddPodData(point: %s, item: %s)", point:GetString(), tostring(item)))
	table.insert(missionData().hellPods, { point, item })
end

--id: 0: Napalm
--Or I could just pass the mode name?
function truelch_MechDivers_AddAirstrike(point, dir, id)
	table.insert(missionData().airstrikes, { point, dir, id })
end

function truelch_MechDivers_AddOrbitalStrike(point, dir, id)
	table.insert(missionData().orbitalStrikes, { point, dir, id })
end

function computeNapalmAirstrike(se, point, dir, playAnim)
	if playAnim then
		se:AddSound("/weapons/airstrike") --almost forgot that!
		if dir == 0 or dir == 2 then
			se:AddReverseAirstrike(point, "effects/truelch_eagle.png")
		else
			se:AddAirstrike(point, "effects/truelch_eagle.png")
		end
	end

	--Center (fake marks)
	computeNapalmIcon(se, point, dir, not playAnim)

	--Center (real damage)
	local curr = point
	local damage = SpaceDamage(curr, 0)
	damage.iFire = EFFECT_CREATE
	damage.bHide = playAnim
	--Edit: no, we target this point for the shuttle move
	--damage.iPush = dir --new so that it's actually interesting to have the instant effect
	se:AddDamage(damage)
	se:AddBounce(curr, 2)

	--Forward, left, right
	local dirOffsets = {0, -1, 1} 
	for _, offset in ipairs(dirOffsets) do
		local curr = point + DIR_VECTORS[(dir + offset)% 4]
		local damage = SpaceDamage(curr, 0)
		damage.iFire = EFFECT_CREATE
		damage.bHide = playAnim
		if offset ~= 0 then
			damage.iPush = dir --test
		end
		se:AddDamage(damage)
		se:AddBounce(curr, 2)
	end
end

function computeSmokeAirstrike(se, point, dir, playAnim)
	if playAnim then
		se:AddSound("/weapons/airstrike") --almost forgot that!
		if dir == 0 or dir == 2 then
			se:AddReverseAirstrike(point, "effects/truelch_eagle.png")
		else
			se:AddAirstrike(point, "effects/truelch_eagle.png")
		end
	end

	--Center (fake marks)
	computeSmokeIcon(se, point, dir, true)


	--Center (real damage)
	local damage = SpaceDamage(point, 0)
	damage.iSmoke = EFFECT_CREATE
	damage.bHide = playAnim
	--Edit: no, we target this point for the shuttle move
	--damage.iPush = dir --new so that it's actually interesting to have the instant effect
	se:AddDamage(damage)
	se:AddBounce(point, 2)

	--Forward, left, right
	local dirOffsets = {0, -1, 1} 
	for _, offset in ipairs(dirOffsets) do
		local curr = point + DIR_VECTORS[(dir + offset)% 4]
		local damage = SpaceDamage(curr, 0)
		damage.iSmoke = EFFECT_CREATE
		damage.bHide = playAnim
		--damage.sImageMark = "combat/icons/icon_smoke_airstrike.png" --if effect is instant, don't show the plane icon
		if offset ~= 0 then
			damage.iPush = dir --test
		end
		se:AddDamage(damage)
		se:AddBounce(curr, 2)
	end
end

function compute500KgAirstrike(se, point, playAnim)
	if playAnim then
		se:AddSound("/weapons/airstrike") --almost forgot that!
		if dir == 0 or dir == 2 then
			se:AddReverseAirstrike(point, "effects/truelch_eagle.png")
		else
			se:AddAirstrike(point, "effects/truelch_eagle.png")
		end
	end

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
	damage.sImageMark = "combat/icons/icon_500kg_inner.png" --specifically for test mech scenario
	damage.sSound = "/impact/generic/explosion"
	se:AddDamage(damage)
	se:AddBounce(point, 3)

	--Adjacent
	for dir = DIR_START, DIR_END do
		local curr = point + DIR_VECTORS[dir]
		local damage = SpaceDamage(curr, 2)
		damage.sImageMark = "combat/icons/icon_500kg_outer.png" --specifically for test mech scenario
		--Does it have a dir?
		damage.sAnimation = "exploout2_" --Replacement proposed by Metalocif
		se:AddDamage(damage)
		se:AddBounce(curr, 1)
	end
end


--Happens before Vek actions
local function resolveAirstrikes()
	--Loop
	for _, airstrike in pairs(missionData().airstrikes) do
		local se = SkillEffect()

		local point = airstrike[1]
		local dir   = airstrike[2]
		local id    = airstrike[3]	

		if id == 0 then
			computeNapalmAirstrike(se, point, dir, true)
		elseif id == 1 then
			computeSmokeAirstrike(se, point, dir, true)
		elseif id == 2 then
			compute500KgAirstrike(se, point, true)
		end

		Board:AddEffect(se)
	end	

	--Clear airstrikes data
	missionData().airstrikes = {}
end

--That one too?
local function rippleEffect(point)
	--Ripple effect
	local ripple = SkillEffect()

	ring1 = { Point(0, 1), Point(-1, 0), Point(1, 0), Point(0, -1) }
	ring2 = { Point(0, 2), Point(-1, 1), Point(1, 1), Point(-2, 0), Point(2, 0), Point(-1, -1), Point(1, -1), Point(0, 2) }

	--Center
	ripple:AddBounce(point, 5)

	ripple:AddDelay(0.2)

	for _, offset in pairs(ring1) do
		local curr = point + offset
		if Board:IsValid(curr) then
			ripple:AddBounce(point + offset, 3)
		end
		--Negative bounce for center?
	end

	ripple:AddDelay(0.2)
	
	for _, offset in pairs(ring2) do
		local curr = point + offset
		if Board:IsValid(curr) then
			ripple:AddBounce(point + offset, 1)
		end
		--Negative bounce for ring1?
	end

	--Add effect to Board
	Board:AddEffect(ripple)
end

--Oooh, I think I need the function to NOT be local to be called from an AddScript() function
function computeOrbitalPrecisionStrike(point)
	local damage = SpaceDamage(point, DAMAGE_DEATH)
	damage.iCrack = EFFECT_CREATE
	damage.sAnimation = "truelch_anim_orbital_laser"
	damage.sSound = "/weapons/burst_beam"
	Board:AddEffect(damage)

	rippleEffect(point)

	local damage = SpaceDamage(point, DAMAGE_DEATH)
	Board:AddEffect(damage)
end

function computeOrbitalWalkingBarrage(point, dir)
	local effect = SkillEffect()

	local damage = SpaceDamage(point, 2)
	damage.sAnimation = "ExploRaining1"
	damage.sSound = "/impact/generic/explosion"
	effect:AddDamage(damage)

	local curr = point + DIR_VECTORS[dir]	
	if not Board:IsBuilding(curr) then
		effect:AddDelay(0.5)

		local damage = SpaceDamage(curr, 2)
		damage.sAnimation = "ExploRaining1"
		damage.sSound = "/impact/generic/explosion"
		effect:AddDamage(damage)

		if not IsTestMechScenario() then
			--Continue!
			modApi:runLater(function() --maybe this will avoid the problem?
				truelch_MechDivers_AddOrbitalStrike(curr, dir, 1)
			end)
		end
	end

	Board:AddEffect(effect)
end

--Happens AFTER enemies' actions
local function resolveOrbitalStrikes()
	--Loop
	for _, orbitalStrike in pairs(missionData().orbitalStrikes) do
		local se = SkillEffect()

		local point = orbitalStrike[1]
		local dir   = orbitalStrike[2] --not used (well, maybe?)
		local id    = orbitalStrike[3]

		if id == 0 then
			computeOrbitalPrecisionStrike(point)
		elseif id == 1 then
			computeOrbitalWalkingBarrage(point, dir)
		end
	end

	--Clear orbital strikes data
	missionData().orbitalStrikes = {}
end

---------------------------------------------------------
-------------------- SUPPORT WEAPONS --------------------
---------------------------------------------------------

-------------------- MODE 0: Base (not used) --------------------
truelch_StratMode = {
	aFM_name = "Name",
	aFM_desc = "Description.",
	aFM_icon = "img/modes/icon_mg43.png",
	Range = 2,
	aFM_twoClick = false,
	aFM_limited = 1,
	UpShot = "effects/truelch_shotup_stratagem_ball.png",
}

function truelch_StratMode:targeting(point)
	local points = {}

    for j = -self.Range, self.Range do
        for i = -self.Range, self.Range do
            local curr = point + Point(i, j)
            if curr ~= point and Board:IsValid(curr) then
            	points[#points+1] = curr
            end
        end
    end

	return points
end

CreateClass(truelch_StratMode)

-------------------- MODE 1: MG-43 Machine Gun --------------------
truelch_Mg43Mode = truelch_StratMode:new{
	aFM_name = "Call-in a Machine Gun",
	aFM_desc = "Free action."..
		"\nCall-in a pod containing a MG-43 Machine Gun that shoots a pushing projectile that deals 1 damage."..
		"\nShoots a second pushing projectile just before the enemies act if the Mech used half movement."..
		"\nShoots a third projectile after enemies actions if the Mech stayed immobile.",
	aFM_icon = "img/modes/icon_mg43.png",

	aFM_twoClick = true,

	--UpShot = "effects/truelch_shotup_stratagem_ball.png",

	Item = "truelch_Item_WeaponPod_Mg43",
	Weapon = "truelch_Mg43MachineGun",
	Message = "Acquired a MG-43 Machine Gun!", --"\n(de-select and re-select the Mech to see it)"
}

--p2 is FUCKING nil FOR NO REASON. So I'm using this external variable. FFS. GAAAH
function truelch_Mg43Mode:isTwoClickExc(p1, p2)
	--return not isShuttle(p2) or IsTestMechScenario() --p2 nil...
	return not isShuttle(truelch_strat_p2) or IsTestMechScenario() --WHY WHY WHY WHY WHY
end

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
            	(not Board:IsBlocked(curr, PATH_PROJECTILE) or isShuttle(curr)) and
                not Board:IsPod(curr) and
                isItem == false and --not Board:IsPod(point) --same?
                not Board:IsTerrain(curr, TERRAIN_HOLE) and
                not Board:IsTerrain(curr, TERRAIN_WATER) and --works with lava? and acid water?
                not Board:IsTerrain(curr, TERRAIN_LAVA) and
                isHellPodPoint == false then
                	points[#points+1] = curr
            end
        end
    end

	return points
end

--Note: AddScript need to call a global function (so, a function without "local in front")
--These functions need to have a very specific name (prefixed with modder's username for example)
--to not accidentally override other function elsewhere with the same name.
--I've decided to not use missionData() directly here and rather use an intermediate function for that reason.
--Thx tosx and Metalocif for the help!
function truelch_Mg43Mode:fire(p1, p2, se)
	if IsTestMechScenario() then
		local damage = SpaceDamage(p2, 0)
    	damage.sImageMark = "combat/blue_stratagem_grenade.png"
    	damage.sItem = self.Item
    	se:AddArtillery(damage, self.UpShot)
		return
	end

	if isShuttle(p2) then
		--"throw"
		local damage = SpaceDamage(p2, 0)
		damage.sImageMark = "advanced/combat/throw_"..GetDirection(p2 - p1)..".png"
	else
	    local damage = SpaceDamage(p2, 0)
    	damage.sImageMark = "combat/blue_stratagem_grenade.png"
    	se:AddArtillery(damage, self.UpShot)
	end

    --Free action
    se:AddScript("Pawn:SetActive(true)")

    --tip image would not reach here anyway (i think?)
    if not Board:IsTipImage() and isMission() then
	    se:AddScript(string.format([[truelch_MechDivers_AddPodData(%s, "%s")]], p2:GetString(), self.Item))
	end
end

function truelch_Mg43Mode:second_targeting(p1, p2)
    local ret = PointList()

	for dir = DIR_START, DIR_END do
		local curr = p2 + DIR_VECTORS[dir]*2
		if not isShuttle(p2) or not Board:IsBlocked(curr, PATH_PROJECTILE) then
			ret:push_back(curr)
		end
	end

    return ret
end

--Need to do this because you can't call a global function with arguments with AddScript. SOMEHOW.
--Why is it name ZogZog? Why not?
local zogZogLoc    --Am I
local zogZogWeapon --Becoming crazy?
local zogZogMsg    --NO NO IT'S FINE I'M FINE...              ...HAHAHAHAHAHAHA
function ZogZog(--[[loc, weapon, msg]]) --hehehe... NO
	--LOG(string.format("ZogZog(loc: %s, weapon: %s, msg: %s)", loc:GetString(), weapon, msg))
	--LOG("ZogZog()")
	--TryAddWeapon(loc, weapon, msg) --HAHAHA
	TryAddWeapon(zogZogLoc, zogZogWeapon, zogZogMsg) --HO? OH OH OH
end
--pleasedontjudgeme

function truelch_Mg43Mode:second_fire(p1, p2, p3)
    local ret = SkillEffect()

    --Shuttle's move
    if isShuttle(p2) then
    	local dir = GetDirection(p3 - p2)

    	--Shuttle move
		local move = PointList()
		move:push_back(p2)
		move:push_back(p3)
		ret:AddBounce(p2, 2)
		ret:AddLeap(move, 0.25)

		local middle = p2 + DIR_VECTORS[dir]
		local pawn = Board:GetPawn(middle)
		if pawn == nil then
			--Create an item (instantly)
			local damage = SpaceDamage(middle, 0)
			damage.sItem = self.Item
			ret:AddDamage(damage)
			--ret.sItem = self.Item
		elseif pawn:IsMech() then
			--Give this mech the weapon
			--TryAddWeapon(middle, self.Weapon, self.Message) --don't want to happen during preview but when the weapon is actually fired
			--Apparently, you cannot call a global function with argument in AddScript()
			--local stringTest = string.format("TryAddWeapon(%s, %s, %s)", middle:GetString(), self.Weapon, self.Message)
			
			--So I might try with an intermediate local function
			zogZogLoc = middle         --Everything
			zogZogWeapon = self.Weapon --is
			zogZogMsg = self.Message   --daijobu
			ret:AddScript("ZogZog()")
		else
			--LOG("Certainly an enemy or a deployable or whatever")
		end		
	else
		--Should NOT happen
		LOG("WTF")
    end

    --Free action
    ret:AddScript("Pawn:SetActive(true)")

    return ret
end


-------------------- MODE 2: APW-1 Anti-Materiel Rifle --------------------
truelch_Apw1Mode = truelch_Mg43Mode:new{
	aFM_name = "Call-in a Sniper Rifle",
	aFM_desc = "Free action."..
		"\nCall-in a pod containing a APW-1 Anti-Materiel Rifle."..
		"It shoots projectiles with a minimum range of 2 that deals heavy damage and pull.",
	aFM_icon = "img/modes/icon_apw1.png",

	Item = "truelch_Item_WeaponPod_Apw1",
	Weapon = "truelch_Apw1AntiMaterielRifle",
	Message = "Acquired an APW-1 Anti-Materiel Rifle!", --"\n(de-select and re-select the Mech to see it)"
}


-------------------- MODE 3: FLAM-40 Flamethrower --------------------
truelch_Flam40Mode = truelch_Mg43Mode:new{
	aFM_name = "Call-in a Flamethrower",
	aFM_desc = "Free action."..
		"\nCall-in a pod containing a FLAM-40 Flamethrower."..
		"Ignite the target tile and pull inward an adjacent tile.",
	aFM_icon = "img/modes/icon_flam40.png",

	Item = "truelch_Item_WeaponPod_Flam40",
	Weapon = "truelch_Flam40Flamethrower",
	Message = "Acquired a FLAM-40 Flamethrower!", --"\n(de-select and re-select the Mech to see it)"
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
	Weapon = "truelch_Rs422Railgun",
	Message = "Acquired a RS-422 Railgun!", --"\n(de-select and re-select the Mech to see it)"
}

-----------------------------------------------------
-------------------- DEPLOYABLES --------------------
-----------------------------------------------------

-------------------- MODE 5: A/MG Machine Gun Sentry --------------------
truelch_MgSentryMode = truelch_StratMode:new{ --no more spaghetti
	aFM_name = "Call-in a Machine Gun Sentry",
	aFM_desc = "Drop an A/MG Machine Gun Sentry."..
		"\nShoot a projectile that deployables 1 damage and pushes.",
	aFM_icon = "img/modes/icon_mg_sentry.png",
	Pawn = "truelch_Amg43MachineGunSentry",
}

function truelch_MgSentryMode:targeting(point)
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
            if curr ~= point and Board:IsValid(curr) and not Board:IsBlocked(curr, PATH_PROJECTILE) and isItem == false and not Board:IsPod(curr)
            		and not Board:IsTerrain(curr, TERRAIN_HOLE) and not Board:IsTerrain(curr, TERRAIN_WATER) and not Board:IsTerrain(curr, TERRAIN_LAVA) then
            	points[#points+1] = curr
            end
        end
    end

	return points
end

function truelch_MgSentryMode:fire(p1, p2, se)
    local damage = SpaceDamage(p2, 0)
    se:AddArtillery(damage, self.UpShot, FULL_DELAY)

    local dropAnim = SpaceDamage(p2, 0)
    dropAnim.sAnimation = "truelch_anim_pod_land_2"
    se:AddDamage(dropAnim)

    se:AddDelay(1.9)

    se:AddScript("Board:StartShake(0.5)")

    local sfx = SpaceDamage(p2, 0)
    sfx.sSound = "/mech/land"
    se:AddDamage(sfx)

    --Dust
    for dir = DIR_START, DIR_END do
        local curr = p2 + DIR_VECTORS[dir]
        local dust = SpaceDamage(curr, 0)
        dust.sAnimation = "airpush_"..dir
        se:AddDamage(dust)
    end

    local spawn = SpaceDamage(p2, 0)
    spawn.sPawn = self.Pawn
    se:AddDamage(spawn)
end

-------------------- MODE 6: AA/M-12 Mortar Sentry --------------------
truelch_MortarSentryMode = truelch_MgSentryMode:new{
	aFM_name = "Call-in a Mortar Sentry",
	aFM_desc = "Drop an AA/M-12 Mortar Sentry."..
		"\nIt shoots artillery projectiles that deals 1 damage to the target and adjacent tiles and pushes adjacent tiles."..
		"\nIt acts autonomously during enemy turn.",
	aFM_icon = "img/modes/icon_mortar_sentry.png",
	Pawn = "truelch_Am12MortarSentry",
}

-------------------- MODE 7: A/ARC-3 Tesla Tower --------------------
truelch_TeslaTowerMode = truelch_MgSentryMode:new{
	aFM_name = "Call-in a Tesla Tower",
	aFM_desc = "Drop an A/ARC-3 Tesla Tower."..
		"\nChain damage through adjacent targets, dealing 2 points of damage. (can damage friendly units but not the buildings)"..
		"\nIt acts autonomously during enemy turn.",
	aFM_icon = "img/modes/icon_tesla_tower.png",
	Pawn = "truelch_TeslaTower",
}

-------------------- MODE 8: Guard Dog --------------------
truelch_GuardDogMode = truelch_MgSentryMode:new{
	aFM_name = [[Release a AX/AR-23 "Guard Dog"]],
	aFM_desc = "A Flying drone that shoots projectiles at melee range."..
		"\nIt plays autonomously during enemy turn.",
	aFM_icon = "img/modes/icon_guard_dog.png",
	Pawn = "truelch_GuardDog",
}

function truelch_GuardDogMode:targeting(point)
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
            if curr ~= point and Board:IsValid(curr) and not Board:IsBlocked(curr, PATH_PROJECTILE) and isItem == false and not Board:IsPod(curr) then
            	points[#points+1] = curr
            end
        end
    end

	return points
end

function truelch_GuardDogMode:fire(p1, p2, se)
    local damage = SpaceDamage(p2, 0)
    se:AddArtillery(damage, "effects/truelch_mg_drone_shotup.png", FULL_DELAY)
    local spawn = SpaceDamage(p2, 0)
    spawn.sPawn = self.Pawn
    se:AddDamage(spawn)
end

-------------------- MODE 9: Guard Dog --------------------
truelch_GuardDogLaserMode = truelch_GuardDogMode:new{
	aFM_name = [[Release a AX/LAS-5 "Guard Dog" Rover]],
	aFM_desc = "A flying drone that shoots a laser beam."..
		"\nIt plays autonomously during enemy turn.",
	aFM_icon = "img/modes/icon_guard_dog_laser.png",
	Pawn = "truelch_GuardDogLaser",
}

-----------------------------------------------------
-------------------- AIR STRIKES --------------------
-----------------------------------------------------
--Airstrikes after Mechs' turn but before Vek act. If the Shuttle Mech is in range, it can fires the effect itself, making it instant.

-------------------- MODE 10: Napalm Airstrike --------------------
truelch_NapalmAirstrikeMode = truelch_StratMode:new{
	aFM_name = "Napalm Airstrike",
	aFM_desc = "Ignite 4 tiles in an arrow shapes and push the central tile."..
		"\nYou can first target a Shuttle Mech to do the strike instantly."..
		"\nOtherwise, the strike is released just before the Vek act", --wait, it actually doesn't change anything then?
	aFM_icon = "img/modes/icon_napalm_airstrike.png",
	aFM_twoClick = true, --!!!!
	MinRange = 1,
	MaxRange = 3,
	FakeMark = "combat/icons/icon_napalm_airstrike.png",
}

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
    	--Fake damage (just for test)
    	local damage = SpaceDamage(p2, 0)
    	se:AddDamage(damage)
    else
		local damage = SpaceDamage(p2, 0)
		damage.sImageMark = self.FakeMark
    	se:AddDamage(damage)
    end
end

function truelch_NapalmAirstrikeMode:second_targeting(p1, p2) 
    local ret = PointList()

	for dir = DIR_START, DIR_END do
		for i = self.MinRange, self.MaxRange do
			local curr = p2 + DIR_VECTORS[dir]*i
			if not isShuttle(p2) or not Board:IsBlocked(curr, PATH_PROJECTILE) then
				ret:push_back(curr)
			end
		end
	end

    return ret
end

function truelch_NapalmAirstrikeMode:second_fire(p1, p2, p3)
    local ret = SkillEffect()

    local damage = SpaceDamage(p2, 0)    
    ret:AddArtillery(damage, self.UpShot, FULL_DELAY)

    local dir = GetDirection(p3 - p2)

    if IsTestMechScenario() then
    	computeNapalmAirstrike(ret, p2, dir, true)

    	--Center: no longer push, it's left and right
		--computeNapalmIcon(ret, p2, dir, true)
		local damage = SpaceDamage(p2, 0)
		damage.sImageMark = self.FakeMark
		ret:AddDamage(damage)

		--Fake marks (Forward, left, right)
		local dirOffsets = {0, -1, 1} 
		for _, offset in ipairs(dirOffsets) do
			local curr = p2 + DIR_VECTORS[(dir + offset)% 4]			
			if offset == 0 then
				local damage = SpaceDamage(curr, 0)
				damage.sImageMark = self.FakeMark
				ret:AddDamage(damage)
			else
				computeNapalmIcon(ret, curr, dir, true)
			end
		end    	

    	return ret
    end

    --Shuttle's move
    if isShuttle(p2) then
    	--Shuttle move
		local move = PointList()
		move:push_back(p2)
		move:push_back(p3)
		ret:AddBounce(p2, 2)
		ret:AddLeap(move, 0.25)

		--Instant damage effect
		--NEW: effect will be dealt just behind shuttle landing point
		local point = p3 - DIR_VECTORS[dir]*2
		computeNapalmAirstrike(ret, point, dir, false)
	else
		--Center
		--computeNapalmIcon(ret, p2, dir, true)
		local damage = SpaceDamage(p2, 0)
		damage.sImageMark = self.FakeMark
		ret:AddDamage(damage)

		--Fake marks (Forward, left, right)
		local dirOffsets = {0, -1, 1}
		for _, offset in ipairs(dirOffsets) do
			local curr = p2 + DIR_VECTORS[(dir + offset)% 4]
			if offset == 0 then
				local damage = SpaceDamage(curr, 0)
				damage.sImageMark = self.FakeMark
				ret:AddDamage(damage)
			else
				computeNapalmIcon(ret, curr, dir, true)
			end
		end

		--Add Airstrike
		ret:AddScript(string.format("truelch_MechDivers_AddAirstrike(%s, %s, 0)", p2:GetString(), tostring(dir)))
    end

    return ret
end

-------------------- MODE 11: Smoke Airstrike --------------------
truelch_SmokeAirstrikeMode = truelch_NapalmAirstrikeMode:new{
	aFM_name = "Smoke Airstrike",
	aFM_desc = "Smoke 4 tiles in an arrow shapes and push the central tile."..
		"\nYou can first target a Shuttle Mech to do the strike instantly."..
		"\nOtherwise, the strike is released just before the Vek act", --wait, it actually doesn't change anything then?
	aFM_icon = "img/modes/icon_smoke_airstrike.png",
	FakeMark = "combat/icons/icon_smoke_airstrike.png",
}

function truelch_SmokeAirstrikeMode:second_fire(p1, p2, p3)
    local ret = SkillEffect()

    local damage = SpaceDamage(p2, 0)    
    ret:AddArtillery(damage, self.UpShot, FULL_DELAY)

    local dir = GetDirection(p3 - p2)

    --Shuttle's move
    if isShuttle(p2) then
    	--Shuttle move
		local move = PointList()
		move:push_back(p2)
		move:push_back(p3)
		ret:AddBounce(p2, 2)
		ret:AddLeap(move, 0.25)

		--Instant damage effect
		--NEW: effect will be dealt just behind shuttle landing point
		local point = p3 - DIR_VECTORS[dir]*2
		computeSmokeAirstrike(ret, point, dir, false)
	else
		--Fake marks (Center)
		--computeSmokeIcon(ret, p2, dir, true)
		local damage = SpaceDamage(p2, 0)
		damage.sImageMark = self.FakeMark
		ret:AddDamage(damage)

		--Fake marks (Forward, left, right)
		local dirOffsets = {0, -1, 1} 
		for _, offset in ipairs(dirOffsets) do
			local curr = p2 + DIR_VECTORS[(dir + offset)% 4]
			if offset == 0 then
				local damage = SpaceDamage(curr, 0)
				damage.sImageMark = self.FakeMark
				ret:AddDamage(damage)
			else
				computeSmokeIcon(ret, curr, dir, true)
			end
		end

		--point, dir, id (1 = Smoke Airstrike)
		if IsTestMechScenario() then
			computeSmokeAirstrike(ret, p2, dir, true)
		else
			ret:AddScript(string.format("truelch_MechDivers_AddAirstrike(%s, %s, 1)", p2:GetString(), tostring(dir)))
		end
    end

    return ret
end

-------------------- MODE 12: 500kg Bomb Airstrike --------------------
truelch_500kgAirstrikeMode = truelch_NapalmAirstrikeMode:new{
	aFM_name = "500kg Bomb",
	aFM_desc = "Call-in for an airstrike, dropping a 500kg bomb on the targeted tile, dealing 4 damage in the center and 2 damage on adjacent tiles."..
		"\nYou can first target a Shuttle Mech to do the strike instantly."..
		"\nOtherwise, the strike is released just before the Vek act", --wait, it actually doesn't change anything then?
	aFM_icon = "img/modes/icon_500kg_airstrike.png",
	aFM_twoClick = true, --we actually need it for (potential) shuttle move. Maybe I can do a TC exception?
	MinRange = 1,
	MaxRange = 3,
}

--p2 was nil for mg43 so I'm taking safety measures here
function truelch_500kgAirstrikeMode:isTwoClickExc(p1, p2)
	return not isShuttle(truelch_strat_p2) or IsTestMechScenario() --p2 is nil...
end

--TC wasn't necessary
--Oh, it was, for the shuttle move!
--Maybe I should write a TC exception for the case we don't target shuttle at p2
function truelch_500kgAirstrikeMode:fire(p1, p2, se)
    local damage = SpaceDamage(p2, 0)
    se:AddArtillery(damage, self.UpShot, FULL_DELAY)

	if isShuttle(p2) then
    	local damage = SpaceDamage(p2, 0)
    	se:AddDamage(damage)
    else
    	--Let's do the final effect here since we are in a TC exception here...

    	--For 500kg, fake marks don't work in test mech scenario for some reason, so I'm adding them in the compute 500kg airstrike
    	--(yes I've tried putting the compute after and before the fake marks, didn't changed a thing)

    	--Fake Mark (Center)
		local damage = SpaceDamage(p2, 0)
		damage.sImageMark = "combat/icons/icon_500kg_inner.png"
    	se:AddDamage(damage)

		--Fake Mark (Outer)
		for dir = DIR_START, DIR_END do
			local curr = p2 + DIR_VECTORS[dir]
			local damage = SpaceDamage(curr, 0)
			damage.sImageMark = "combat/icons/icon_500kg_outer.png"
			se:AddDamage(damage)
		end

	    if IsTestMechScenario() then
			compute500KgAirstrike(se, p2, true)
		else
			se:AddScript(string.format("truelch_MechDivers_AddAirstrike(%s, -1, 2)", p2:GetString()))
		end
    end
end

function truelch_500kgAirstrikeMode:second_targeting(p1, p2)
    local ret = PointList()

	for dir = DIR_START, DIR_END do
		for i = self.MinRange, self.MaxRange do
			local curr = p2 + DIR_VECTORS[dir]*i
			if not isShuttle(p2) or not Board:IsBlocked(curr, PATH_PROJECTILE) then
				ret:push_back(curr)
			end
		end
	end

    return ret
end

function truelch_500kgAirstrikeMode:second_fire(p1, p2, p3)
    local ret = SkillEffect()

	local damage = SpaceDamage(p2, 0)    
    ret:AddArtillery(damage, self.UpShot, FULL_DELAY)

    local dir = GetDirection(p3 - p2)

    --Shuttle's move
    if isShuttle(p2) then
    	--Shuttle move
		local move = PointList()
		move:push_back(p2)
		move:push_back(p3)
		ret:AddBounce(p2, 2)
		ret:AddLeap(move, 0.25)

		--NEW: effect will be dealt just behind shuttle landing point
		local point = p3 - DIR_VECTORS[dir]*2
		compute500KgAirstrike(ret, point, false)
    end

    return ret
end



---------------------------------------------------------
-------------------- ORBITAL STRIKES --------------------
---------------------------------------------------------
--Orbital strikes effects will happen AFTER Vek act.

-------------------- MODE 13: Orbital Precision Strike --------------------
truelch_OrbitalPrecisionStrikeMode = truelch_NapalmAirstrikeMode:new{
	aFM_name = "Orbital Precision Strike",
	aFM_desc = "Command a precision orbital strike that'll kill anything below."..
		"\nOrbital strikes happen after enemy turn, so you'll need to anticipate enemies' movement!",
	aFM_icon = "img/modes/icon_orbital_precision_strike.png",
	aFM_twoClick = false,
}

function truelch_OrbitalPrecisionStrikeMode:fire(p1, p2, se)
	local damage = SpaceDamage(p2, 0)    
    se:AddArtillery(damage, self.UpShot, FULL_DELAY)

	--Fake Mark
	local damage = SpaceDamage(p2, 0)
	damage.sImageMark = "combat/icons/icon_orbital_precision_strike.png"
	se:AddDamage(damage)

	if IsTestMechScenario() then
		se:AddScript(string.format("computeOrbitalPrecisionStrike(%s)", p2:GetString()))
		se:AddScript(string.format([[Board:AddAlert(%s, "After queued actions")]], p1:GetString()))
		return
	end

	--dir might not be used
	--point, dir, id
	se:AddScript(string.format("truelch_MechDivers_AddOrbitalStrike(%s, -1, 0)", p2:GetString()))
end

-------------------- MODE 14: Orbital Walking Barrage --------------------
truelch_OrbitalWalkingBarrageMode = truelch_NapalmAirstrikeMode:new{
	aFM_name = "Orbital Walking Barrage",
	aFM_desc = "Target a point and a direction for salvos that will be fired from space, dealing 2 damage to the tile and the next one."..
		"\nEvery turn, it'll move forward by one tile, until it detects a building."..
		"\nOrbital strikes happen after enemy turn, so you'll need to anticipate enemies' movement!",
	aFM_icon = "img/modes/icon_orbital_walking_barrage.png",
}

function truelch_OrbitalWalkingBarrageMode:fire(p1, p2, se)
	local damage = SpaceDamage(p2, 0)    
    se:AddArtillery(damage, self.UpShot, FULL_DELAY)

	--Fake Mark
	local damage = SpaceDamage(p2, 0)
	damage.sImageMark = "combat/icons/icon_orbital_walking_barrage.png"
	se:AddDamage(damage)
end

function truelch_OrbitalWalkingBarrageMode:second_targeting(p1, p2)
    local ret = PointList()

	for dir = DIR_START, DIR_END do
		ret:push_back(p2 + DIR_VECTORS[dir])
	end

    return ret
end

function truelch_OrbitalWalkingBarrageMode:second_fire(p1, p2, p3)
    local ret = SkillEffect()
    local dir = GetDirection(p3 - p2)

	local damage = SpaceDamage(p2 + DIR_VECTORS[dir], 0)
	damage.sImageMark = "combat/icons/icon_orbital_walking_barrage_end_"..tostring(dir)..".png"
	ret:AddDamage(damage)

	local damage = SpaceDamage(p2, 0)
	damage.sImageMark = "combat/icons/icon_orbital_walking_barrage_start_"..tostring(dir)..".png"
    ret:AddArtillery(damage, self.UpShot, FULL_DELAY)

    if IsTestMechScenario() then
		ret:AddScript(string.format("computeOrbitalWalkingBarrage(%s, %s)", p2:GetString(), tostring(dir)))
		ret:AddScript(string.format([[Board:AddAlert(%s, "After queued actions")]], p1:GetString()))
		return ret
	end

    ret:AddScript(string.format("truelch_MechDivers_AddOrbitalStrike(%s, %s, 1)", p2:GetString(), tostring(dir)))

    return ret
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
		"\nIf you have a Shuttle Mech in range, the call-in can be instant. (airstrikes and weapons drops)"..
		"\nYou can store up to 2 stratagems max.",
	Class = "",
	TwoClick = true, --!!!!
	Rarity = 1,
	PowerCost = 0,
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
		"truelch_GuardDogLaserMode", --New!

		--Air strikes
		"truelch_NapalmAirstrikeMode",
		"truelch_SmokeAirstrikeMode",
		"truelch_500kgAirstrikeMode",

		--Orbital strikes
		"truelch_OrbitalPrecisionStrikeMode",
		"truelch_OrbitalWalkingBarrageMode", --New!
	},
	aFM_ModeSwitchDesc = "Click to change mode.",

	--Upgrades
	Upgrades = 1,
	UpgradeCost = { 1 --[[, 3]] },

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
	UpgradeDescription = "+1 stratagem acquired at the start of each mission.\nYou can store all the possible stratagems.",
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
    
	--Okay this is very experimental
	--Oh it actually causes sometimes a little error at the beginning of a game
	--This function is called just at the start of the player's turn
	local isOk = true
	if Pawn == nil then
		isOk = false
	else
		isOk = Pawn:GetId() <= 2 --respawned mechs aren't allowed to use stratagems!
	end

	if self:FM_CurrentModeReady(point) and isOk then
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

	local p1 = Point(2, 1)
	local p2 = Point(2, 3)

	if self.TipIndex == 0 then
		self.TipIndex = 1
		local pawn = Board:GetPawn(Point(2, 3))
		if pawn ~= nil then
			pawn:SetSpace(Point(2, 1))
		end
    	local damage = SpaceDamage(p2, 0)
    	--damage.sImageMark = "combat/blue_stratagem_grenade.png" --doesn't show up in the tip image
	    ret:AddArtillery(p1, damage, "effects/truelch_shotup_stratagem_ball.png", FULL_DELAY)    
	    local dropAnim = SpaceDamage(p2, 0)
	    dropAnim.sAnimation = "truelch_anim_pod_land_2"
	    ret:AddDamage(dropAnim)

        ret:AddScript("Board:StartShake(0.5)")

        --No sound in tip image anyway
	    --local sfx = SpaceDamage(p2, 0)
	    --sfx.sSound = "/mech/land"
	    --ret:AddDamage(sfx)

	    --Dust
	    for dir = DIR_START, DIR_END do
	        local curr = p2 + DIR_VECTORS[dir]
	        local dust = SpaceDamage(curr, 0)
	        dust.sAnimation = "airpush_"..dir
	        ret:AddDamage(dust)
	    end
	elseif self.TipIndex == 1 then
		self.TipIndex = 2
		Board:SetItem(p2, "truelch_Item_WeaponPod_Mg43")
		ret:AddMove(Board:GetPath(p1, Point(2, 3), PATH_GROUND), FULL_DELAY)
	elseif self.TipIndex == 2 then
		self.TipIndex = 0
		local pawn = Board:GetPawn(Point(2, 1))
		if pawn ~= nil then
			pawn:SetSpace(Point(2, 3))
		else
			--LOG("------------- pawn is nil!!")
		end

		Board:AddAlert(Point(2, 3), "WEAPON ACQUIRED") --I want to make this happen AFTER move.
	end

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
	if not Board:IsTipImage() then
		return self:GetSkillEffect_Normal(p1, p2)
	else
		return self:GetSkillEffect_TipImage()
	end
end

function truelch_StratagemFMW:IsTwoClickException(p1, p2)
	--WHY WHY WHY WHY WHY
	truelch_strat_p1 = p1
	truelch_strat_p2 = p2

	if _G[self:FM_GetMode(p1)].isTwoClickExc then
		return _G[self:FM_GetMode(p1)].isTwoClickExc(p1, p2)
	else
		return not _G[self:FM_GetMode(p1)].aFM_twoClick
	end
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
		return self:GetFinalEffect_TipImage()
	end
end


----------------------------------------------- HOOKS / EVENTS SUBSCRIPTION -----------------------------------------------

--TODO: final mission second phase
local HOOK_onMissionStarted = function(mission)
	--LOG("truelch_StratagemFMW -> HOOK_onMissionStarted")
	truelch_stratagem_flag = true
end

local function computeStratagems()
	local size = Board:GetSize()
	for j = 0, size.y do
		for i = 0, size.x do
			local pawn = Board:GetPawn(Point(i, j))
			if pawn ~= nil and pawn:IsMech() then
				local weapons = pawn:GetPoweredWeapons()
				local p = pawn:GetId()
				for weaponIdx = 1, 3 do
					local fmw = truelch_divers_fmwApi:GetSkill(p, weaponIdx, false)
					if fmw ~= nil then
						local weapon = weapons[weaponIdx]
						if type(weapon) == 'table' then
							weapon = weapon.__Id
						end

						if isStratagemWeapon(weapon) then
							local currAmount = 0 --new!
							local list = {}
							--LOG(" --------- StratagemFMW found! Mode list:")
							for k, mode in pairs(_G[weapon].aFM_ModeList) do
								--LOG(string.format("k: %s, mode: %s", tostring(k), tostring(mode)))
								if gameData().stratagems[p] ~= nil and list_contains(gameData().stratagems[p], mode) then
									--LOG(" -> This is an active mode in the game data!")
									fmw:FM_SetActive(p, mode, true)
									currAmount = currAmount + 1
								else
									fmw:FM_SetActive(p, mode, false)
									table.insert(list, {mode, k})
								end
							end

							--LOG("currAmount: "..tostring(currAmount))

							local max = truelch_max_strat --new!
							local stratIncr = 1 --amount of Stratagem modes added at the start of the mission (+2 with an upgrade)
							if weapon == "truelch_StratagemFMW_A" or weapon == "truelch_StratagemFMW_AB" then
								stratIncr = 2
								max = 14
							end

							for i = 1, stratIncr do
								--TODO: check if the list count > 0
								--TODO: max amount of stratagems
								--LOG("i: "..tostring(i).." / stratIncr: "..tostring(stratIncr)..", list size: "..tostring(#list))

								--LOG("currAmount: "..tostring(currAmount).." / max: "..tostring(max))

								if #list >= 1 and currAmount < max then
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

									currAmount = currAmount + 1
								else
									LOG("Cannot add more stratagems!")
								end
							end

							--Board:AddAlert(pawn:GetSpace(), tostring(truelch_statagemNames[index]).." added")
						end
					end
				end
			end
		end
	end
end

local testMode = false

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
    if alpha >= 1 then
    	alpha = 1
    	incr = -0.01
    elseif alpha <= 0 then
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
			local dir = orbitalStrike[2] --not used (actually, it is!)
			local id = orbitalStrike[3]

			if id == 0 then
				--Orbital precision strike
				Board:MarkSpaceImage(point, "combat/tile_icon/tile_truelch_orbital_precision_strike.png", GL_Color(255, 180, 0, 0.75))
				Board:MarkSpaceDesc(point, "orbital_precision_strike")
			elseif id == 1 then
				--Orbital walking barrage
				Board:MarkSpaceImage(point, "combat/tile_icon/tile_truelch_orbital_walking_barrage_"..tostring(dir)..".png", GL_Color(255, 180, 0, 0.75))
				Board:MarkSpaceDesc(point, "orbital_walking_barrage")

				Board:MarkSpaceImage(point + DIR_VECTORS[dir], "combat/tile_icon/tile_truelch_orbital_walking_barrage_"..tostring(dir)..".png", GL_Color(255, 180, 0, 0.75))
				Board:MarkSpaceDesc(point + DIR_VECTORS[dir], "orbital_walking_barrage")
			end
		end
end

local function debugGameData()
	for i, stratagem in pairs(gameData().stratagems) do
		LOG(string.format("stratagem[%s]: %s", tostring(i), tostring(stratagem[i])))
	end
end

local function computeStratagemAfterUse(pawn, weaponId)
    if type(weaponId) == 'table' then weaponId = weaponId.__Id end

    if pawn == nil then return end
    local p = pawn:GetId() --happened to be nil at some point
    local weapons = pawn:GetPoweredWeapons()
    local fmw
    for weaponIdx = 1, 3 do
    	local fmw = truelch_divers_fmwApi:GetSkill(p, weaponIdx, false)
    	weapon = weapons[weaponIdx]
    	if fmw ~= nil and isStratagemWeapon(weaponId) and weapon == weaponId then
    		local mode = fmw:FM_GetMode(p)
    		for i, stratagem in pairs(gameData().stratagems) do
				if stratagem[i] == mode then
    				table.remove(gameData().stratagems[p], i)
    			end
			end
    	end
	end
end

local HOOK_onSkillEnd = function(mission, pawn, weaponId, p1, p2)
	computeStratagemAfterUse(pawn, weaponId)
end

local HOOK_onFinalEffectEnd = function(mission, pawn, weaponId, p1, p2, p3)
	computeStratagemAfterUse(pawn, weaponId)
end

local function EVENT_onModsLoaded()
    modApi:addMissionStartHook(HOOK_onMissionStarted)
    modApi:addNextTurnHook(HOOK_onNextTurn)
    modApi:addPreEnvironmentHook(HOOK_onPreEnv)
    modApi:addMissionUpdateHook(HOOK_onMissionUpdate)
    modapiext:addSkillEndHook(HOOK_onSkillEnd)
    modapiext:addFinalEffectEndHook(HOOK_onFinalEffectEnd)
end

modApi.events.onModsLoaded:subscribe(EVENT_onModsLoaded)

modApi.events.onTestMechEntered:subscribe(function()
	modApi:runLater(function() --why was it necessary? But I 
		local pawn = false
			or Game:GetPawn(0)
			or Game:GetPawn(1)
			or Game:GetPawn(2)

		--I didn't even know IsWeaponEquipped was a thing. That'd simplify stuff on my other mods...
		local points = {}
		if pawn and pawn:IsWeaponEquipped("truelch_StratagemFMW") then
			for j = 0, 7 do
				for i = 0, 7 do
					local curr = Point(i, j)
					if not Board:IsBlocked(curr, PATH_PROJECTILE) then
						points[#points + 1] = curr
						break
					end
				end
			end
		end

		if #points > 0 then
			local spawn = SpaceDamage(points[math.random(1, #points)], 0)
			spawn.sPawn = "truelch_TestScenarioPawn"
			--spawn.sPawn = "truelch_EagleMech" --so that the player can also test shuttle-compatible skills (cause error with FMW resulting in not being able to change delivery mode)
			Board:AddEffect(spawn)
		end
	end)
end)


return this