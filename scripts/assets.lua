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

--Items
--TMP
--[[
modApi:appendAsset("img/combat/item_truelch_supply_pod.png", resourcePath.."img/combat/item_truelch_supply_pod.png")
	Location["combat/item_truelch_supply_pod.png"] = Point(-15, 10) --28, 22
]]

--Note: this is also temporary; these effects are kinda like ENV icons
modApi:appendAsset("img/combat/blue_stratagem_grenade.png", resourcePath.."img/combat/blue_stratagem_grenade.png")
	Location["combat/blue_stratagem_grenade.png"] = Point(-7, -22) --14, 52

modApi:appendAsset("img/combat/red_stratagem_grenade.png", resourcePath.."img/combat/red_stratagem_grenade.png")
	Location["combat/red_stratagem_grenade.png"] = Point(-7, -22)

--Anims
modApi:appendAsset("img/effects/truelch_anim_pod_land.png", resourcePath.."img/effects/truelch_anim_pod_land.png")
	Location["effects/truelch_anim_pod_land.png"] = Point(-20, -40)

ANIMS.truelch_anim_pod_land = Animation:new{
	Image = "effects/truelch_anim_pod_land.png",
	PosX = -25, -- -20
	PosY = -165, -- -40
	Time = 0.04,
	NumFrames = 9,
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

--Trait icon
modApi:appendAsset("img/combat/icons/icon_protecc.png", resourcePath.."img/combat/icons/icon_protecc.png")
	Location["combat/icons/icon_protecc.png"] = Point(-12, 8)

--Artillery shotups
modApi:appendAsset("img/effects/truelch_shotup_stratagem_ball.png", resourcePath.."img/effects/truelch_shotup_stratagem_ball.png")

--Projectiles


--Weapons icons
modApi:appendAsset("img/weapons/truelch_delivery.png", resourcePath.."img/weapons/truelch_delivery.png")
modApi:appendAsset("img/weapons/truelch_reinforcement_passive.png", resourcePath.."img/weapons/truelch_reinforcement_passive.png")
modApi:appendAsset("img/weapons/truelch_dual_autocannon.png", resourcePath.."img/weapons/truelch_dual_autocannon.png")
modApi:appendAsset("img/weapons/truelch_patriot_weapons.png", resourcePath.."img/weapons/truelch_patriot_weapons.png")
modApi:appendAsset("img/weapons/truelch_stratagem.png", resourcePath.."img/weapons/truelch_stratagem.png")

--Animations