local resourcePath = mod_loader.mods[modApi.currentMod].resourcePath
local scriptPath = mod_loader.mods[modApi.currentMod].scriptPath
local mod = modApi:getCurrentMod()
local mechDivers = modApi:getPaletteImageOffset("truelch_MechDivers")

PrimeDiverMech = Pawn:new{
	Name = "Emancipator Mech",
	Class = "Prime",

	Health = 1,
	MoveSpeed = 15,
	Massive = true,

	Image = "MechPunch",
	ImageOffset = mechDivers,
	
	SkillList = { "truelch_TestWeapon", "truelch_DebugMechs" },

	SoundLocation = "/mech/prime/punch_mech/",
	ImpactMaterial = IMPACT_METAL,
	
	DefaultTeam = TEAM_PLAYER,
}