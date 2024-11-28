-------------------- IMPORTS --------------------

local this = {}
local mod = mod_loader.mods[modApi.currentMod]
local scriptPath = mod.scriptPath
local resourcePath = mod.resourcePath
local fmw = require(scriptPath.."fmw/api")


-------------------- SPRITES --------------------

modApi:appendAsset("img/modes/icon_resupply.png", resourcePath.."img/modes/icon_resupply.png")
modApi:appendAsset("img/modes/icon_strafe.png",   resourcePath.."img/modes/icon_strafe.png")


-------------------- ITEMS --------------------

--[[
--- Resupply Pod
modApi:appendAsset("img/combat/item_truelch_supply_pod.png", resourcePath.."img/combat/item_truelch_supply_pod.png")
	Location["combat/item_truelch_supply_pod.png"] = Point(-15, 10)

--Maybe I'll move it to a separate file, because I *might* also do item drops for the Patriot and Emancipator when they're out of ammo
truelch_Item_ResupplyPod = {
	Image = "combat/item_truelch_supply_pod.png",
	Damage = SpaceDamage(0),
	Tooltip = "Item_Truelch_ResupplyDrop_Text",
	Icon = "combat/icons/icon_mine_glow.png",
	UsedImage = ""
}

TILE_TOOLTIPS.Item_Truelch_ResupplyDrop_Text = {"Supply Pod", "Pick it up to reload your weapons."}

--- Weapon Pod
]]

-------------------- MODE 1: Strafe run --------------------

truelch_DeliveryMode1 = {
	aFM_name = "Strafing run",
	aFM_desc = "Bombing run",
	aFM_icon = "img/modes/icon_strafe.png",
	--aFM_limited = 2,
}

CreateClass(truelch_DeliveryMode1)

function truelch_DeliveryMode1:targeting(point)
	local points = {}
	for dir = DIR_START, DIR_END do
		local curr = point + 2 * DIR_VECTORS[dir]
		if not Board:IsBlocked(curr, PATH_PROJECTILE) then
			points[#points+1] = curr
		end
	end
	return points
end

function truelch_DeliveryMode1:fire(p1, p2, ret)
	local dir = GetDirection(p2 - p1)
	
	local move = PointList()
	move:push_back(p1)
	move:push_back(p2)
	
	local distance = p1:Manhattan(p2)
	
	ret:AddBounce(p1,2)
	if distance == 1 then
		ret:AddLeap(move, 0.5)--small delay between move and the damage, attempting to make the damage appear when jet is overhead
	else
		ret:AddLeap(move, 0.25)
	end

	--[[	
	for k = 1, (self.Range-1) do
		if p1 + DIR_VECTORS[dir]*k == p2 then
			break
		end

		--damage

		local animSpaceDamage = SpaceDamage(p1 + DIR_VECTORS[dir]*k, 0)
		animSpaceDamage.sAnimation = self.AttackAnimation..tostring(dir)
		ret:AddDamage(animSpaceDamage)

		ret:AddDelay(0.2)

		local pullDir = GetDirection(p1 - p2)
		local damage = SpaceDamage(p1 + DIR_VECTORS[dir]*k, self.Damage, pullDir) --has pull directly in the main damage
		damage.iFire = self.Fire
		damage.sSound = self.BombSound
		ret:AddDamage(damage)

		--bounce
		ret:AddBounce(p1 + DIR_VECTORS[dir]*k,3)
	end
	]]
end

-------------------- MODE 2: Supply drop --------------------

truelch_DeliveryMode2 = truelch_DeliveryMode1:new{
	aFM_name = "Supply drop",
	aFM_desc = "Drop a Supply Box that reloads weapons.",
	aFM_icon = "img/modes/icon_resupply.png",
	--aFM_limited = 2,
}

function truelch_DeliveryMode2:targeting(point)
	local points = {}
	for dir = DIR_START, DIR_END do
		local curr = point + 2 * DIR_VECTORS[dir]
		if not Board:IsBlocked(curr, PATH_PROJECTILE) then
			points[#points+1] = curr
		end
	end
	return points
end

function truelch_DeliveryMode2:fire(p1, p2, ret)
	local dir = GetDirection(p2 - p1)
	
	local move = PointList()
	move:push_back(p1)
	move:push_back(p2)
	
	local distance = p1:Manhattan(p2)
	
	ret:AddBounce(p1, 2)
	if distance == 1 then
		ret:AddLeap(move, 0.5)--small delay between move and the damage, attempting to make the damage appear when jet is overhead
	else
		ret:AddLeap(move, 0.25)
	end

	--[[		
	for k = 1, (self.Range-1) do

		if p1 + DIR_VECTORS[dir]*k == p2 then
			break
		end

		--damage

		local animSpaceDamage = SpaceDamage(p1 + DIR_VECTORS[dir]*k, 0)
		animSpaceDamage.sAnimation = self.AttackAnimation..tostring(dir)
		ret:AddDamage(animSpaceDamage)

		ret:AddDelay(0.2)

		local pullDir = GetDirection(p1 - p2)
		local damage = SpaceDamage(p1 + DIR_VECTORS[dir]*k, self.Damage, pullDir) --has pull directly in the main damage
		damage.iFire = self.Fire
		damage.sSound = self.BombSound
		ret:AddDamage(damage)

		--bounce
		ret:AddBounce(p1 + DIR_VECTORS[dir]*k,3)
		
	end
	]]
end


-------------------- WEAPON --------------------

truelch_Delivery = aFM_WeaponTemplate:new{
	--Infos
	Name = "Delivery",
	Description = "Drop various playloads.",
	Class = "Science",	
	Icon = "weapons/truelch_delivery.png", --TODO
	Rarity = 1,
	PowerCost = 0,

	--Upgrades
	--Upgrades = 2,
	--UpgradeCost = { 1, 2 },

	--FMW
	aFM_ModeList = { "truelch_Mode1" --[[, "truelch_Mode2"]] },
	aFM_ModeSwitchDesc = "Click to change mode.",

	--Gameplay

	--Tip image
	--TipImage = StandardTips.Ranged,
}

--[[
Weapon_Texts.truelch_Delivery_Upgrade1 = "Upgrade 1"
Weapon_Texts.truelch_Delivery_Upgrade2 = "Upgrade 2"

truelch_Delivery_A = truelch_Delivery:new{
	UpgradeDescription = "Description 1",
}

truelch_Delivery_B = truelch_Delivery:new{
	UpgradeDescription = "Description 2",
}

truelch_Delivery_AB = truelch_Delivery:new{
}
]]

function truelch_Delivery:GetTargetArea(point)
	LOG("truelch_Delivery:GetTargetArea")
	local pl = PointList()
	
	--[[
	local mission = GetCurrentMission()
	if mission and not Board:IsTipImage() and not IsTestMechScenario() then
		tips:Trigger("M6GunFMW", point)
	end
	]]

	local currentMode = _G[self:FM_GetMode(point)]
	if self:FM_CurrentModeReady(point) then
		local points = currentMode:targeting(point)
		for _, p in ipairs(points) do
			pl:push_back(p)
		end
	end
	return pl
end

function truelch_Delivery:GetSkillEffect(p1, p2)
	LOG("truelch_Delivery:GetSkillEffect")
	local se = SkillEffect()
	local currentMode = self:FM_GetMode(p1)
	
	if self:FM_CurrentModeReady(p1) then 
		_G[currentMode]:fire(p1, p2, se)
	end

	return se
end