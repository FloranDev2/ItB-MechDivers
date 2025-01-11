truelch_TestScenarioReloadWeapon = Skill:new{
	--Infos
	Name = "Reload",
	Description = "Reload any weapon (regular or FMW).",
	Class = "Any",
	Icon = "weapons/truelch_delivery.png",

	--Shop
	Rarity = 1,
	PowerCost = 0,
}

function truelch_TestScenarioReloadWeapon:GetTargetArea(point)
	local ret = PointList()
	for j = 0, 7 do
		for i = 0, 7 do
			local curr = Point(i, j)
			local pawn = Board:GetPawn(curr)
			if pawn ~= nil and pawn:IsMech() then
				ret:push_back(curr)
			end
		end
	end	
	return ret
end

function truelch_TestScenarioReloadWeapon:GetSkillEffect(p1, p2)
	local ret = SkillEffect()
	local pawn = Board:GetPawn(p2)
	if pawn ~= nil and pawn:IsMech() then
		ret:AddScript(string.format("truelch_ItemReload(%s, 1)", tostring(pawn:GetId())))
		ret:AddScript(string.format([[Board:AddAlert(%s, "RELOADED!")]], p2:GetString()))
	end
	return ret
end


truelch_TestScenarioPawn = Pawn:new{
	Name = "Click on me!",
	Health = 5,
	MoveSpeed = 15,
	Image = "DroneSupport1",
	SkillList = { "truelch_TestScenarioReloadWeapon" },
	SoundLocation = "/mech/flying/jet_mech/",
	DefaultTeam = TEAM_PLAYER,
	ImpactMaterial = IMPACT_METAL,
	Corpse = false,
	Flying = true,
}
AddPawn("truelch_TestScenarioPawn")