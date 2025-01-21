-------------------- IMPORTS --------------------

local this = {}
local mod = mod_loader.mods[modApi.currentMod]
local scriptPath = mod.scriptPath
local resourcePath = mod.resourcePath


-------------------- MODE 1: MINIGUN --------------------

--Can KO efffects work with FMW?
--OnKill = "Brute_KO_Combo_OnKill",

truelch_PatriotWeaponsMode1 = {
	aFM_name = "Minigun",
	aFM_desc = "Shoot a projectile that deals damage equal to health lost by the target + 1."..
		"\nIf it kills it, shoot a projectile from the dead unit that pushes and deal damage equal to excess damage."..
		"\nOtherwise, the projectile pushes.",
	aFM_icon = "img/modes/icon_minigun.png",

	ProjectileArt = "effects/shot_mechtank",
	BaseDamage = 0,
}

CreateClass(truelch_PatriotWeaponsMode1)

function truelch_PatriotWeaponsMode1:targeting(point)
	local points = {}

	for dir = DIR_START, DIR_END do
		for i = 1, 7 do
			local curr = DIR_VECTORS[dir]*i + point
			points[#points+1] = curr
			if not Board:IsValid(curr) or Board:IsBlocked(curr, PATH_PROJECTILE) then
				break
			end
		end
	end

	return points
end

function truelch_PatriotWeaponsMode1:fire(p1, p2, se, betterKO)
	local direction = GetDirection(p2 - p1)

	local target = GetProjectileEnd(p1, p2, PATH_PROJECTILE)

	local damage = self.BaseDamage
	local pawn = Board:GetPawn(target)
	if pawn ~= nil then
		damage = damage + pawn:GetMaxHealth() - pawn:GetHealth()
	end

	local spaceDamage = SpaceDamage(target, damage)

	if Board:IsDeadly(spaceDamage, Pawn) and betterKO then
		se:AddProjectile(spaceDamage, self.ProjectileArt)
		local target2 = GetProjectileEnd(target, target + DIR_VECTORS[direction], PATH_PROJECTILE)
		local excessDamage = damage

		--local debugStr = "[A] excessDamage: "..tostring(excessDamage)

		local deadPawn = Board:GetPawn(target)
		if deadPawn ~= nil then
			--I hope I'm making a reliable damage calculator
			if deadPawn:IsShield() or deadPawn:IsFrozen() then --Shouldn't trigger IsDeadly then?
				LOG("--------- WTF? shield or frozen")
				excessDamage = 0
			elseif deadPawn:IsAcid() then
				excessDamage = damage * 2 --effective damage
			elseif deadPawn:IsArmor() then
				excessDamage = damage - 1
			end

			--debugStr = debugStr.."\n[B] excessDamage: "..tostring(excessDamage)

			--Subtract health
			excessDamage = excessDamage - deadPawn:GetHealth()
			if excessDamage < 0 then --equal 0 is fine since it creates a pushing projectile
				LOG("--------- Shouldn't happen")
				--debugStr = debugStr.."\n[C] excessDamage: "..tostring(excessDamage)..", deadPawn:GetHealth(): "..tostring(deadPawn:GetHealth())
				--LOG(debugStr)
				return
			end

			local sd2 = SpaceDamage(target2, excessDamage)
			sd2.iPush = direction

			se:AddProjectile(target, sd2, self.ProjectileArt, FULL_DELAY)
		end
	else --test
		spaceDamage.iPush = direction
		se:AddProjectile(spaceDamage, self.ProjectileArt--[[, FULL_DELAY]])
	end
end


-------------------- MODE 2: ROCKET POD --------------------

--Should it be able to hit before the target end? Or behave like a projectile, just diagonally?
truelch_PatriotWeaponsMode2 = truelch_PatriotWeaponsMode1:new{
	aFM_name = "Rocket pod",
	aFM_desc = "Shoot a powerful rocket diagonally that deals 3 damage to the first obstable. Deal 1 damage to adjacent tiles if the target unit dies.",
	aFM_icon = "img/modes/icon_rocket_pod.png",
	aFM_limited = 1,
	--Wait, what does that mean (below)
	--aFM_handleLimited = false-- optional (FMW will no longer automatically handle uses for this mode if set)

	UpShot = "effects/shotup_missileswarm.png", --tmp
	MaxRange = 7, --3 (real projectile behaviour, just diagonal)
}

function truelch_PatriotWeaponsMode2:getProjEnd(point, diagDir)	
	local curr = point
	for range = 1, self.MaxRange do
		local testPoint = diagDir*range + point
		if Board:IsValid(diagDir*range + point) then
    		curr = testPoint
    	end
		if not Board:IsValid(testPoint) or Board:IsBlocked(testPoint, PATH_PROJECTILE) then
			break
		end
    end

    return curr
end

function truelch_PatriotWeaponsMode2:targeting(point)
	local points = {}
	local offsets = { Point(-1, -1), Point(-1, 1), Point(1, -1), Point(1, 1) }

	--[[
	for range = 1, self.MaxRange do
        for _, offset in pairs(offsets) do
        	local curr = offset*range + point
        	points[#points+1] = curr
        end
	end
	]]

	--Show directly projectile end
	--[[
    for _, offset in pairs(offsets) do
    	local projEnd = self:getProjEnd(point, offset)
    	points[#points+1] = projEnd
    end
    ]]

    --Actually, show it like a regular projectile
    --(is still different than the first version, because the first version would actually add all tiles regardless of obstacles)
    for _, offset in pairs(offsets) do
		for range = 1, self.MaxRange do
        	local curr = offset*range + point
        	points[#points+1] = curr
        	if not Board:IsValid(curr) or Board:IsBlocked(curr, PATH_PROJECTILE) then
        		break
        	end
        end
	end

	return points
end

function truelch_PatriotWeaponsMode2:fire(p1, p2, se, betterKO)
	--Compute offset
	local diff = p2 - p1

	local offset = Point(0, 0)
	if     diff.x > 0 and diff.y > 0 then offset = Point( 1,  1)
	elseif diff.x > 0 and diff.y < 0 then offset = Point( 1, -1)
	elseif diff.x < 0 and diff.y > 0 then offset = Point(-1,  1)
	elseif diff.x < 0 and diff.y < 0 then offset = Point(-1, -1)
	end

	if offset ~= Point(0, 0) then
		local endProj = self:getProjEnd(p1, offset)
		--LOG("endProj: "..endProj:GetString())
	    local spaceDamage = SpaceDamage(endProj, 3)
	    se:AddArtillery(spaceDamage, self.UpShot)
	    if Board:IsDeadly(spaceDamage, Pawn) and betterKO then
		    for dir = DIR_START, DIR_END do
		    	local curr = endProj + DIR_VECTORS[dir]
		    	local pawn = Board:GetPawn(curr)
		    	if pawn ~= nil then
		    		local aoeDamage = SpaceDamage(curr, 1)
		    		se:AddDamage(aoeDamage)
		    	end
		    end
		end
	else
		LOG("Patriot's rocket weapon: unexpected p2!")
	end
end


-------------------- WEAPON --------------------

truelch_PatriotWeapons = aFM_WeaponTemplate:new{
	Name = "Patriot's weapons",
	--[[
	Description = "Two fire modes:"..
		"\n\nMinigun: shoot a projectile dealing more damage to damaged units and that can pierce through its target if it kills it."..
		"\n\nRocket pod: shoot a powerful rocket diagonally."..
		"\n\n(more details on the modes buttons' descriptions)",
	]]
	Description = "Shoot a pushing projectile that deals additional damage equal to the target's health lost.",
	Class = "Prime",
	Icon = "weapons/truelch_patriot_weapons.png",
	Rarity = 1,
	PowerCost = 1,

	--KO
	OnKill = "(Upgrade)",

	--Artillery Arc
	ArtilleryHeight = 0,

	LaunchSound = "/weapons/bomb_strafe",

	--FMW
	aFM_ModeList = { "truelch_PatriotWeaponsMode1", "truelch_PatriotWeaponsMode2" },
	aFM_ModeSwitchDesc = "Click to change mode.",

	--Upgrades
	Upgrades = 1,
	UpgradeCost = { 1 },
	RocketEnabled = true, --just for custom tip
	BetterOnKill = false,

	--Tip image
	PatriotTipIndex = 1, --this works, unlike using a variable from outside. Why? I HAVE NO IDEA	
	TipImage = {
		Unit          = Point(2, 3),
		Target        = Point(2, 2),
		--Enemy_Damaged = Point(2, 2), --this works, but it displays a dead vek (dead anim playing at the very start)
		CustomEnemy   = "Firefly1",

		--Minigun
		Enemy         = Point(2, 2),
		Enemy2        = Point(2, 1),

		--Rocket
		Enemy3        = Point(0, 1),
		Enemy4        = Point(3, 2),

		Second_Target = Point(2, 2),
		Second_Origin = Point(2, 3),

		CustomPawn = "truelch_PatriotMech",
	}
}

Weapon_Texts.truelch_PatriotWeapons_Upgrade1 = "KO Effect"
--Weapon_Texts.truelch_PatriotWeapons_Upgrade2 = "Enable Rockets" --not sure about this
--Weapon_Texts.truelch_PatriotWeapons_Upgrade2 = "+1 Damage" --MAYBE???? (on damage. ALL)

truelch_PatriotWeapons_A = truelch_PatriotWeapons:new{
    UpgradeDescription = "Enables an effect when the primary target dies."..
    	"\nGatling: shoots another projectile."..
    	"\nRocket: damage adjacent units.",
    BetterOnKill = true,
}

--[[
truelch_PatriotWeapons_B = truelch_PatriotWeapons:new{
    UpgradeDescription = "Allow to use a secondary weapon: the rockets."..
    	"\nIt shoots a diagonal projectile that deals 3 damage to its target."..
    	"\nIf it kills its target, all adjacent tiles take 1 damage.",
    aFM_ModeList = { "truelch_PatriotWeaponsMode1", "truelch_PatriotWeaponsMode2" },    
    RocketEnabled = true, --just for tip
}


truelch_PatriotWeapons_AB = truelch_PatriotWeapons:new{
    aFM_ModeList = { "truelch_PatriotWeaponsMode1", "truelch_PatriotWeaponsMode2" },
    RocketEnabled = true, --just for tip
    BetterOnKill = true,
}
]]

-------------------- GET TARGET AREA --------------------

function truelch_PatriotWeapons:GetTargetArea_TipImage(point)
	local pl = PointList()
	local points = {}

	for j = 0, 7 do
		for i = 0, 7 do
			p = Point(i, j)
			pl:push_back(p)
		end
	end

	return pl
end

function truelch_PatriotWeapons:GetTargetArea_Normal(point)
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

function truelch_PatriotWeapons:GetTargetArea(point)
	if not Board:IsTipImage() then
		return self:GetTargetArea_Normal(point)
	else
		return self:GetTargetArea_TipImage(point)
	end
end

-------------------- GET SKILL EFFECT --------------------

function truelch_PatriotWeapons:GetSkillEffect_TipImage(p1, p2)
	local se = SkillEffect()

	if self.PatriotTipIndex == 1 then
		Board:AddAlert(Point(2, 3), "Minigun")		
	elseif self.PatriotTipIndex == 3 then
		Board:AddAlert(Point(2, 3), "Rocket Pod")
	end

	if self.PatriotTipIndex <= 2 then
		truelch_PatriotWeaponsMode1:fire(p1, p2, se, self.BetterOnKill)
	else
		if self.PatriotTipIndex == 3 then
			p2 = Point(0, 1)
		else
			p2 = Point(3, 2)
		end

		truelch_PatriotWeaponsMode2:fire(p1, p2, se, self.BetterOnKill)
	end

	self.PatriotTipIndex = self.PatriotTipIndex + 1

	if self.PatriotTipIndex > 4 or (not self.RocketEnabled and self.PatriotTipIndex > 2) then
		self.PatriotTipIndex = 1
	end

	return se
end

function truelch_PatriotWeapons:GetSkillEffect_Normal(p1, p2)
	local se = SkillEffect()
	local currentMode = self:FM_GetMode(p1)
	
	if self:FM_CurrentModeReady(p1) then
		_G[currentMode]:fire(p1, p2, se, self.BetterOnKill)
	end

	return se
end

function truelch_PatriotWeapons:GetSkillEffect(p1, p2)
	if not Board:IsTipImage() then
		return self:GetSkillEffect_Normal(p1, p2)
	else
		return self:GetSkillEffect_TipImage(p1, p2)
	end
end

return this