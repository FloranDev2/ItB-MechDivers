local resourcePath = mod_loader.mods[modApi.currentMod].resourcePath
local scriptPath = mod_loader.mods[modApi.currentMod].scriptPath
local mechPath = resourcePath .."img/mechs/"
local mod = modApi:getCurrentMod()
local mechDivers = modApi:getPaletteImageOffset("truelch_MechDivers")

--trait --->
local trait = require(scriptPath.."/libs/trait") --unnecessary?
trait:add{
    pawnType = "PatriotMech",
    icon = "img/combat/icons/icon_protecc.png",
    icon_offset = Point(0, 0),
    desc_title = "Patriotism",
    desc_text = "Any damage caused by a Mech Diver to a Building will be redirected to any Mech Diver in the area of effect."
}
-- <--- trait

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
	
	--Might remove stratagem from him?
	SkillList = { "truelch_PatriotWeapons", "truelch_Stratagem" },

	SoundLocation = "/mech/prime/punch_mech/",
	ImpactMaterial = IMPACT_METAL,
	
	DefaultTeam = TEAM_PLAYER,
}