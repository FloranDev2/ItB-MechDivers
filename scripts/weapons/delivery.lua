-------------------- IMPORTS --------------------

local this = {}
local mod = mod_loader.mods[modApi.currentMod]
local scriptPath = mod.scriptPath
local resourcePath = mod.resourcePath


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
		damage.sImageMark = "combat/icons/icon_resupply.png"
		damage.sItem = "truelch_Item_ResupplyPod"
		se:AddDamage(damage)
	elseif pawn ~= nil then
		local damage = SpaceDamage(middlePoint)
		damage.sImageMark = "combat/icons/icon_resupply.png"
		se:AddDamage(damage)
		se:AddScript([[
			Board:AddAlert(]]..middlePoint:GetString()..[[, "RELOADED")
			pawn:ResetUses()
		]])
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
	aFM_ModeSwitchDesc = "Click to change mode.",

	TipImage = {
		Unit = Point(2, 2)
	}
}

function truelch_Delivery:GetTargetArea(point)
	local pl = PointList()
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
	local se = SkillEffect()
	local currentMode = self:FM_GetMode(p1)
	
	if self:FM_CurrentModeReady(p1) then
		_G[currentMode]:fire(p1, p2, se)
		--se:AddSound(_G[currentMode].impactsound)
	end

	return se
end

-------------------- TIP IMAGE CUSTOM --------------------



return this