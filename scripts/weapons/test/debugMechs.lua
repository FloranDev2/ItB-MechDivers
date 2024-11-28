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

	LOG("Mech debug:")
	for i = 0, 2 do
		local mech = Board:GetPawn(i)
		if mech ~= nil then
			LOG(tostring(i).." -> mech: "..mech:GetMechName().." -> loc:"..mech:GetSpace():GetString())
			--mech:SetInvisible(false)
			--ret:AddDamage(SpaceDamage(mech:GetSpace(), -10)) --test
		else
			LOG(tostring(i).." -> no pawn!")
		end
	end

	--Full pawn debug
	--local fullDebug = "\n\nFull Debug:"
	LOG("Full debug:")
	for j = 0, 7 do
		for i = 0, 7 do
			local curr = Point(i, j)
			local pawn = Board:GetPawn(curr)
			if pawn ~= nil then
				--GetType()
				--fullDebug = fullDebug + "\npawn: "..pawn:GetMechName()..", at: "..pawn:GetSpace()..", id: "..pawn:GetId()
				--LOG("pawn: "..pawn:GetMechName()..", at: "..pawn:GetSpace()..", id: "..pawn:GetId())
				LOG("pawn: "..pawn:GetMechName()..", id: "..pawn:GetId())
			end
		end
	end

	--LOG(fullDebug)

	return ret
end