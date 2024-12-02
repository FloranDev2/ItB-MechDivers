local resourcePath = mod_loader.mods[modApi.currentMod].resourcePath
local scriptPath = mod_loader.mods[modApi.currentMod].scriptPath
local mechPath = resourcePath .."img/mechs/"
local mod = modApi:getCurrentMod()
local mechDiversBlack = modApi:getPaletteImageOffset("truelch_MechDiversBlack")

--trait --->
local trait = require(scriptPath.."/libs/trait") --unnecessary?
trait:add{
    pawnType = "EagleMech",
    icon = "img/combat/icons/icon_protecc.png",
    icon_offset = Point(0, 0),
    desc_title = "Patriotism",
    desc_text = "Any damage caused by a Mech Diver to a Building will be redirected to any Mech Diver in the area of effect."
}
-- <--- trait

local files = {
	"eagleMech.png",
	"eagleMech_a.png",
	"eagleMech_w.png",
	"eagleMech_w_broken.png",
	"eagleMech_broken.png",
	"eagleMech_ns.png",
	"eagleMech_h.png"
}

for _, file in ipairs(files) do
	modApi:appendAsset("img/units/player/"..file, mechPath..file)
end

local a = ANIMS
a.eagleMech =         a.MechUnit:new{Image = "units/player/eagleMech.png",          PosX = -28, PosY =  -5 }
a.eagleMecha =        a.MechUnit:new{Image = "units/player/eagleMech_a.png",        PosX = -28, PosY = -10, NumFrames = 4 }
a.eagleMechw =        a.MechUnit:new{Image = "units/player/eagleMech_w.png",        PosX = -28, PosY =   4 }
a.eagleMech_broken =  a.MechUnit:new{Image = "units/player/eagleMech_broken.png",   PosX = -28, PosY =  -5 }
a.eagleMechw_broken = a.MechUnit:new{Image = "units/player/eagleMech_w_broken.png", PosX = -28, PosY =  -5 }
a.eagleMech_ns =      a.MechIcon:new{Image = "units/player/eagleMech_ns.png" }

truelch_EagleMech = Pawn:new{
	Name = "Shuttle Mech", --Support Mech? (already used in WotP) / (Aerospace) Assault (Craft) Mech?
	Class = "Science", --or Brute? But since it'll have a lot of support stuff + passive, makes more sense to make it Science, right?

	Health = 3,
	MoveSpeed = 3,
	Massive = true,

	Flying = true,

	Image = "eagleMech",
	ImageOffset = mechDiversBlack,
	
	--One FMWeapon that calls in various weapon and a Respawn passive
	SkillList = { "truelch_Delivery", "truelch_Reinforcements_Passive" }, --truelch_TestWeapon

	--[[
	"/mech/flying/jet_mech/"	
	]]
	SoundLocation = "/mech/flying/jet_mech/",
	ImpactMaterial = IMPACT_METAL,
	
	DefaultTeam = TEAM_PLAYER,
}