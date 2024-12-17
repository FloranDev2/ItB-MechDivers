local mod = mod_loader.mods[modApi.currentMod]
local resourcePath = mod.resourcePath

--FMW modes icons

--Debug stuff
for i = 1, 8 do
	modApi:appendAsset("img/modes/icon_mode"..tostring(i)..".png", resourcePath.."img/modes/icon_mode"..tostring(i)..".png")
end

modApi:appendAsset("img/modes/icon_resupply.png", resourcePath.."img/modes/icon_resupply.png")
modApi:appendAsset("img/modes/icon_strafe.png",   resourcePath.."img/modes/icon_strafe.png")

modApi:appendAsset("img/modes/icon_minigun.png",    resourcePath.."img/modes/icon_minigun.png")
modApi:appendAsset("img/modes/icon_rocket_pod.png", resourcePath.."img/modes/icon_rocket_pod.png")

--Stratagem FMWs icons
modApi:appendAsset("img/modes/icon_mg43.png",   resourcePath.."img/modes/icon_mg43.png")
modApi:appendAsset("img/modes/icon_apw1.png",   resourcePath.."img/modes/icon_apw1.png")
modApi:appendAsset("img/modes/icon_flam40.png", resourcePath.."img/modes/icon_flam40.png")
modApi:appendAsset("img/modes/icon_rs422.png",  resourcePath.."img/modes/icon_rs422.png")

modApi:appendAsset("img/modes/icon_mg_sentry.png",     resourcePath.."img/modes/icon_mg_sentry.png")
modApi:appendAsset("img/modes/icon_mortar_sentry.png", resourcePath.."img/modes/icon_mortar_sentry.png")
modApi:appendAsset("img/modes/icon_tesla_tower.png",   resourcePath.."img/modes/icon_tesla_tower.png")
modApi:appendAsset("img/modes/icon_guard_dog.png",     resourcePath.."img/modes/icon_guard_dog.png")

modApi:appendAsset("img/modes/icon_napalm_airstrike.png", resourcePath.."img/modes/icon_napalm_airstrike.png")
modApi:appendAsset("img/modes/icon_smoke_airstrike.png",  resourcePath.."img/modes/icon_smoke_airstrike.png")
modApi:appendAsset("img/modes/icon_500kg_airstrike.png",  resourcePath.."img/modes/icon_500kg_airstrike.png")

modApi:appendAsset("img/modes/icon_orbital_precision_strike.png", resourcePath.."img/modes/icon_orbital_precision_strike.png")

--Items
--Note: this is also temporary; these effects are kinda like ENV icons
modApi:appendAsset("img/combat/blue_stratagem_grenade.png", resourcePath.."img/combat/blue_stratagem_grenade.png")
	Location["combat/blue_stratagem_grenade.png"] = Point(-7, -22) --14, 52

modApi:appendAsset("img/combat/red_stratagem_grenade.png", resourcePath.."img/combat/red_stratagem_grenade.png")
	Location["combat/red_stratagem_grenade.png"] = Point(-7, -22)

modApi:appendAsset("img/combat/item_ammo.png", resourcePath.."img/combat/item_apw1.png")
	Location["combat/item_ammo.png"] = Point(-25, -10)

modApi:appendAsset("img/combat/item_apw1.png", resourcePath.."img/combat/item_apw1.png")
	Location["combat/item_apw1.png"] = Point(-25, -10)
modApi:appendAsset("img/combat/item_flam40.png", resourcePath.."img/combat/item_flam40.png")
	Location["combat/item_flam40.png"] = Point(-25, -10)
modApi:appendAsset("img/combat/item_mg43.png", resourcePath.."img/combat/item_mg43.png")
	Location["combat/item_mg43.png"] = Point(-25, -10)
modApi:appendAsset("img/combat/item_rs422.png", resourcePath.."img/combat/item_rs422.png")
	Location["combat/item_rs422.png"] = Point(-25, -10)


--Anims
modApi:appendAsset("img/effects/truelch_anim_pod_land.png", resourcePath.."img/effects/truelch_anim_pod_land.png")
	Location["effects/truelch_anim_pod_land.png"] = Point(-20, -40)

ANIMS.truelch_anim_pod_land = Animation:new{
	Image = "effects/truelch_anim_pod_land.png",
	PosX = -25,
	PosY = -165,
	Time = 0.08,
	NumFrames = 24,
}

modApi:appendAsset("img/effects/truelch_nuke.png", resourcePath.."img/effects/truelch_nuke.png")
	Location["effects/truelch_nuke.png"] = Point(-20, -40)

ANIMS.truelch_nuke = Animation:new{
	Image = "effects/truelch_nuke.png",
	PosX = -20,
	PosY = -40,
	Time = 0.04,
	NumFrames = 9,
}

--Damage mark
modApi:appendAsset("img/combat/icons/icon_resupply.png", resourcePath.."img/combat/icons/icon_resupply.png")
	Location["combat/icons/icon_resupply.png"] = Point(-10, 16)

modApi:appendAsset("img/combat/icons/icon_ammo_glow.png", resourcePath.."img/combat/icons/icon_ammo_glow.png")
	Location["combat/icons/icon_ammo_glow.png"] = Point(-15, 15)

--Trait icon
modApi:appendAsset("img/combat/icons/icon_protecc.png", resourcePath.."img/combat/icons/icon_protecc.png")
	Location["combat/icons/icon_protecc.png"] = Point(-12, 8)

--Artillery shotups
modApi:appendAsset("img/effects/truelch_shotup_stratagem_ball.png", resourcePath.."img/effects/truelch_shotup_stratagem_ball.png")

--Projectiles

--Airstrikes
modApi:appendAsset("img/effects/truelch_eagle.png", resourcePath.."img/effects/truelch_eagle.png")

--Weapons icons
modApi:appendAsset("img/weapons/truelch_delivery.png", resourcePath.."img/weapons/truelch_delivery.png")
modApi:appendAsset("img/weapons/truelch_reinforcement_passive.png", resourcePath.."img/weapons/truelch_reinforcement_passive.png")
modApi:appendAsset("img/weapons/truelch_dual_autocannon.png", resourcePath.."img/weapons/truelch_dual_autocannon.png")
modApi:appendAsset("img/weapons/truelch_patriot_weapons.png", resourcePath.."img/weapons/truelch_patriot_weapons.png")
modApi:appendAsset("img/weapons/truelch_stratagem.png", resourcePath.."img/weapons/truelch_stratagem.png")

--Tile icons
modApi:appendAsset("img/combat/tile_icon/tile_truelch_drop.png", mod.resourcePath.."img/combat/tile_icon/tile_truelch_drop.png")
	Location["combat/tile_icon/tile_truelch_drop.png"] = Point(-27, 2)