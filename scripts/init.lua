local mod = {
	id = "truelch_MechDivers",
	name = "Mech Divers",
	icon = "img/mod_icon.png",
	version = "0.0.0",
	modApiVersion = "2.9.2",
	--gameVersion = "1.2.88",
    dependencies = {
		memedit = "1.0.4",
        modApiExt = "1.21",
    }	
}

function mod:init()
	--Palette
	require(self.scriptPath.."palette")

	--Achievements
	--require(self.scriptPath.."achievements")

	--Mechs
	require(self.scriptPath.."mechs/primeDiver")
	require(self.scriptPath.."mechs/bruteDiver")
	require(self.scriptPath.."mechs/rangedDiver")

	--Hooks
	require(self.scriptPath.."hooks")

	--Regular weapons
	--[[
	require(self.scriptPath.."/weapons/fighter_strafe")
	require(self.scriptPath.."/weapons/rotary_cannon")
	require(self.scriptPath.."/weapons/musket")
	]]

	--Animations
	--require(self.scriptPath .. "animations")

	--Weapon deck
	--[[
	modApi:addWeaponDrop("truelch_FighterStrafe")
	modApi:addWeaponDrop("truelch_RotaryCannon")
	modApi:addWeaponDrop("truelch_Musket")
	]]

	--Custom hangar
	require(self.scriptPath.."modifiedHangar"):init(self)
end

function mod:load(options, version)
	modApi:addSquad(	
		{
			id = "truelch_MechDivers",
			"Mech Divers",
			"PrimeDiverMech",
			"BruteDiverMech",
			"RangedDiverMech",
		},
		"Mech Divers",
		"A cup of Liber-Tea.\nLet's free Super Earth from these undemocratic Vek!",
		self.resourcePath.."img/squad_icon.png"
	)
	require(self.scriptPath.."modifiedHangar"):load(self, options)
end

return mod