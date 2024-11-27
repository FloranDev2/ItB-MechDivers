local resourcePath = mod_loader.mods[modApi.currentMod].resourcePath
local scriptPath = mod_loader.mods[modApi.currentMod].scriptPath
local mod = modApi:getCurrentMod()
local mechDivers = modApi:getPaletteImageOffset("truelch_MechDivers")

BruteDiverMech = Pawn:new{
	Name = "Eagle Mech",
	Class = "Brute",

	Health = 1,
	MoveSpeed = 15,
	Massive = true,

	--Flying = true,

	Image = "MechLaser", --"MechLaser"
	ImageOffset = mechDivers,
	
	SkillList = { "truelch_TestWeapon", "truelch_DebugMechs" },

	SoundLocation = "/mech/prime/punch_mech/",
	ImpactMaterial = IMPACT_METAL,
	
	DefaultTeam = TEAM_PLAYER,
}