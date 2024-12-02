-------------------- IMPORTS --------------------

local this = {}
local mod = mod_loader.mods[modApi.currentMod]
local scriptPath = mod.scriptPath
local resourcePath = mod.resourcePath

----------------------------------------------- MISSION / GAME FUNCTIONS -----------------------------------------------

local function isGame()
    return true
        and Game ~= nil
        and GAME ~= nil
end

local function isMission()
    local mission = GetCurrentMission()

    return true
        and isGame()
        and mission ~= nil
        and mission ~= Mission_Test
end

local function missionData()
    local mission = GetCurrentMission()

    if mission.truelch_MechDivers == nil then
        mission.truelch_MechDivers = {}
    end

    if mission.truelch_MechDivers.WeaponItems == nil then
        mission.truelch_MechDivers.WeaponItems = {}
    end

    return mission.truelch_MechDivers
end



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
modApi:appendAsset("img/combat/item_truelch_supply_pod.png", resourcePath.."img/combat/item_truelch_supply_pod.png")
	Location["combat/item_truelch_supply_pod.png"] = Point(-15, 10)

--Maybe I'll move it to a separate file, because I *might* also do item drops for the Patriot and Emancipator when they're out of ammo
truelch_Item_WeaponPod = {
	Image = "combat/item_truelch_supply_pod.png",
	Damage = SpaceDamage(0),
	Tooltip = "Item_Truelch_WeaponDrop_Text",
	Icon = "combat/icons/icon_mine_glow.png",
	UsedImage = ""
}

TILE_TOOLTIPS.Item_Truelch_WeaponDrop_Text = {"Weapon Pod", "Pick it up to put a new weapon in the second slot."}


-------------------- BOARD EVENTS --------------------

BoardEvents.onTerrainChanged:subscribe(function(p, terrain, terrain_prev)
	local item = Board:GetItem(p)
	if item == "truelch_Item_ResupplyPod" or item == "truelch_Item_WeaponPod" then
		if terrain == TERRAIN_HOLE or terrain == TERRAIN_WATER then
			Board:RemoveItem(p)
		end
	end
end)

BoardEvents.onItemRemoved:subscribe(function(loc, removed_item)
	if removed_item == "truelch_Item_ResupplyPod" then
		local pawn = Board:GetPawn(loc)
		if pawn then
			attemptReload(pawn)
		end
	elseif removed_item == "truelch_Item_WeaponPod" then
		--TODO: store in mission data in what weapon is at each pod position
		local pawn = Board:GetPawn(loc)
		--pawn:RemoveWeapon(2)
		pawn:AddWeapon("truelch_mg43MachineGun")
		Board:AddAlert(loc, "Acquired a MG-43 Machine Gun!")
	end
end)
