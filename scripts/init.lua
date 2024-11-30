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

	--Libs
	require(self.scriptPath.."libs/artilleryArc") --weaponArmed is imported by artilleryArc
	require(self.scriptPath.."libs/boardEvents")
	require(self.scriptPath.."libs/trait")
	require(self.scriptPath.."libs/weaponArmed") --even though it's imported by artilleryArc, I'll need it for QTE's too

	--Test
	--require(self.scriptPath.."test_qte") --omg it works lmao

	--FMW
	self.FMW_hotkeyConfigTitle = "Mode Selection Hotkey" -- title of hotkey config in mod config
	self.FMW_hotkeyConfigDesc = "Hotkey used to open and close firing mode selection." -- description of hotkey config in mod config
	require(self.scriptPath.."fmw/FMW"):init()

	--Items
	require(self.scriptPath.."items")

	--Drop Env
	require(self.scriptPath.."dropEnv")

	--Hooks
	require(self.scriptPath.."hooks")   --> will be moved to the reinforcement passive
	require(self.scriptPath.."protecc") --> will be moved to trait

	--Mechs
	require(self.scriptPath.."mechs/patriotMech")
	require(self.scriptPath.."mechs/emancipatorMech")
	require(self.scriptPath.."mechs/eagleMech")

	--Test
	require(self.scriptPath.."/weapons/test/testWeapon")
	require(self.scriptPath.."/weapons/test/debugMechs")

	--Regular weapons
	require(self.scriptPath.."/weapons/emancipatorWeapons")
	require(self.scriptPath.."/weapons/patriotWeapons")
	require(self.scriptPath.."/weapons/stratagem")
	require(self.scriptPath.."/weapons/delivery")
	require(self.scriptPath.."/weapons/passive_respawn")

	--Stratagem weapons
	require(self.scriptPath.."/weapons/stratagemsWeapons/stratagemsWeapons")

	--Deployable weapons

	--Replacing AI Pilot with Mech Diver recruit pilot
	require(self.scriptPath.."pilots")

	--Weapon deck
	modApi:addWeaponDrop("truelch_Reinforcements_Passive")

	--Custom hangar
	require(self.scriptPath.."modifiedHangar"):init(self)
end

function mod:load(options, version)
	--FMW
	require(self.scriptPath.."fmw/FMW"):load()

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