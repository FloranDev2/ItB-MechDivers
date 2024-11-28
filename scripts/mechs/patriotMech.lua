local resourcePath = mod_loader.mods[modApi.currentMod].resourcePath
local scriptPath = mod_loader.mods[modApi.currentMod].scriptPath
local mechPath = resourcePath .."img/mechs/"
local mod = modApi:getCurrentMod()
local mechDivers = modApi:getPaletteImageOffset("truelch_MechDivers")

local files = {
	"patriotMech.png",
	"patriotMech_a.png",
	"patriotMech_w.png",
	"patriotMech_w_broken.png",
	"patriotMech_broken.png",
	"patriotMech_ns.png",
	"patriotMech_h.png"
}

for _, file in ipairs(files) do
	modApi:appendAsset("img/units/player/"..file, mechPath..file)
end

local a = ANIMS
a.patriotMech =         a.MechUnit:new{Image = "units/player/patriotMech.png",          PosX = -28, PosY =  -5 }
a.patriotMecha =        a.MechUnit:new{Image = "units/player/patriotMech_a.png",        PosX = -28, PosY = -10, NumFrames = 4 }
a.patriotMechw =        a.MechUnit:new{Image = "units/player/patriotMech_w.png",        PosX = -28, PosY =   4 }
a.patriotMech_broken =  a.MechUnit:new{Image = "units/player/patriotMech_broken.png",   PosX = -28, PosY =  -5 }
a.patriotMechw_broken = a.MechUnit:new{Image = "units/player/patriotMech_w_broken.png", PosX = -28, PosY =  -5 }
a.patriotMech_ns =      a.MechIcon:new{Image = "units/player/patriotMech_ns.png" }

PatriotMech = Pawn:new{
	Name = "Patriot Mech",
	Class = "Prime",

	Health = 2,
	MoveSpeed = 3,
	Massive = true,

	Image = "patriotMech",
	ImageOffset = mechDivers,
	
	SkillList = { "truelch_TestWeapon", "truelch_DebugMechs" },

	SoundLocation = "/mech/prime/punch_mech/",
	ImpactMaterial = IMPACT_METAL,
	
	DefaultTeam = TEAM_PLAYER,
}