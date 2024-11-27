truelch_DebugMechs = Skill:new{
	--Infos
	Name = "Debug Mechs",
	Description = "Debug the status of all Mechs",
	Class = "Any",
	Icon = "weapons/brute_tankmech.png",

	--Shop
	Rarity = 1,
	PowerCost = 0,
}

function truelch_DebugMechs:GetTargetArea(point)
	local ret = PointList()

	for j = 0, 7 do
		for i = 0, 7 do
			local curr = Point(i, j)
			ret:push_back(curr)
		end
	end
	
	return ret
end

function truelch_DebugMechs:GetSkillEffect(p1, p2)
	local ret = SkillEffect()

	for i = 0, 2 do
		local mech = Board:GetPawn(i)
		LOG(tostring(i).." -> loc:"..mech:GetSpace():GetString())
		mech:SetInvisible(false)
		ret:AddDamage(SpaceDamage(mech:GetSpace(),-10)) --test
	end

	return ret
end