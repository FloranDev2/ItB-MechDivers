local mod = mod_loader.mods[modApi.currentMod]
local resourcePath = mod.resourcePath

--FMW modes icons (TODO)
modApi:appendAsset("img/modes/icon_resupply.png", resourcePath.."img/modes/icon_resupply.png")
modApi:appendAsset("img/modes/icon_strafe.png",   resourcePath.."img/modes/icon_strafe.png")

modApi:appendAsset("img/modes/icon_minigun.png", resourcePath.."img/modes/icon_minigun.png")
modApi:appendAsset("img/modes/icon_rocket_pod.png",   resourcePath.."img/modes/icon_rocket_pod.png")

--Items
modApi:appendAsset("img/combat/item_truelch_supply_pod.png", resourcePath.."img/combat/item_truelch_supply_pod.png")
	Location["combat/item_truelch_supply_pod.png"] = Point(-15, 10)

--Damage mark
modApi:appendAsset("img/combat/icons/icon_resupply.png", resourcePath.."img/combat/icons/icon_resupply.png")
	Location["combat/icons/icon_resupply.png"] = Point(-10, 16)

--Trait icon
modApi:appendAsset("img/combat/icons/icon_protecc.png", resourcePath.."img/combat/icons/icon_protecc.png")
	Location["combat/icons/icon_protecc.png"] = Point(-12, 8)

--Weapons icons
modApi:appendAsset("img/weapons/truelch_delivery.png", resourcePath.."img/weapons/truelch_delivery.png")
modApi:appendAsset("img/weapons/truelch_reinforcement_passive.png", resourcePath.."img/weapons/truelch_reinforcement_passive.png")
modApi:appendAsset("img/weapons/truelch_dual_autocannon.png", resourcePath.."img/weapons/truelch_dual_autocannon.png")
modApi:appendAsset("img/weapons/truelch_patriot_weapons.png", resourcePath.."img/weapons/truelch_patriot_weapons.png")
modApi:appendAsset("img/weapons/truelch_stratagem.png", resourcePath.."img/weapons/truelch_stratagem.png")

--Animations