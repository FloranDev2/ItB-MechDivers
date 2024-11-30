--[[
Another possibility would be to have a FMWeapon that allow to either shoot left or right or both!
Each side would only have 2 ammo.
]]



truelch_EmancipatorWeapons = Skill:new{
	--Infos
	Name = "Dual autocannons",
	Description = "Shoot 2 pushing projectiles from either sides. If the target is at a distance of 2 or less, the projectile deal 1 damage.",
	Class = "Prime",
	PowerCost = 0,

	--Art
	Icon = "weapons/brute_tankmech.png",
	UpShot = "effects/shotup_ignite_fireball.png",
	Explosion = "explopush2_",
	Sound = "/general/combat/explode_small",
	LaunchSound = "/weapons/modified_cannons",
	ImpactSound = "/impact/generic/explosion",

	--Artillery arc
	ArtilleryHeight = 0,

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
	}
}


function truelch_EmancipatorWeapons:GetTargetArea(point)
	local ret = PointList()

	for dir = DIR_START, DIR_END do
		for i = 1, 7 do
			local curr = Point(point + DIR_VECTORS[dir] * i)
			if Board:IsValid(curr) then
				ret:push_back(curr)
			else
				break
			end
		end
	end

	return ret
end


function truelch_EmancipatorWeapons:AutocannonShot(ret, point, direction)
	damage = 1
	local projEnd = GetProjectileEnd(point, point + DIR_VECTORS[direction], PATH_PROJECTILE)

	local dist = point:Manhattan(projEnd)

	LOG("point: "..point:GetString()..", projEnd: "..projEnd:GetString().." -> dist: " ..tostring(dist))

	local spaceDamage = SpaceDamage(projEnd, damage--[[, direction]])
	spaceDamage.sAnimation = self.Explosion..direction
	spaceDamage.sImageMark = "combat/icons/icon_resupply.png"
	ret:AddArtillery(spaceDamage, self.UpShot)
end


function truelch_EmancipatorWeapons:GetSkillEffect(p1, p2)
	local ret = SkillEffect()

	local direction = GetDirection(p2 - p1)
	ret:AddBounce(p1, 1)

	--LEFT
	local point = p2 - DIR_VECTORS[(direction + 1)% 4]
	self:AutocannonShot(ret, point, direction)

	--RIGHT
	local point = p2 + DIR_VECTORS[(direction + 1)% 4]
	self:AutocannonShot(ret, point, direction)
	
	return ret
end
