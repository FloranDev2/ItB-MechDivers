local mod = mod_loader.mods[modApi.currentMod]
local resourcePath = mod.resourcePath

--FMW modes icons
modApi:appendAsset("img/modes/icon_resupply.png", resourcePath.."img/modes/icon_resupply.png")
modApi:appendAsset("img/modes/icon_strafe.png",   resourcePath.."img/modes/icon_strafe.png")

modApi:appendAsset("img/modes/icon_minigun.png",    resourcePath.."img/modes/icon_minigun.png")
modApi:appendAsset("img/modes/icon_rocket_pod.png", resourcePath.."img/modes/icon_rocket_pod.png")

--Stratagem FMWs icons
modApi:appendAsset("img/modes/icon_mg43.png",   resourcePath.."img/modes/icon_mg43.png")
modApi:appendAsset("img/modes/icon_apw1.png",   resourcePath.."img/modes/icon_apw1.png")
modApi:appendAsset("img/modes/icon_flam40.png", resourcePath.."img/modes/icon_flam40.png")
modApi:appendAsset("img/modes/icon_rs422.png",  resourcePath.."img/modes/icon_rs422.png")

modApi:appendAsset("img/modes/icon_mg_sentry.png",       resourcePath.."img/modes/icon_mg_sentry.png")
modApi:appendAsset("img/modes/icon_mortar_sentry.png",   resourcePath.."img/modes/icon_mortar_sentry.png")
modApi:appendAsset("img/modes/icon_tesla_tower.png",     resourcePath.."img/modes/icon_tesla_tower.png")
modApi:appendAsset("img/modes/icon_guard_dog.png",       resourcePath.."img/modes/icon_guard_dog.png")
modApi:appendAsset("img/modes/icon_guard_dog_laser.png", resourcePath.."img/modes/icon_guard_dog_laser.png")

modApi:appendAsset("img/modes/icon_napalm_airstrike.png", resourcePath.."img/modes/icon_napalm_airstrike.png")
modApi:appendAsset("img/modes/icon_smoke_airstrike.png",  resourcePath.."img/modes/icon_smoke_airstrike.png")
modApi:appendAsset("img/modes/icon_500kg_airstrike.png",  resourcePath.."img/modes/icon_500kg_airstrike.png")

modApi:appendAsset("img/modes/icon_orbital_precision_strike.png", resourcePath.."img/modes/icon_orbital_precision_strike.png")
modApi:appendAsset("img/modes/icon_orbital_walking_barrage.png", resourcePath.."img/modes/icon_orbital_walking_barrage.png")

--Items
--Note: this is also temporary; these effects are kinda like ENV icons
modApi:appendAsset("img/combat/blue_stratagem_grenade.png", resourcePath.."img/combat/blue_stratagem_grenade.png")
	Location["combat/blue_stratagem_grenade.png"] = Point(-7, -22) --14, 52

modApi:appendAsset("img/combat/red_stratagem_grenade.png", resourcePath.."img/combat/red_stratagem_grenade.png")
	Location["combat/red_stratagem_grenade.png"] = Point(-7, -22)

modApi:appendAsset("img/combat/item_ammo.png", resourcePath.."img/combat/item_ammo.png")
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

--Same, but with the grenade designator that has the light signal thingy
modApi:appendAsset("img/effects/truelch_anim_pod_land_2.png", resourcePath.."img/effects/truelch_anim_pod_land_2.png")
	Location["effects/truelch_anim_pod_land_2.png"] = Point(-20, -40)

ANIMS.truelch_anim_pod_land_2 = Animation:new{
	Image = "effects/truelch_anim_pod_land_2.png",
	PosX = -25,
	PosY = -165,
	Time = 0.08,
	NumFrames = 24,
}

modApi:appendAsset("img/effects/truelch_500kg.png", resourcePath.."img/effects/truelch_500kg.png")
	Location["effects/truelch_500kg.png"] = Point(-25, -123)

ANIMS.truelch_500kg = Animation:new{
	Image = "effects/truelch_500kg.png",
	PosX = -25,
	PosY = -123,
	Time = 0.08,
	NumFrames = 13,
}

modApi:appendAsset("img/effects/truelch_anim_orbital_laser.png", resourcePath.."img/effects/truelch_anim_orbital_laser.png")
	Location["effects/truelch_anim_orbital_laser.png"] = Point(-25, -165)

ANIMS.truelch_anim_orbital_laser = Animation:new{
	Image = "effects/truelch_anim_orbital_laser.png",
	PosX = -25,
	PosY = -165,
	Time = 0.04,
	NumFrames = 10,
}

--Test
modApi:appendAsset("img/effects/truelch_charged.png", resourcePath.."img/effects/truelch_charged.png")
	Location["effects/truelch_charged.png"] = Point(-25, -165)
ANIMS.truelch_anim_charged = Animation:new{
	Image = "effects/truelch_charged.png",
	NumFrames = 8,
	Time = 0.15,
	PosX = -33,
	PosY = -14,	
	Loop = true
}

--Damage mark
modApi:appendAsset("img/combat/icons/icon_resupply.png", resourcePath.."img/combat/icons/icon_resupply.png")
	Location["combat/icons/icon_resupply.png"] = Point(-10, 16)

modApi:appendAsset("img/combat/icons/icon_ammo_glow.png", resourcePath.."img/combat/icons/icon_ammo_glow.png")
	Location["combat/icons/icon_ammo_glow.png"] = Point(-15, 15)

modApi:appendAsset("img/combat/icons/icon_napalm_airstrike.png", resourcePath.."img/combat/icons/icon_napalm_airstrike.png")
	Location["combat/icons/icon_napalm_airstrike.png"] = Point(-13, 11)

modApi:appendAsset("img/combat/icons/icon_smoke_airstrike.png", resourcePath.."img/combat/icons/icon_smoke_airstrike.png")
	Location["combat/icons/icon_smoke_airstrike.png"] = Point(-13, 11)

modApi:appendAsset("img/combat/icons/icon_500kg_outer.png", resourcePath.."img/combat/icons/icon_500kg_outer.png")
	Location["combat/icons/icon_500kg_outer.png"] = Point(-11, 11)

modApi:appendAsset("img/combat/icons/icon_500kg_inner.png", resourcePath.."img/combat/icons/icon_500kg_inner.png")
	Location["combat/icons/icon_500kg_inner.png"] = Point(-11, 11)

modApi:appendAsset("img/combat/icons/icon_truelch_too_close.png", resourcePath.."img/combat/icons/icon_truelch_too_close.png")
	Location["combat/icons/icon_truelch_too_close.png"] = Point(-20, 3)

modApi:appendAsset("img/combat/icons/icon_orbital_precision_strike.png", resourcePath.."img/combat/icons/icon_orbital_precision_strike.png")
	Location["combat/icons/icon_orbital_precision_strike.png"] = Point(-18, 5)

modApi:appendAsset("img/combat/icons/icon_orbital_walking_barrage.png", resourcePath.."img/combat/icons/icon_orbital_walking_barrage.png")
	Location["combat/icons/icon_orbital_walking_barrage.png"] = Point(-20, 3)

for i = 0, 3 do
	modApi:appendAsset("img/combat/icons/icon_orbital_walking_barrage_start_"..tostring(i)..".png", resourcePath.."img/combat/icons/icon_orbital_walking_barrage_start_"..tostring(i)..".png")
		Location["combat/icons/icon_orbital_walking_barrage_start_"..tostring(i)..".png"] = Point(-20, 3)

	modApi:appendAsset("img/combat/icons/icon_orbital_walking_barrage_end_"..tostring(i)..".png", resourcePath.."img/combat/icons/icon_orbital_walking_barrage_end_"..tostring(i)..".png")
		Location["combat/icons/icon_orbital_walking_barrage_end_"..tostring(i)..".png"] = Point(-20, 3)
end


for i = 0, 3 do
	----- AIRSTRIKES -----

	--Airstrike smoke push
	modApi:appendAsset("img/combat/icons/truelch_airstrike_smoke_push_"..tostring(i)..".png", resourcePath.."img/combat/icons/truelch_airstrike_smoke_push_"..tostring(i)..".png")
		Location["combat/icons/truelch_airstrike_smoke_push_"..tostring(i)..".png"] = Point(-50, -27)

	--Airstrike smoke push blocked
	modApi:appendAsset("img/combat/icons/truelch_airstrike_smoke_push_blocked_"..tostring(i)..".png", resourcePath.."img/combat/icons/truelch_airstrike_smoke_push_blocked_"..tostring(i)..".png")
		Location["combat/icons/truelch_airstrike_smoke_push_blocked_"..tostring(i)..".png"] = Point(-50, -27)

	--Airstrike smoke push off (tile with no pawn)
	modApi:appendAsset("img/combat/icons/truelch_airstrike_smoke_push_off_"..tostring(i)..".png", resourcePath.."img/combat/icons/truelch_airstrike_smoke_push_off_"..tostring(i)..".png")
		Location["combat/icons/truelch_airstrike_smoke_push_off_"..tostring(i)..".png"] = Point(-50, -27)

	--Airstrike smoke push guard (stable pawn)
	modApi:appendAsset("img/combat/icons/truelch_airstrike_smoke_push_guard_"..tostring(i)..".png", resourcePath.."img/combat/icons/truelch_airstrike_smoke_push_guard_"..tostring(i)..".png")
		Location["combat/icons/truelch_airstrike_smoke_push_guard_"..tostring(i)..".png"] = Point(-50, -27)

	--Airstrike fire push
	modApi:appendAsset("img/combat/icons/truelch_airstrike_fire_push_"..tostring(i)..".png", resourcePath.."img/combat/icons/truelch_airstrike_fire_push_"..tostring(i)..".png")
		Location["combat/icons/truelch_airstrike_fire_push_"..tostring(i)..".png"] = Point(-50, -27)

	--Airstrike fire push blocked
	modApi:appendAsset("img/combat/icons/truelch_airstrike_fire_push_blocked_"..tostring(i)..".png", resourcePath.."img/combat/icons/truelch_airstrike_fire_push_blocked_"..tostring(i)..".png")
		Location["combat/icons/truelch_airstrike_fire_push_blocked_"..tostring(i)..".png"] = Point(-50, -27)

	--Airstrike fire push off
	modApi:appendAsset("img/combat/icons/truelch_airstrike_fire_push_off_"..tostring(i)..".png", resourcePath.."img/combat/icons/truelch_airstrike_fire_push_off_"..tostring(i)..".png")
		Location["combat/icons/truelch_airstrike_fire_push_off_"..tostring(i)..".png"] = Point(-50, -27)

	--Airstrike fire push guard
	modApi:appendAsset("img/combat/icons/truelch_airstrike_fire_push_guard_"..tostring(i)..".png", resourcePath.."img/combat/icons/truelch_airstrike_fire_push_guard_"..tostring(i)..".png")
		Location["combat/icons/truelch_airstrike_fire_push_guard_"..tostring(i)..".png"] = Point(-50, -27)

	----- DIRECT EFFECTS -----
	--No need for fire push (+ blocked), it already exist in the game!

	--Smoke push
	modApi:appendAsset("img/combat/icons/truelch_smoke_push_"..tostring(i)..".png", resourcePath.."img/combat/icons/truelch_smoke_push_"..tostring(i)..".png")
		Location["combat/icons/truelch_smoke_push_"..tostring(i)..".png"] = Point(-50, -27)

	--Smoke push blocked
	modApi:appendAsset("img/combat/icons/truelch_smoke_push_blocked_"..tostring(i)..".png", resourcePath.."img/combat/icons/truelch_smoke_push_blocked_"..tostring(i)..".png")
		Location["combat/icons/truelch_smoke_push_blocked_"..tostring(i)..".png"] = Point(-50, -27)

	--Smoke push off
	modApi:appendAsset("img/combat/icons/truelch_smoke_push_off_"..tostring(i)..".png", resourcePath.."img/combat/icons/truelch_smoke_push_off_"..tostring(i)..".png")
		Location["combat/icons/truelch_smoke_push_off_"..tostring(i)..".png"] = Point(-50, -27)

	--Smoke push guard
	modApi:appendAsset("img/combat/icons/truelch_smoke_push_guard_"..tostring(i)..".png", resourcePath.."img/combat/icons/truelch_smoke_push_guard_"..tostring(i)..".png")
		Location["combat/icons/truelch_smoke_push_guard_"..tostring(i)..".png"] = Point(-50, -27)
end


for i = 1, 15 do --dimension: 10x15 -> 13x15
	--Protecc normal damage
	modApi:appendAsset("img/combat/icons/icon_protecc_"..tostring(i)..".png", resourcePath.."img/combat/icons/icon_protecc_"..tostring(i)..".png")
		Location["combat/icons/icon_protecc_"..tostring(i)..".png"] = Point(-10, 10)

	--Protecc acid damage
	modApi:appendAsset("img/combat/icons/icon_protecc_acid_"..tostring(i)..".png", resourcePath.."img/combat/icons/icon_protecc_acid_"..tostring(i)..".png")
		Location["combat/icons/icon_protecc_acid_"..tostring(i)..".png"] = Point(-10, 10)
end

--Trait icon
modApi:appendAsset("img/combat/icons/icon_protecc.png", resourcePath.."img/combat/icons/icon_protecc.png")
	Location["combat/icons/icon_protecc.png"] = Point(-12, 8)

--Artillery shotups
modApi:appendAsset("img/effects/truelch_shotup_stratagem_ball.png", resourcePath.."img/effects/truelch_shotup_stratagem_ball.png")
modApi:appendAsset("img/effects/truelch_shotup_mortar.png",         resourcePath.."img/effects/truelch_shotup_mortar.png")
modApi:appendAsset("img/effects/truelch_mg_drone_shotup.png",       resourcePath.."img/effects/truelch_mg_drone_shotup.png")
modApi:appendAsset("img/effects/truelch_laser_drone_shotup.png",    resourcePath.."img/effects/truelch_laser_drone_shotup.png")

--Projectiles
modApi:appendAsset("img/effects/truelch_weak_shot_R.png",     resourcePath.."img/effects/truelch_weak_shot_R.png")
modApi:appendAsset("img/effects/truelch_weak_shot_U.png",     resourcePath.."img/effects/truelch_weak_shot_U.png")
modApi:appendAsset("img/effects/truelch_strong_sniper_R.png", resourcePath.."img/effects/truelch_strong_sniper_R.png")
modApi:appendAsset("img/effects/truelch_strong_sniper_U.png", resourcePath.."img/effects/truelch_strong_sniper_U.png")

--Airstrikes
modApi:appendAsset("img/effects/truelch_eagle.png", resourcePath.."img/effects/truelch_eagle.png")

--Weapons icons
modApi:appendAsset("img/weapons/truelch_delivery.png",              resourcePath.."img/weapons/truelch_delivery.png")
modApi:appendAsset("img/weapons/truelch_reinforcement_passive.png", resourcePath.."img/weapons/truelch_reinforcement_passive.png")
modApi:appendAsset("img/weapons/truelch_dual_autocannon.png",       resourcePath.."img/weapons/truelch_dual_autocannon.png")
modApi:appendAsset("img/weapons/truelch_patriot_weapons.png",       resourcePath.."img/weapons/truelch_patriot_weapons.png")
modApi:appendAsset("img/weapons/truelch_stratagem.png",             resourcePath.."img/weapons/truelch_stratagem.png")

modApi:appendAsset("img/weapons/truelch_strat_mg43.png",   resourcePath.."img/weapons/truelch_strat_mg43.png")
modApi:appendAsset("img/weapons/truelch_strat_apw1.png",   resourcePath.."img/weapons/truelch_strat_apw1.png")
modApi:appendAsset("img/weapons/truelch_strat_flam40.png", resourcePath.."img/weapons/truelch_strat_flam40.png")
modApi:appendAsset("img/weapons/truelch_strat_rs422.png",  resourcePath.."img/weapons/truelch_strat_rs422.png")


--Tile icons
modApi:appendAsset("img/combat/tile_icon/tile_truelch_drop.png", mod.resourcePath.."img/combat/tile_icon/tile_truelch_drop.png")
	Location["combat/tile_icon/tile_truelch_drop.png"] = Point(-27, 2)

modApi:appendAsset("img/combat/tile_icon/tile_truelch_napalm_airstrike.png", mod.resourcePath.."img/combat/tile_icon/tile_truelch_napalm_airstrike.png")
	Location["combat/tile_icon/tile_truelch_napalm_airstrike.png"] = Point(-27, 2)
modApi:appendAsset("img/combat/tile_icon/tile_truelch_smoke_airstrike.png", mod.resourcePath.."img/combat/tile_icon/tile_truelch_smoke_airstrike.png")
	Location["combat/tile_icon/tile_truelch_smoke_airstrike.png"] = Point(-27, 2)
modApi:appendAsset("img/combat/tile_icon/tile_truelch_500kg_airstrike.png", mod.resourcePath.."img/combat/tile_icon/tile_truelch_500kg_airstrike.png")
	Location["combat/tile_icon/tile_truelch_500kg_airstrike.png"] = Point(-27, 2)

modApi:appendAsset("img/combat/tile_icon/tile_truelch_orbital_precision_strike.png", mod.resourcePath.."img/combat/tile_icon/tile_truelch_orbital_precision_strike.png")
	Location["combat/tile_icon/tile_truelch_orbital_precision_strike.png"] = Point(-27, 2)

modApi:appendAsset("img/combat/tile_icon/tile_truelch_orbital_walking_barrage.png", mod.resourcePath.."img/combat/tile_icon/tile_truelch_orbital_walking_barrage.png")
	Location["combat/tile_icon/tile_truelch_orbital_walking_barrage.png"] = Point(-27, 2)

for i = 0, 3 do
	modApi:appendAsset("img/combat/tile_icon/tile_truelch_orbital_walking_barrage_"..tostring(i)..".png", mod.resourcePath.."img/combat/tile_icon/tile_truelch_orbital_walking_barrage_"..tostring(i)..".png")
		Location["combat/tile_icon/tile_truelch_orbital_walking_barrage_"..tostring(i)..".png"] = Point(-27, 2)
end