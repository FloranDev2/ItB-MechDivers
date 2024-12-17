-------------------- IMPORTS --------------------

local this = {}
local mod = mod_loader.mods[modApi.currentMod]
local scriptPath = mod.scriptPath
local resourcePath = mod.resourcePath


-------------------- MODE 1: Strafe run --------------------
	
truelch_DeliveryMode1 = {
	aFM_name = "Strafing run",
	aFM_desc = "Fly forward, shooting all units and buildings that were under the fly path or adjacent."..
		"\nDamage is reduced by the amount of units and buildings hit (minimum: 1).",
	aFM_icon = "img/modes/icon_strafe.png",

	BaseDamage = 4,
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
			--[[
			else
				break --No!
			]]
			end
		end
	end

	return points
end

function truelch_DeliveryMode1:addLateralPoints(list, point, p1, p2, dmgVsUnits, dmgVsBuildings, minDmgVsUnits, minDmgVsBuildings)
	local dir = GetDirection(p2 - p1)
	for i = -1, 1 do
		local curr = point + DIR_VECTORS[(dir + 1)% 4]*i
		if Board:IsValid(curr) and not list_contains(list, curr) and
			curr ~= p1 and curr ~= p2 then
			list[#list+1] = curr
			if Board:IsPawnSpace(curr) or Board:IsBuilding(curr) then
				if dmgVsUnits > minDmgVsUnits then
					dmgVsUnits = dmgVsUnits - 1
				end
				if dmgVsBuildings > minDmgVsBuildings then
					dmgVsBuildings = dmgVsBuildings - 1
				end
			end
		end
	end
	return dmgVsUnits, dmgVsBuildings
end

function truelch_DeliveryMode1:fire(p1, p2, se, up1, up2)
	--LOG("truelch_DeliveryMode1:fire(p1: "..p1:GetString()..", p2:"..p2:GetString()..")")
	local dir = GetDirection(p2 - p1)
	local move = PointList()
	move:push_back(p1)
	move:push_back(p2)
	se:AddBounce(p1, 2)
	se:AddLeap(move, 0.25)
	
	--AoE damage. Will never be 4 anyway, for just one unit, it's 3 damage
	local dmgVsUnits = self.BaseDamage 
	local dmgVsBuildings = self.BaseDamage
	if up2 then
		dmgVsUnits = dmgVsUnits + 1
		dmgVsBuildings = dmgVsBuildings + 1
	end

	local minDmgVsUnits = 1
	local minDmgVsBuildings = 1
	if up1 then
		minDmgVsBuildings = 0
	end

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
		dmgVsUnits, dmgVsBuildings = self:addLateralPoints(list, p1 - DIR_VECTORS[dir], p1, p2,
			dmgVsUnits, dmgVsBuildings, minDmgVsUnits, minDmgVsBuildings)
	end

	--Path (start -> end rows)
	for _, pathPoint in ipairs(path) do
		dmgVsUnits, dmgVsBuildings = self:addLateralPoints(list, pathPoint, p1, p2,
			dmgVsUnits, dmgVsBuildings, minDmgVsUnits, minDmgVsBuildings)
	end

	if self.FrontDamage then
		dmgVsUnits, dmgVsBuildings = self:addLateralPoints(list, p2 + DIR_VECTORS[dir], p1, p2,
			dmgVsUnits, dmgVsBuildings, minDmgVsUnits, minDmgVsBuildings)
	end

	--Apply damage
	local prevLoc
	for _, point in ipairs(list) do
		local dmg = 0
		if Board:IsBuilding(point) then
			dmg = dmgVsBuildings
		else --in any other case, we want to damage the tile (empty tile, damaging forest, ice, sand, etc.)
			dmg = dmgVsUnits
		end

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

function truelch_DeliveryMode2:fire(p1, p2, se, up1, up2)
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
		damage.sImageMark = "combat/icons/icon_ammo_glow.png"
		damage.sItem = "truelch_Item_ResupplyPod"
		se:AddDamage(damage)
	elseif pawn ~= nil then
		local damage = SpaceDamage(middlePoint)
		damage.sImageMark = "combat/icons/icon_ammo_glow.png"
		se:AddDamage(damage)

		--Lazy reload
		--se:AddScript([[
		--	Board:AddAlert(]]..middlePoint:GetString()..[[, "RELOADED")
		--	pawn:ResetUses()
		--]])

		--(Way) better reload: (oh also, I really need to get started on using string format!)
		se:AddScript([[truelch_ItemReload(]]..tostring(pawn:GetId())..[[, 1)]])
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
	Upgrades = 2,
	UpgradeCost = { 1, 3 },
	Up1 = false,
	Up2 = false,

	--Tip image
	TipIndex = 0,
	TipImage = {
		Unit      = Point(1, 0),
		Enemy     = Point(2, 1),
		Friendly  = Point(2, 3),
		Building  = Point(3, 1),
		Target    = Point(1, 2),
		Second_Origin = Point(1, 2),
		Second_Target = Point(3, 2),
		CustomPawn = "truelch_EagleMech",
	}
}

Weapon_Texts.truelch_Delivery_Upgrade1 = "Building Damage"
Weapon_Texts.truelch_Delivery_Upgrade2 = "+1 Range and Dmg"

truelch_Delivery_A = truelch_Delivery:new{
    UpgradeDescription = "Strafing run: damage taken by buildings can be reduced to zero.",
    Up1 = true,
}

truelch_Delivery_B = truelch_Delivery:new{
    UpgradeDescription = "Strafing run: +1 damage.\nBoth: leap can be 1 tile longer.",
    Up2 = true,
}

truelch_Delivery_AB = truelch_Delivery:new{
    Up1 = true,
    Up2 = true,
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
	if self.TipIndex == 1 then
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
		_G[currentMode]:fire(p1, p2, se, self.Up1, self.Up2)
	end

	return se
end

function truelch_Delivery:GetSkillEffect(p1, p2)
	return self:GetSkillEffect_Normal(p1, p2)
	--[[
	if not Board:IsTipImage() then
		return self:GetSkillEffect_Normal(p1, p2)
	else
		return self:GetSkillEffect_TipImage(p1, p2)
	end
	]]
end

return this