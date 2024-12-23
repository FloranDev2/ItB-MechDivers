local resourcePath = mod_loader.mods[modApi.currentMod].resourcePath
local scriptPath = mod_loader.mods[modApi.currentMod].scriptPath
local mechPath = resourcePath .."img/mechs/"
local mod = modApi:getCurrentMod()
local mechDiversBlack = modApi:getPaletteImageOffset("truelch_MechDiversBlack")

--trait --->
local trait = require(scriptPath.."/libs/trait") --unnecessary?
trait:add{
    pawnType = "truelch_PatriotMech",
    icon = "img/combat/icons/icon_protecc.png",
    icon_offset = Point(0, 0),
    desc_title = "Patriotism",
    desc_text = "Any damage caused during player's turn to a Building will be redirected to any adjacent Mech Diver."
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
a.patriotMech =         a.MechUnit:new{Image = "units/player/patriotMech.png",          PosX = -21, PosY =  -5 }
a.patriotMecha =        a.MechUnit:new{Image = "units/player/patriotMech_a.png",        PosX = -21, PosY = -10, NumFrames = 4 }
a.patriotMechw =        a.MechUnit:new{Image = "units/player/patriotMech_w.png",        PosX = -21, PosY =   4 }
a.patriotMech_broken =  a.MechUnit:new{Image = "units/player/patriotMech_broken.png",   PosX = -21, PosY = -10 }
a.patriotMechw_broken = a.MechUnit:new{Image = "units/player/patriotMech_w_broken.png", PosX = -21, PosY =  -5 }
a.patriotMech_ns =      a.MechIcon:new{Image = "units/player/patriotMech_ns.png" }

truelch_PatriotMech = Pawn:new{
	Name = "Patriot Mech",
	Class = "Prime",

	Health = 3,
	MoveSpeed = 3,
	Massive = true,

	Image = "patriotMech",
	ImageOffset = mechDiversBlack,
	
	SkillList = { "truelch_PatriotWeapons", "truelch_StratagemFMW" },
	--SkillList = { "truelch_TestWeapon", "truelch_DebugMechs" },

	SoundLocation = "/mech/prime/punch_mech/",
	ImpactMaterial = IMPACT_METAL,
	
	DefaultTeam = TEAM_PLAYER,
}