local resourcePath = mod_loader.mods[modApi.currentMod].resourcePath
local scriptPath = mod_loader.mods[modApi.currentMod].scriptPath
local mechPath = resourcePath .."img/mechs/"
local mod = modApi:getCurrentMod()
local mechDivers = modApi:getPaletteImageOffset("truelch_MechDivers")

local files = {
	"emancipatorMech.png",
	"emancipatorMech_a.png",
	"emancipatorMech_w.png",
	"emancipatorMech_w_broken.png",
	"emancipatorMech_broken.png",
	"emancipatorMech_ns.png",
	"emancipatorMech_h.png"
}

for _, file in ipairs(files) do
	modApi:appendAsset("img/units/player/"..file, mechPath..file)
end

local a = ANIMS
a.emancipatorMech =         a.MechUnit:new{Image = "units/player/emancipatorMech.png",          PosX = -28, PosY =  -5 }
a.emancipatorMecha =        a.MechUnit:new{Image = "units/player/emancipatorMech_a.png",        PosX = -28, PosY = -10, NumFrames = 4 }
a.emancipatorw =        	a.MechUnit:new{Image = "units/player/emancipatorMech_w.png",        PosX = -28, PosY =   4 }
a.emancipatorMech_broken =  a.MechUnit:new{Image = "units/player/emancipatorMech_broken.png",   PosX = -28, PosY =  -5 }
a.emancipatorMechw_broken = a.MechUnit:new{Image = "units/player/emancipatorMech_w_broken.png", PosX = -28, PosY =  -5 }
a.emancipatorMech_ns =      a.MechIcon:new{Image = "units/player/emancipatorMech_ns.png" }

EmancipatorMech = Pawn:new{
	Name = "Emancipator Mech",
	Class = "Prime",

	Health = 2,
	MoveSpeed = 3,
	Massive = true,

	Image = "emancipatorMech",
	ImageOffset = mechDivers,
	
	SkillList = { "truelch_TestWeapon", "Support_Repair" },

	SoundLocation = "/mech/prime/punch_mech/",
	ImpactMaterial = IMPACT_METAL,
	
	DefaultTeam = TEAM_PLAYER,
}