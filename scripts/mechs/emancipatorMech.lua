local resourcePath = mod_loader.mods[modApi.currentMod].resourcePath
local scriptPath = mod_loader.mods[modApi.currentMod].scriptPath
local mechPath = resourcePath .."img/mechs/"
local mod = modApi:getCurrentMod()
local mechDiversYellow = modApi:getPaletteImageOffset("truelch_MechDiversYellow")

--trait --->
local trait = require(scriptPath.."/libs/trait") --unnecessary?
trait:add{
    pawnType = "EmancipatorMech",
    icon = "img/combat/icons/icon_protecc.png",
    icon_offset = Point(0, 0),
    desc_title = "Patriotism",
    desc_text = "Any damage caused by a Mech Diver to a Building will be redirected to any Mech Diver in the area of effect."
}
-- <--- trait

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

truelch_EmancipatorMech = Pawn:new{
	Name = "Emancipator Mech",
	Class = "Prime",

	Health = 3,
	MoveSpeed = 3,
	Massive = true,

	Image = "patriotMech", --Image = "emancipatorMech",
	ImageOffset = mechDiversYellow,
	
	SkillList = { "truelch_dualAutocannons", "truelch_Stratagem" },

	SoundLocation = "/mech/prime/punch_mech/",
	ImpactMaterial = IMPACT_METAL,
	
	DefaultTeam = TEAM_PLAYER,
}