
--Interesting (and undocumented?): IsPassiveSkill("tatu_Acid_Passive")

truelch_Reinforcements_Passive = PassiveSkill:new{
	Name = "Reinforcements",
	Description = "Everytime a Mech dies, drop a new Mech randomly on the map.",
	PowerCost = 1,
	Icon = "weapons/truelch_reinforcement_passive.png",
	Upgrades = 0,
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
