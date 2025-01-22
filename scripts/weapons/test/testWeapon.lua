truelch_TestWeapon = Skill:new{
	--Infos
	Name = "NIK",
	Description = "TAMER",
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

	--[[
	for j = 0, 7 do
		for i = 0, 7 do
			local curr = Point(i, j)
			ret:push_back(curr)
		end
	end
	]]

	for dir = DIR_START, DIR_END do
		for i = 1, 7 do
			local curr = point + DIR_VECTORS[dir]*i
			ret:push_back(curr)
		end
	end
	
	return ret
end

function truelch_TestWeapon:GetSkillEffect(p1, p2)
	local ret = SkillEffect()

	--Just to show bunch of damage
	--[[
	local dmg = 0
	for j = 0, 7 do
		for i = 0, 7 do
			local curr = Point(i, j)

			--Test mark
			local damage = SpaceDamage(curr, 1)
			damage.sImageMark = "combat/truelch_test_square.png"
			ret:AddDamage(damage)

			--ACID

			local damage = SpaceDamage(curr, dmg)
			damage.iAcid = EFFECT_CREATE
			ret:AddDamage(damage)



			--DAMAGE
			local damage = SpaceDamage(curr, dmg)
			ret:AddDamage(damage)

			--INCR
			if dmg < 15 then --it seems to be the hardcoded limit!
				dmg = dmg + 1
			end
		end
	end

	]]

	--DAMAGE_DEATH


	local damage = SpaceDamage(p2, 0)
	--damage.sImageMark = "combat/icons/truelch_test_square.png"
	local dir = GetDirection(p2 - p1)
	damage.sImageMark = "combat/icons/truelch_smoke_push_"..tostring(dir)..".png"
	ret:AddDamage(damage)


	--[[
	local damage = SpaceDamage(p2, self.Damage)
	damage.iCrack = EFFECT_CREATE
	ret:AddDamage(damage)

	local damage = SpaceDamage(p2, self.Damage)
	damage.iCrack = EFFECT_CREATE
	ret:AddDamage(damage)
	]]
	
	--[[
	local pawn = Board:GetPawn(p2)
	if pawn ~= nil then
		--pawn:RemoveWeapon(1)
		pawn:AddWeapon("truelch_mg43MachineGun")
	end
	]]

	--[[
	LOG("------------- LOOP 1:")
	for j = 0, 7 do
		for i = 0, 7 do
			local mech = Board:GetPawn(Point(i, j))
			if mech ~= nil and mech:IsMech() then
				LOG("mech: "..mech:GetMechName()..", id: "..tostring(mech:GetId()))
			end
		end
	end

	--This isn't reliable, so i'm sticking to the good old method to access all mechs
	LOG("------------- LOOP 2:")
	for _, p in pairs(extract_table(Board:GetPawns(TEAM_MECH))) do
		local damage = SpaceDamage(p:GetSpace(), -10)
		LOG("p: "..p:GetMechName()..", id: "..tostring(p:GetId()))
		ret:AddDamage(damage)
	end
	]]


	return ret
end