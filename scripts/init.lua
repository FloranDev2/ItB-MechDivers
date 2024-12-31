local mod = {
	id = "truelch_MechDivers", --let's avoid errors and keep this id
	name = "Hell Breachers", --Name's change suggested by Generic and it won the poll!
	icon = "img/mod_icon.png",
	version = "1.1.0",
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
	require(self.scriptPath.."achievements")

	--Libs
	require(self.scriptPath.."libs/artilleryArc") --weaponArmed is imported by artilleryArc
	require(self.scriptPath.."libs/boardEvents")
	require(self.scriptPath.."libs/trait")
	--require(self.scriptPath.."libs/weaponArmed") --even though it's imported by artilleryArc, I'll need it for QTE's too

	--FMW
	self.FMW_hotkeyConfigTitle = "Mode Selection Hotkey" -- title of hotkey config in mod config
	self.FMW_hotkeyConfigDesc = "Hotkey used to open and close firing mode selection." -- description of hotkey config in mod config
	require(self.scriptPath.."fmw/FMW"):init()

	--Items
	require(self.scriptPath.."items")
	require(self.scriptPath.."deployables") --deployable pawns

	--Hooks
	require(self.scriptPath.."hellpods")
	require(self.scriptPath.."hooks")   --> will be moved to the reinforcement passive
	require(self.scriptPath.."protecc") --> will be moved to trait (OR PILOT??!)

	--Mechs
	require(self.scriptPath.."mechs/patriotMech")
	require(self.scriptPath.."mechs/emancipatorMech")
	require(self.scriptPath.."mechs/eagleMech")

	--Test
	require(self.scriptPath.."/weapons/test/testWeapon")
	require(self.scriptPath.."/weapons/test/debugMechs")

	--Regular weapons
	require(self.scriptPath.."/weapons/dualAutocannons")
	require(self.scriptPath.."/weapons/patriotWeapons")
	require(self.scriptPath.."/weapons/stratagemFMW")
	require(self.scriptPath.."/weapons/delivery")
	require(self.scriptPath.."/weapons/passive_respawn")

	--Stratagem weapons
	require(self.scriptPath.."/weapons/stratagemsWeapons/stratagemsWeapons")

	--Deployable weapons

	--Replacing AI Pilot with Mech Diver recruit pilot
	require(self.scriptPath.."pilots")

	--Weapon deck
	modApi:addWeaponDrop("truelch_DualAutocannons")
	modApi:addWeaponDrop("truelch_PatriotWeapons")
	modApi:addWeaponDrop("truelch_StratagemFMW")
	modApi:addWeaponDrop("truelch_Delivery")
	modApi:addWeaponDrop("truelch_Reinforcements_Passive")

	--Env tooltips (might move that stuff in a separate file)
	---> Hell Pods
	TILE_TOOLTIPS["hell_drop"] = {"Hell Drop", "A Hell Pod will land here soon, killing any unit below."}
	---> Airstrikes
	TILE_TOOLTIPS["airstrike_napalm"]     = {"Napalm Airstrike", "This tile will be ignited before enemy turn."}
	TILE_TOOLTIPS["airstrike_smoke"]      = {"Smoke Airstrike",  "This tile will be smoked before enemy turn."}
	TILE_TOOLTIPS["airstrike_500_center"] = {"500kg Bomb", "This tile will take 4 damage before enemy turn."}
	TILE_TOOLTIPS["airstrike_500_outer"]  = {"500kg Bomb", "This tile will take 2 damage before enemy turn."}
	---> Orbital
	TILE_TOOLTIPS["orbital_precision_strike"] = {"Orbital Precision Strike", "Anything on this tile will be destroyed AFTER enemy turn."}

	--Custom hangar
	require(self.scriptPath.."modifiedHangar"):init(self) --just tmp
end

function mod:load(options, version)
	--FMW
	require(self.scriptPath.."fmw/FMW"):load()

	modApi:addSquad(
		{
			id = "truelch_MechDivers",
			"Hell Breachers", --Name's change suggested by Generic and it won the poll!
			"truelch_PatriotMech",
			"truelch_EmancipatorMech",
			"truelch_EagleMech",
		},
		"Hell Breachers",
		"A cup of Liber-Tea.\nLet's free Super Earth from these undemocratic Vek!",
		self.resourcePath.."img/squad_icon.png"
	)

	--require(self.scriptPath.."modifiedHangar"):load(self, options) --just tmp
end

return mod