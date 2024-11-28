-------------------- IMPORTS --------------------

local resourcePath = mod_loader.mods[modApi.currentMod].resourcePath


-------------------- FUNCTIONS --------------------

local function isValidPos(p)
	local isValid = true
		and Board:IsValid(p)
		and not Board:IsBlocked(p, PATH_PROJECTILE)
		and Board:GetTerrain(p) ~= TERRAIN_WATER
		and Board:GetTerrain(p) ~= TERRAIN_HOLE
		and Board:IsAcid(p) == false
		and Board:IsFire(p) == false
	return isValid
end


-------------------- ITEMS --------------------

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
	--elseif removed_item == "truelch_Item_ResupplyPod"  then
	end
end)


-------------------- WEAPON --------------------

--Maybe do a leap attack that drops the item, and if the Mech is below, it actually instantly give the Pod to the Mech.
truelch_StratagemsDrop = Skill:new{
	--Infos
	Name = "Stratagems' Drop",
	Description = "Drop a weapon that can be used by an ally so it can.",
	Class = "Science",
	Icon = "weapons/brute_boosters.png", --tmp

	--Shop
	Rarity = 1,
	PowerCost = 0,
	--Upgrades = 2,
	--UpgradeCost = { 1, 2 },

	--Items
	Item = "truelch_Item_ResupplyPod",

	--Tip image
	--[[
	TipImage = {
		Unit   = Point(2, 2),
		Enemy  = Point(2, 1),
		Enemy2 = Point(1, 1),
		Target = Point(2, 1),
		CustomPawn = "truelch_BurrowerMech",

        Second_Origin = Point(2, 2),
        Second_Target = Point(3, 2),
        Building = Point(3, 2),
        Enemy3 = Point(3, 3),
	}
	]]
}

function truelch_StratagemsDrop:GetTargetArea(point)
	local ret = PointList()

	for j = 0, 7 do
		for i = 0, 7 do
			local curr = Point(i, j)
			if not Board:IsBlocked(curr, PATH_PROJECTILE) then
				ret:push_back(curr)
			end
		end
	end
	
	return ret
end

--useless?
function truelch_StratagemsDrop:GetSkillEffect(p1, p2)
	local ret = SkillEffect()

	local damage = SpaceDamage(p2)
	damage.sImageMark = "combat/icons/icon_mind_glow.png" --tmp
	damage.sItem = self.Item
	ret:AddDamage(damage)
	
	return ret
end