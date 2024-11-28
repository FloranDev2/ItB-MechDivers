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
	--Assets
	require(self.scriptPath.."assets")

	--Palette
	require(self.scriptPath.."palette")

	--Achievements
	--require(self.scriptPath.."achievements")

	--FMW
	self.FMW_hotkeyConfigTitle = "Mode Selection Hotkey" -- title of hotkey config in mod config
	self.FMW_hotkeyConfigDesc = "Hotkey used to open and close firing mode selection." -- description of hotkey config in mod config
	require(self.scriptPath .. "fmw/FMW"):init()

	--Drop Env
	require(self.scriptPath.."dropEnv")

	--Hooks
	require(self.scriptPath.."hooks")

	--Mechs
	require(self.scriptPath.."mechs/patriotMech")
	require(self.scriptPath.."mechs/emancipatorMech")
	require(self.scriptPath.."mechs/eagleMech")



	--Regular weapons
	require(self.scriptPath.."/weapons/testWeapon")
	require(self.scriptPath.."/weapons/debugMechs")
	require(self.scriptPath.."/weapons/passive_respawn")

	--Replacing AI Pilot with Mech Diver recruit pilot
	require(self.scriptPath.."pilots")

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
	--FMW
	require(self.scriptPath .. "fmw/FMW"):load()

	modApi:addSquad(	
		{
			id = "truelch_MechDivers",
			"Mech Divers",
			"PatriotMech",
			"EmancipatorMech",
			"EagleMech",
		},
		"Mech Divers",
		"A cup of Liber-Tea.\nLet's free Super Earth from these undemocratic Vek!",
		self.resourcePath.."img/squad_icon.png"
	)

	require(self.scriptPath.."modifiedHangar"):load(self, options)
end

return mod