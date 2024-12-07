-------------------- IMPORTS --------------------

local this = {}
local mod = mod_loader.mods[modApi.currentMod]
local scriptPath = mod.scriptPath
local resourcePath = mod.resourcePath

--FMW
local fmwApi = require(scriptPath.."fmw/api")


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

    --[[
    A list of tables storing:
    [1] Pawn's id (integer)
    [2] Weapon's status (list of tables)
    	-> foreach weapon:
    		-> [1]
    ]]
    if mission.truelch_MechDivers.beforeItemRecov == nil then
        mission.truelch_MechDivers.beforeItemRecov = {}
    end

    return mission.truelch_MechDivers
end

-------------------- MISC FUNCTIONS --------------------

--Return true if it actually reloaded the pawn, false otherwise?
function truelch_ItemReload(pawnId, ammoIncr)
	local pawn = Board:GetPawn(pawnId)
	if pawn == nil then
		return
	end

	LOG("truelch_ItemReload(pawn: "..pawn:GetMechName()..", ammoIncr: "..tostring(ammoIncr)..")")
	if not pawn:IsEnemy() then --this should be checked beforehand, but we never know...
		--Reload
		--TODO: FMW reload -> FM_SetUses
		--pawn:ResetUses() --lazy way

		local hasReloaded = false

		local weapons = pawn:GetPoweredWeapons()
		--or j = 1, 3 do --instead? (or even more)
		--that being said, 3rd weapon would be stratagem-acquired weapon which is temporary
		--and should be destroyed after use anyway
		--"Sir, we are meant to be expandables."
		for j = 1, 2 do
			LOG("-> weapon index j: "..tostring(j))
		    local fmw = fmwApi:GetSkill(pawn:GetId(), j, false)
		    if fmw ~= nil then
		    	--FMWeapon
		    	LOG(" ---> Is FMWeapon!")
		    	--Wait, I need to iterate over all modes, not only the current weapon's mode!
		    	-- Single mode --->		    	
		    	--local mode = fmw:FM_GetMode(pawn:GetId())
				--fmw:FM_AddUses(pawn:GetId(), mode, ammoIncr) --I hope it take account of the initial limit
				-- <--- Single mode

				LOG(" ------> modes:")
				for k = 1, #fmw.aFM_ModeList do
					local mode = weapon.aFM_ModeList[k]
					LOG(" ---------------> k: "..tostring(k)..", mode: "..tostring(mode).." (type: "..type(mode)..")")
					fmw:FM_AddUses(pawn:GetId(), mode, ammoIncr)
				end
			else
				--Regular weapon (non-FMW)
				LOG(" ---> Is regular weapon (non-FMW)")
				--local weapon = weapons[j] --useless?
			    if pawn:GetWeaponLimitedUses(j) > 0 then
			    	local currAmmo = pawn:GetWeaponLimitedRemaining(j)
			    	local maxAmmo = pawn:GetWeaponLimitedUses(j)
			    	local newAmmo = math.min(currAmmo + ammoIncr, maxAmmo)
			    	pawn:SetWeaponLimitedRemaining(j, newAmmo)
			    end
		    end
		end

		if hasReloaded == true then
			Board:AddAlert(pawn:GetSpace(), "RELOADED!")
		end
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
		if pawn ~= nil then
			if not pawn:IsEnemy() then
				truelch_ItemReload(pawn:GetId(), 1)
			else
				Board:AddAlert(loc, "DESTROYED")
			end
			--There can be a case where it's a friendly unit but that can't reload
			--Shame if it happens LOL
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

-------------------- HOOKS / EVENTS --------------------

local HOOK_PawnUndoMove = function(mission, pawn, undonePosition)
	LOG(pawn:GetMechName().." move was undone! Was at: "..undonePosition:GetString()..", returned to: "..pawn:GetSpace():GetString())

	local item = Board:GetItem(undonePosition)
	if item == "truelch_Item_ResupplyPod" then
		local weapons = pawn:GetPoweredWeapons()
		for j = 1, 2 do
			pawn:SetWeaponLimitedRemaining(j, 0) --tmp
		end
	elseif isHellPodItem(item) then --any hell pod item BUT resupply
		pawn:RemoveWeapon()
	end
end


local function EVENT_onModsLoaded()
	modapiext:addPawnUndoMoveHook(HOOK_PawnUndoMove)
end

modApi.events.onModsLoaded:subscribe(EVENT_onModsLoaded)