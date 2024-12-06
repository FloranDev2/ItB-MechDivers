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

--[[
local function missionData()
    local mission = GetCurrentMission()

    if mission.truelch_MechDivers == nil then
        mission.truelch_MechDivers = {}
    end

    if mission.truelch_MechDivers.weaponItems == nil then
        mission.truelch_MechDivers.weaponItems = {}
    end

    return mission.truelch_MechDivers
end
]]


-------------------- MISC FUNCTIONS --------------------

local function attemptReload(pawn)
	if not pawn:IsEnemy() then
		--Reload
		--TODO: FMW reload -> FM_SetUses
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

local hellPodItems =
{
	--Resupply
	"truelch_Item_ResupplyPod",
	--Weapons drops
	"truelch_Item_WeaponPod_Mg43",
	"truelch_Item_WeaponPod_Apw1",
	"truelch_Item_WeaponPod_Flam40",
}
local function isHellPodItem(item)
	for _, hellPodItem in pairs(hellPodItems) do
		if item == hellPodItem then
			return true
		end
	end
	return false
end


-------------------- ITEMS --------------------

--Maybe I'll move it to a separate file, because I *might* also do item drops for the Patriot and Emancipator when they're out of ammo
truelch_Item_ResupplyPod = {
	Image = "combat/blue_stratagem_grenade.png",
	Damage = SpaceDamage(0),
	Tooltip = "Item_Truelch_ResupplyPod_Text",
	Icon = "combat/icons/icon_mine_glow.png",
	UsedImage = ""
}
TILE_TOOLTIPS.Item_Truelch_ResupplyPod_Text = {"Supply Pod", "Pick it up to reload your weapons."}

--Maybe I'll move it to a separate file, because I *might* also do item drops for the Patriot and Emancipator when they're out of ammo
truelch_Item_WeaponPod_Mg43 = {
	Image = "combat/blue_stratagem_grenade.png",
	Damage = SpaceDamage(0),
	Tooltip = "Item_Truelch_WeaponPod_Mg43_Text",
	Icon = "combat/icons/icon_mine_glow.png",
	UsedImage = ""
}
TILE_TOOLTIPS.Item_Truelch_WeaponPod_Mg43_Text = {"MG-43 Pod", "Pick it up to get a MG-43 Machine Gun."}

truelch_Item_WeaponPod_Apw1 = {
	Image = "combat/blue_stratagem_grenade.png",
	Damage = SpaceDamage(0),
	Tooltip = "Item_Truelch_WeaponPod_Apw1_Text",
	Icon = "combat/icons/icon_mine_glow.png",
	UsedImage = ""
}
TILE_TOOLTIPS.Item_Truelch_WeaponPod_Apw1_Text = {"APW-1 Pod", "Pick it up to get a APW-1 Anti-Materiel Rifle."}

truelch_Item_WeaponPod_Flam40 = {
	Image = "combat/blue_stratagem_grenade.png",
	Damage = SpaceDamage(0),
	Tooltip = "Item_Truelch_WeaponPod_Apw1_Text",
	Icon = "combat/icons/icon_mine_glow.png",
	UsedImage = ""
}
TILE_TOOLTIPS.Item_Truelch_WeaponPod_Apw1_Text = {"APW-1 Pod", "Pick it up to get a APW-1 Anti-Materiel Rifle."}

-------------------- BOARD EVENTS --------------------

BoardEvents.onTerrainChanged:subscribe(function(p, terrain, terrain_prev)
	local item = Board:GetItem(p)
	--if item == "truelch_Item_ResupplyPod" or item == "truelch_Item_WeaponPod_Mg43" then
	if isHellPodItem(item) then
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
	elseif removed_item == "truelch_Item_WeaponPod_Mg43" then
		local pawn = Board:GetPawn(loc)
		if pawn ~= nil then
			pawn:AddWeapon("truelch_mg43MachineGun")
			Board:AddAlert(loc, "Acquired a MG-43 Machine Gun!")
		end
	elseif removed_item == "truelch_Item_WeaponPod_Apw1" then
		local pawn = Board:GetPawn(loc)
		if pawn ~= nil then
			pawn:AddWeapon("truelch_apw1AntiMaterielRifle")
			Board:AddAlert(loc, "Acquired an APW-1 Anti-Materiel Rifle!")
		end
	elseif removed_item == "truelch_Item_WeaponPod_Flam40" then
		local pawn = Board:GetPawn(loc)
		if pawn ~= nil then
			pawn:AddWeapon("truelch_flam40Flamethrower")
			Board:AddAlert(loc, "Acquired a FLAM-40 Flamethrower!")
		end
	end
end)