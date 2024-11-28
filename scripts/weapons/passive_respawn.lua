--Interesting (and undocumented?): IsPassiveSkill("tatu_Acid_Passive")

--[[
Good to know: new Mech spawned with this won't be at index 0 - 2 in the list of pawns, and won't have an idea between 0 - 2 either.
So getting mechs by looping from 0 to 2 doesn't work anymore!
]]

truelch_Reinforcements_Passive = PassiveSkill:new{
	--Infos
	Name = "Reinforcements",
	Description = "Everytime a Mech dies, drop a new Mech randomly on the map.",
	PowerCost = 1,
	Icon = "weapons/truelch_reinforcement_passive.png",

	--Upgrades
	Upgrades = 1,
	UpgradeCost = { 1 },

	--Passive
	Passive = "truelch_Reinforcements_Passive",

	--[[
	TipImage = {
		Unit = Point(2,3),
		CustomPawn = "PunchMech",
		Target = Point(2,2),
		Enemy = Point(2,2),
	}
	]]
}

Weapon_Texts.truelch_Reinforcements_Passive_Upgrade1 = "Faster respawn"

truelch_Reinforcements_Passive_A = truelch_Reinforcements_Passive:new{
	UpgradeDescription = "Reinforcements come now instantly!",
	Passive = "truelch_Reinforcements_Passive_A", --test
}

--Useless?
--[[
function truelch_Reinforcements_Passive:GetSkillEffect(p1, p2)
	local ret = SkillEffect()
	return ret
end
]]