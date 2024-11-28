local mod = mod_loader.mods[modApi.currentMod]
local resourcePath = mod.resourcePath

--FMW modes icons (TODO)

--Weapons icons
modApi:appendAsset("img/weapons/truelch_delivery.png", resourcePath.."img/weapons/truelch_delivery.png")
modApi:appendAsset("img/weapons/truelch_reinforcement_passive.png", resourcePath.."img/weapons/truelch_reinforcement_passive.png")

--Animations