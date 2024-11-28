truelch_TestWeapon = Skill:new{
	--Infos
	Name = "Test Weapon",
	Description = "DEMOCRACY.",
	Class = "Any",
	Icon = "weapons/brute_tankmech.png",

	--Shop
	Rarity = 1,
	PowerCost = 0,

	--Upgrades
	--Upgrades = 2,
	--UpgradeCost = { 1, 2 },

	--Gameplay
	Damage = 3,

	--Tip image
	--[[
	TipImage = {
		Unit   = Point(2, 2),
		Enemy  = Point(2, 1),
		Enemy2 = Point(1, 1),
		Target = Point(2, 1),
		CustomPawn = "truelch_BurrowerMech",

        Second_Origin = Point(2, 2),
        Second_Target = Point(3, 2),
        Building = Point(3, 2),
        Enemy3 = Point(3, 3),
	}
	]]
}

function truelch_TestWeapon:GetTargetArea(point)
	local ret = PointList()

	for j = 0, 7 do
		for i = 0, 7 do
			local curr = Point(i, j)
			ret:push_back(curr)
		end
	end
	
	return ret
end

function truelch_TestWeapon:GetSkillEffect(p1, p2)
	local ret = SkillEffect()

	local damage = SpaceDamage(p2, self.Damage)
	--damage.iCrack = EFFECT_CREATE
	ret:AddDamage(damage)

	--[[
	local damage = SpaceDamage(p2, self.Damage)
	damage.iCrack = EFFECT_CREATE
	ret:AddDamage(damage)
	]]


	return ret
end