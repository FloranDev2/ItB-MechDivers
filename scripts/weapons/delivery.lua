-------------------- IMPORTS --------------------

local this = {}
local mod = mod_loader.mods[modApi.currentMod]
local scriptPath = mod.scriptPath
local resourcePath = mod.resourcePath


-------------------- MODE 1: Strafe run --------------------
	
truelch_DeliveryMode1 = {
	aFM_name = "Strafing run",
	--aFM_desc = "Leap over a tile, shooting any toward any direction there's a unit (enemy AND ally!).",
	--aFM_desc = "Leap over a tile, shooting sideways if there's a unit (enemy or ally).",
	--New idea: just raw damage around the unit. The damage is a flat amount, reduce my the numbers of enemies
	--So you have some control; do you want to deal more damage to a single target or spread it?
	--I'm also doing this because the squad is already overloaded with pushing projectiles
	aFM_desc = "Fly forward, shooting all units and buildings that were under the fly path or adjacent."..
		"\nDamage is reduced by the amount of units and buildings hit (minimum: 1).",
	aFM_icon = "img/modes/icon_strafe.png",

	LeapMaxRange = 3,
	FrontDamage = false, --not sure about that
	BackDamage = false, --I'm 95% sure I should keep it disabled
}

CreateClass(truelch_DeliveryMode1)

function truelch_DeliveryMode1:targeting(point)
	local points = {}

	for dir = DIR_START, DIR_END do
		for i = 1, self.LeapMaxRange do
			local curr = DIR_VECTORS[dir]*i + point
			if not Board:IsBlocked(curr, PATH_PROJECTILE) then
				points[#points+1] = curr
			end
		end
	end

	return points
end

function truelch_DeliveryMode1:addLateralPoints(list, point, p1, p2, dmg)
	local dir = GetDirection(p2 - p1)
	for i = -1, 1 do
		local curr = point + DIR_VECTORS[(dir + 1)% 4]*i
		if Board:IsValid(curr) and not list_contains(list, curr) and
			curr ~= p1 and curr ~= p2 then
			list[#list+1] = curr
			if (Board:IsPawnSpace(curr) or Board:IsBuilding(curr)) and dmg > 1 then
				dmg = dmg - 1
			end
		end
	end
	return dmg --not a reference so modifying dmg here just modify local copy it seems
end

function truelch_DeliveryMode1:fire(p1, p2, se)
	--LOG("truelch_DeliveryMode1:fire(p1: "..p1:GetString()..", p2:"..p2:GetString()..")")
	local dir = GetDirection(p2 - p1)
	local move = PointList()
	move:push_back(p1)
	move:push_back(p2)
	se:AddBounce(p1, 2)
	se:AddLeap(move, 0.25)
	
	--AoE
	local dmg = 4 --will never be 4 anyway, for just one unit, it's 3 damage

	--Path
	path = {}
	cond = true
	local whileLimit = 7
	local curr = p1

	path[#path+1] = curr

	while cond do
		curr = curr + DIR_VECTORS[dir]

		path[#path+1] = curr

		if curr == p2 then
			cond = false
		end

		--Hard stop to avoid infinite loop. Hopefully it will never happen
		whileLimit = whileLimit - 1
		if whileLimit == 0 then
			LOG("--------- END: hard limit (not nice!)")
			cond = false
		end
	end


	--Calculate points that need to be damaged + damage calculation
	list = {}

	if self.BackDamage then
		dmg = self:addLateralPoints(list, p1 - DIR_VECTORS[dir], dir, dmg)
	end

	--Path (start -> end rows)
	for _, pathPoint in ipairs(path) do
		dmg = self:addLateralPoints(list, pathPoint, p1, p2, dmg)
	end

	if self.FrontDamage then
		dmg = self:addLateralPoints(list, p2 + DIR_VECTORS[dir], p1, p2, dmg)
	end

	--Apply damage
	local prevLoc
	for _, point in ipairs(list) do
		local spaceDamage = SpaceDamage(point, dmg)
		spaceDamage.sAnimation = "ExploRaining1"
		spaceDamage.sSound = "/general/combat/stun_explode"
		se:AddDamage(spaceDamage)
		se:AddBounce(point, 2) --test

		--dir == 1 or 3: x move / dir == 0 or 2: y move
		if prevLoc ~= nil and ((dir%2 == 1 and prevLoc.x ~= point.x) or (dir%2 == 0 and prevLoc.y ~= point.y)) then
			se:AddDelay(0.2)
		end

		--Hopefully, I added points in the right order so that I never move back
		prevLoc = point
	end

	--Also add (negative?) bounce on arrival
	se:AddBounce(p2, 2)
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
	--Infos
	Name = "Delivery",
	Description = "Drop various playloads.",
	Class = "Science",
	Rarity = 1,
	PowerCost = 0,

	--Art
	Icon = "weapons/truelch_delivery.png",

    --TwoClick = true,
	LaunchSound = "/weapons/bomb_strafe",

	--FMW
	aFM_ModeList = { "truelch_DeliveryMode1", "truelch_DeliveryMode2" },
	aFM_ModeSwitchDesc = "Click to change mode.",

	--Upgrades

	--Tip image
	TipIndex = 0,
	TipImage = {
		Unit       = Point(1, 2),
		Enemy      = Point(2, 3),
		Friendly   = Point(2, 1),
		Target     = Point(3, 2),
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

function truelch_Delivery:GIE_TI0(p1, p2)
	local ret = SkillEffect()
	return ret
end

function truelch_Delivery:GIE_TI1(p1, p2)
	local ret = SkillEffect()
	return ret
end

function truelch_Delivery:GetSkillEffect_TipImage(p1, p2)
	if tipIndex == 1 then
		self.TipIndex = 0
		return self:GIE_TI1(p1, p2)
	else
		self.TipIndex = 1
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