--[[
Another possibility would be to have a FMWeapon that allow to either shoot left or right or both!
Each side would only have 2 ammo.
]]



truelch_EmancipatorWeapons = Skill:new{
	--Infos
	Name = "Dual autocannons",
	Description = "Shoot 2 pushing projectiles from either sides or just to one side. If the target is 2 tiles away or less, the projectile deal 1 damage.",
	Class = "Prime",
	PowerCost = 0,

	--Art
	Icon = "weapons/truelch_dual_autocannon.png",
	ShortRangeProjectileArt = "effects/shot_mechtank", --damage
	LongRangeProjectileArt = "effects/shot_mechtank", --harmless
	Explosion = "explopush2_",
	Sound = "/general/combat/explode_small", --what is this?
	LaunchSound = "/weapons/modified_cannons",
	ImpactSound = "/impact/generic/explosion", --differentiate short and long range sounds? and make a delay between each shot?

	--Artillery arc
	--UpShot = "effects/shotup_ignite_fireball.png",
	--ArtilleryHeight = 0, --this might be what caused the projectile to crash the game

	--Gameplay
	ShortRangeDamage = 1,
	LongRangeDamage = 0,
	RangeThreshold = 2,

	--Tip image
	TipImage = {
		Unit   = Point(2, 4),
		Target = Point(2, 2),
		Enemy  = Point(1, 3),
		Enemy2 = Point(3, 1),
		CustomPawn = "truelch_EmancipatorMech",
	}
}


function truelch_EmancipatorWeapons:GetTargetArea(point)
	local ret = PointList()

	--LOG("truelch_EmancipatorWeapons:GetTargetArea(point: "..point:GetString()..")")

	for dir = DIR_START, DIR_END do
		for i = 1, 7 do
			local curr = Point(point + DIR_VECTORS[dir] * i)
			if Board:IsValid(curr) then
				ret:push_back(curr)
				--LOG(" ---------> add: "..curr:GetString())
			else
				break
			end

			--Add sides! (to only shoot sideways if the player want)
			--[[
			if i > 1 then
				--LEFT
				local left = curr - DIR_VECTORS[(dir + 1)% 4]
				if Board:IsValid(left) then
					ret:push_back(left)
				end

				--RIGHT
				local right = curr + DIR_VECTORS[(dir + 1)% 4]
				if Board:IsValid(right) then
					ret:push_back(right)
				end
			end
			]]
		end
	end

	--LOG("truelch_EmancipatorWeapons:GetTargetArea ---- END")

	return ret
end


function truelch_EmancipatorWeapons:AutocannonShot(ret, point, direction)
	local target = GetProjectileEnd(point, point + DIR_VECTORS[direction], PATH_PROJECTILE)
	local dist = point:Manhattan(target)

	--Flat artillery shot doesn't look that great at short range
	--Plus, it sometimes bugs and don't have a flat arc at all, which is way worse
	local damage = self.ShortRangeDamage
	if dist > self.RangeThreshold then
		damage = self.LongRangeDamage
	end

	--[[
	local spaceDamage = SpaceDamage(target, damage, direction)
	spaceDamage.sAnimation = self.Explosion..direction
	ret:AddArtillery(spaceDamage, self.UpShot)
	]]

	if dist <= self.RangeThreshold then
		--Short range shot
		local damage = SpaceDamage(target, self.ShortRangeDamage, direction)
		ret:AddProjectile(damage, self.ShortRangeProjectileArt)
	else		
		--Long range shot
		local damage = SpaceDamage(target, self.LongRangeDamage, direction)
		ret:AddProjectile(damage, self.LongRangeProjectileArt)
	end
end

--[[
    local ret = SkillEffect()
    local direction = GetDirection(p2 - p1)            
    local target = GetProjectileEnd(p1, p2)
    damage = SpaceDamage(target, self.Damage, direction)
    ret:AddProjectile(damage, self.Projectile)   
]]


function truelch_EmancipatorWeapons:GetSkillEffect(p1, p2)
	LOG("truelch_EmancipatorWeapons:GetSkillEffect(p1, p2)")
	local ret = SkillEffect()

	local direction = GetDirection(p2 - p1)
	ret:AddBounce(p1, 1)

	--LEFT
	local point = p1 - DIR_VECTORS[(direction + 1)% 4]
	self:AutocannonShot(ret, point, direction)

	--RIGHT
	local point = p1 + DIR_VECTORS[(direction + 1)% 4]
	self:AutocannonShot(ret, point, direction)
	
	return ret
end
