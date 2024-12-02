-------------------- IMPORTS --------------------

local this = {}
local mod = mod_loader.mods[modApi.currentMod]
local scriptPath = mod.scriptPath
local resourcePath = mod.resourcePath


-------------------- MODE 1: Strafe run --------------------
	
truelch_DeliveryMode1 = {
	aFM_name = "Strafing run",
	--aFM_desc = "Leap over a tile, shooting any toward any direction there's a unit (enemy AND ally!).",
	aFM_desc = "Leap over a tile, shooting sideways if there's a unit (enemy or ally).",
	aFM_icon = "img/modes/icon_strafe.png",
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

	se:AddDelay(0.5)
	
	for dir = DIR_START, DIR_END do
		local damage = SpaceDamage(p1)
		local target = GetProjectileEnd(p1, p2)
		
	end
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
		Unit   = Point(1, 2),
		Target = Point(3, 2),
		CustomPawn = "truelch_EagleMech",
	}
}


-------------------- GET TARGET AREA --------------------

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

-------------------- TIP IMAGE --------------------

--custom tip image index
local tipIndex = 0

function truelch_Delivery:GIE_TI0(p1, p2)
	local ret = SkillEffect()

	tipIndex = 1
	return ret
end

function truelch_Delivery:GIE_TI1(p1, p2)
	local ret = SkillEffect()

	tipIndex = 0 --tmp
	return ret
end

function truelch_Delivery:GetSkillEffect_TipImage(p1, p2)
	if tipIndex == 0 then
		return self:GIE_TI0(p1, p2)
	elseif tipIndex == 1 then
		return self:GIE_TI1(p1, p2)
	else
		--tipIndex == 0 --for safety
		return self:GIE_TI0(p1, p2)
	end
end

function truelch_Delivery:GetSkillEffect_Normal(p1, p2)
	local se = SkillEffect()
	local currentMode = self:FM_GetMode(p1)
	
	if self:FM_CurrentModeReady(p1) then
		_G[currentMode]:fire(p1, p2, se)
		--se:AddSound(_G[currentMode].impactsound)
	end

	return se
end

function truelch_Delivery:GetSkillEffect(p1, p2)
	if not Board:IsTipImage() then
		return self:GetSkillEffect_Normal(p1, p2)
	else
		return self:GetSkillEffect_TipImage(p1, p2)
	end
end

return this