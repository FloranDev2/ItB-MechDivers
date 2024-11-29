local this = {}
local mod = mod_loader.mods[modApi.currentMod]
local scriptPath = mod.scriptPath
local resourcePath = mod.resourcePath

-------------------- MODES' ICONS --------------------

modApi:appendAsset("img/modes/icon_resupply.png", resourcePath.."img/modes/icon_resupply.png")
modApi:appendAsset("img/modes/icon_strafe.png",   resourcePath.."img/modes/icon_strafe.png")

-------------------- MISC FUNCTIONS --------------------

local function attemptReload(pawn)
	if not pawn:IsEnemy() then
		--Reload
		pawn:ResetUses()
		Board:AddAlert(pawn:GetSpace(), "RELOADED!")
		--[[
		local weapons = pawn:GetPoweredWeapons()
		for j = 1, 2 do
		    if ??? then --is limited use weapon?

		    end
		end
		]]
	else
		--Destroy
		Board:AddAlert(pawn:GetSpace(), "DESTROYED")
	end
end

-------------------- ITEMS --------------------

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


-------------------- BOARD EVENTS --------------------

BoardEvents.onTerrainChanged:subscribe(function(p, terrain, terrain_prev)
	local item = Board:GetItem(p)
	if item == "truelch_Item_ResupplyPod" then
		if terrain == TERRAIN_HOLE or terrain == TERRAIN_WATER then
			Board:RemoveItem(p)
		end
	end
end)

BoardEvents.onItemRemoved:subscribe(function(loc, removed_item)
	if removed_item == "truelch_Item_ResupplyPod"  then
		local pawn = Board:GetPawn(loc)
		if pawn then
			attemptReload(pawn)
		end
	--elseif removed_item == "truelch_Item_ResupplyPod"  then
	end
end)


-------------------- MODE 1: Strafe run --------------------
	
truelch_DeliveryMode1 = {
	aFM_name = "Strafing run",					   -- required
	aFM_desc = "Leap over a tile and bombard it.", -- required
	aFM_icon = "img/modes/icon_strafe.png",        -- required (if you don't have an image an empty string will work) 
	-- aFM_limited = 2, 						   -- optional (FMW will automatically handle uses for weapons)
	-- aFM_handleLimited = false 				   -- optional (FMW will no longer automatically handle uses for this mode if set)
}

CreateClass(truelch_DeliveryMode1)

function truelch_DeliveryMode1:targeting(point)
	local points = {}
	for dir = DIR_START, DIR_END do
		local curr = DIR_VECTORS[dir]*2 + point
		if not Board:IsBlocked(curr, PATH_PROJECTILE) then
			points[#points+1] = curr
		end
	end
	return points
end

function truelch_DeliveryMode1:fire(p1, p2, se)
	local dir = GetDirection(p2 - p1)
	
	local move = PointList()
	move:push_back(p1)
	move:push_back(p2)
	
	se:AddBounce(p1, 2)

	se:AddLeap(move, 0.25)

	ret:AddDelay(0.5)


end


-------------------- MODE 2: Supply drop --------------------

truelch_DeliveryMode2 = truelch_DeliveryMode1:new{
	aFM_name = "Supply drop",
	aFM_desc = "Drop a Supply Box that reloads weapons.",
	aFM_icon = "img/modes/icon_resupply.png",
	aFM_limited = 2,
}

function truelch_DeliveryMode2:targeting(point)
	local points = {}
	for dir = DIR_START, DIR_END do
		local curr = DIR_VECTORS[dir]*2 + point
		if not Board:IsBlocked(curr, PATH_PROJECTILE) then
			points[#points+1] = curr
		end
	end
	return points
end

function truelch_DeliveryMode2:fire(p1, p2, se)
	local dir = GetDirection(p2 - p1)
	
	local move = PointList()
	move:push_back(p1)
	move:push_back(p2)
	
	se:AddBounce(p1, 2)

	se:AddLeap(move, 0.25)

	local middlePoint = p1 + DIR_VECTORS[dir]

	local pawn = Board:GetPawn(middlePoint)

	if not Board:IsBlocked(middlePoint, PATH_PROJECTILE) then
		local damage = SpaceDamage(middlePoint)
		damage.sImageMark = "combat/icons/icon_mind_glow.png" --TMP
		damage.sItem = "truelch_Item_ResupplyPod"
		se:AddDamage(damage)
	elseif pawn ~= nil then
		--attemptReload(pawn)
		--TODO: use AddScript stuff instead to avoid reload during preview!
	end
end


-------------------- WEAPON --------------------

truelch_Delivery = aFM_WeaponTemplate:new{
	Name = "Delivery",
	Description = "Drop various playloads.",
	Class = "Science",
	Icon = "weapons/truelch_delivery.png",
	Rarity = 1,
	PowerCost = 0,

    --TwoClick = true,
	LaunchSound = "/weapons/bomb_strafe",

	aFM_ModeList = { "truelch_DeliveryMode1", "truelch_DeliveryMode2" },
	aFM_ModeSwitchDesc = "Click to change Mortar shells.",

	TipImage = {
		Unit = Point(2, 2)
	}
}

function truelch_Delivery:GetTargetArea(point)
	local pl = PointList()
	local currentShell = _G[self:FM_GetMode(point)]
    
	if self:FM_CurrentModeReady(point) then 
		local points = currentShell:targeting(point)
		
		for _, p in ipairs(points) do
			pl:push_back(p)
		end
	end
	 
	return pl
end

function truelch_Delivery:GetSkillEffect(p1, p2)
	local se = SkillEffect()
	local currentShell = self:FM_GetMode(p1)
	
	if self:FM_CurrentModeReady(p1) then 
		_G[currentShell]:fire(p1, p2, se)
		--se:AddSound(_G[currentShell].impactsound)
	end

	return se
end

-------------------- TIP IMAGE CUSTOM --------------------



return this