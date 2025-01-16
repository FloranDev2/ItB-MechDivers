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

    --[1] Pawn id   [2] Weapon index (of the stratagem weapon to remove)
    --if mission.truelch_MechDivers.stratWeapsToRemove == nil then
	--	mission.truelch_MechDivers.stratWeapsToRemove = {}
    --end

    return mission.truelch_MechDivers
end

--Debug test
--[[
local beforeItemRecov = {}
beforeItemRecov[42] = {"A", "B"}
beforeItemRecov[43] = {"C", "D"}

LOG("beforeItemRecov count: "..tostring(#beforeItemRecov))
LOG("beforeItemRecov: "..tostring(beforeItemRecov))
LOG("beforeItemRecov[42]: "..tostring(beforeItemRecov[42]))

for _, elem in pairs(beforeItemRecov) do
	LOG("elem: "..tostring(elem))
	LOG("elem[0]: "..tostring(elem[0])) --nil (yes lua is weird)
	LOG("elem[1]: "..tostring(elem[1])) --"A"
end
]]

-------------------- MISC FUNCTIONS --------------------

--Return true if it actually reloaded the pawn, false otherwise?
function truelch_ItemReload(pawnId, ammoIncr)
	local pawn = Board:GetPawn(pawnId)
	if pawn == nil then
		return
	end

	--LOG("truelch_ItemReload(pawn: "..pawn:GetMechName()..", ammoIncr: "..tostring(ammoIncr)..")")
	if not pawn:IsEnemy() then --this should be checked beforehand, but we never know...
		--Reload
		local hasReloaded = false
		local weapons = pawn:GetPoweredWeapons()

		missionData().beforeItemRecov[pawn:GetId()] = {}

		--that being said, 3rd weapon would be stratagem-acquired weapon which is temporary
		--and should be destroyed after use anyway
		--"Sir, we are meant to be expandables."
		for j = 1, #weapons do
		    --local fmw = fmwApi:GetSkill(pawn:GetId(), j, false)
		    local fmw = fmwApi:GetSkill(pawn:GetId(), j) --taking inspiration from FMW.lua, line 45
		    if fmw ~= nil then
		    	--FMWeapon
		    	missionData().beforeItemRecov[pawn:GetId()][j] = {} --Save for undo move
				for k = 1, #_G[weapon].aFM_ModeList do --no idea if I should use weapon or fmw there, I think it's the latter
					--local mode = weapon.aFM_ModeList[k] --this?
					local mode = fmw.aFM_ModeList[k] --or this?
					missionData().beforeItemRecov[pawn:GetId()][j][k] = fmw:FM_GetUses(pawn:GetId(), mode)
					fmw:FM_AddUses(pawn:GetId(), mode, ammoIncr)
					hasReloaded = true
				end
			else
				--Regular weapon (non-FMW)
			    if pawn:GetWeaponLimitedUses(j) > 0 then
			    	local currAmmo = pawn:GetWeaponLimitedRemaining(j)			    	
			    	missionData().beforeItemRecov[pawn:GetId()][j] = currAmmo --Save for undo move
			    	local maxAmmo = pawn:GetWeaponLimitedUses(j)
			    	local newAmmo = math.min(currAmmo + ammoIncr, maxAmmo)
			    	pawn:SetWeaponLimitedRemaining(j, newAmmo)
			    	hasReloaded = true
			    end
		    end
		end

		--TODO: also check if the current amount of ammo was actually strictly inferior to the max ammo? Too lazy to do that for now
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
	"truelch_Item_WeaponPod_Rs422",
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
	Image = "combat/item_ammo.png", --"combat/blue_stratagem_grenade.png"
	Damage = SpaceDamage(0),
	Tooltip = "Item_Truelch_ResupplyPod_Text",
	Icon = "combat/icons/icon_mine_glow.png", --"combat/icons/icon_mine_glow.png"
	UsedImage = ""
}
TILE_TOOLTIPS.Item_Truelch_ResupplyPod_Text = {"Supply Pod", "Pick it up to reload your weapons."}

--Maybe I'll move it to a separate file, because I *might* also do item drops for the Patriot and Emancipator when they're out of ammo
truelch_Item_WeaponPod_Mg43 = {
	Image = "combat/item_mg43.png",
	Damage = SpaceDamage(0),
	Tooltip = "Item_Truelch_WeaponPod_Mg43_Text",
	Icon = "combat/icons/icon_mine_glow.png",
	UsedImage = ""
}
TILE_TOOLTIPS.Item_Truelch_WeaponPod_Mg43_Text = {"MG-43 Pod", "Pick it up to get a MG-43 Machine Gun."}

truelch_Item_WeaponPod_Apw1 = {
	Image = "combat/item_apw1.png",
	Damage = SpaceDamage(0),
	Tooltip = "Item_Truelch_WeaponPod_Apw1_Text",
	Icon = "combat/icons/icon_mine_glow.png",
	UsedImage = ""
}
TILE_TOOLTIPS.Item_Truelch_WeaponPod_Apw1_Text = {"APW-1 Pod", "Pick it up to get a APW-1 Anti-Materiel Rifle."}

truelch_Item_WeaponPod_Flam40 = {
	Image = "combat/item_flam40.png",
	Damage = SpaceDamage(0),
	Tooltip = "Item_Truelch_WeaponPod_Flam40_Text",
	Icon = "combat/icons/icon_mine_glow.png",
	UsedImage = ""
}
TILE_TOOLTIPS.Item_Truelch_WeaponPod_Flam40_Text = {"FLAM-40 Pod", "Pick it up to get a FLAM-40 Flamethrower."}

--RS-422 Railgun
truelch_Item_WeaponPod_Rs422 = {
	Image = "combat/item_rs422.png",
	Damage = SpaceDamage(0),
	Tooltip = "Item_Truelch_WeaponPod_Rs422_Text",
	Icon = "combat/icons/icon_mine_glow.png",
	UsedImage = ""
}
TILE_TOOLTIPS.Item_Truelch_WeaponPod_Rs422_Text = {"RS-422 Pod", "Pick it up to get a RS-422 Railgun."}


-------------------- UTILITY FUNCTIONS --------------------

function TryAddWeapon(loc, weapon, msg)
	local pawn = Board:GetPawn(loc)

	if pawn == nil then return end

	if not pawn:IsEnemy() then
		if #pawn:GetPoweredWeapons() < 3 then
			pawn:AddWeapon(weapon)			
			Board:AddAlert(loc, msg)
			Board:Ping(loc, GL_Color(255, 255, 255, 1))
		else
			--Replace the 3rd weapon with the new one?
		end
	else
		Board:AddAlert(loc, "DESTROYED")
	end
end


-------------------- BOARD EVENTS --------------------

BoardEvents.onTerrainChanged:subscribe(function(p, terrain, terrain_prev)
	local item = Board:GetItem(p)
	if isHellPodItem(item) then
		if terrain == TERRAIN_HOLE or terrain == TERRAIN_WATER then
			Board:RemoveItem(p)
		end
	end
end)

BoardEvents.onItemRemoved:subscribe(function(loc, removed_item)
	local pawn = Board:GetPawn(loc)
	if pawn == nil then return end
	local weaponSuffix = "\n(de-select and re-select the Mech to see it)"
	LOG("BoardEvents.onItemRemoved(removed_item: "..tostring(removed_item))
	if removed_item == "truelch_Item_ResupplyPod" then
		if not pawn:IsEnemy() then
			truelch_ItemReload(pawn:GetId(), 1)
		else
			LOG("--------------- DESTROYED")
			Board:AddAlert(loc, "DESTROYED")
		end
		--There can be a case where it's a friendly unit but that can't reload
		--Shame if it happens LOL
	--[[
	(About adding weapons)
	The player needs to un-select and select again the pawn to see the newly added weapon.
	I've tried some stuff to force the UI to update, but none worked:
	 - Force fire to an unreachable position (400, 400)
	 - Move the pawn to (-1, -1), wait a frame and move it back to loc, doesn't work (even if I also wait one frame before doing that)
	]]
	elseif removed_item == "truelch_Item_WeaponPod_Mg43" then
		TryAddWeapon(loc, "truelch_Mg43MachineGun", "Acquired a MG-43 Machine Gun!"..weaponSuffix)
	elseif removed_item == "truelch_Item_WeaponPod_Apw1" then
		TryAddWeapon(loc, "truelch_Apw1AntiMaterielRifle", "Acquired an APW-1 Anti-Materiel Rifle!"..weaponSuffix)
	elseif removed_item == "truelch_Item_WeaponPod_Flam40" then
		TryAddWeapon(loc, "truelch_Flam40Flamethrower", "Acquired a FLAM-40 Flamethrower!"..weaponSuffix)
	elseif removed_item == "truelch_Item_WeaponPod_Rs422" then
		TryAddWeapon(loc, "truelch_Rs422Railgun", "Acquired a RS-422 Railgun!"..weaponSuffix)
	end
end)

-------------------- HOOKS / EVENTS --------------------

local HOOK_pawnUndoMove = function(mission, pawn, undonePosition)
	local item = Board:GetItem(undonePosition)
	if item == "truelch_Item_ResupplyPod" then
		local weapons = pawn:GetPoweredWeapons()
		for j = 1, #weapons do
		    local fmw = fmwApi:GetSkill(pawn:GetId(), j)
		    if fmw ~= nil then
		    	--FMWeapon
				for k = 1, #_G[weapon].aFM_ModeList do
					local mode = fmw.aFM_ModeList[k]
					--fmw:FM_SubUses(pawn:GetId(), mode, missionData().beforeItemRecov[pawn:GetId()][j][k]) --I could have done that by sending the difference
					--LOG("FM_SetUses ---> "..tostring(missionData().beforeItemRecov[pawn:GetId()][j][k]))
					fmw:FM_SetUses(pawn:GetId(), mode, missionData().beforeItemRecov[pawn:GetId()][j][k]) --I hope it doesn't set the max use too?
				end
			else
				--Regular weapon (non-FMW)
			    if pawn:GetWeaponLimitedUses(j) > 0 then
			    	pawn:SetWeaponLimitedRemaining(j, missionData().beforeItemRecov[pawn:GetId()][j])
			    end
		    end
		end
	elseif isHellPodItem(item) then --any hell pod item BUT resupply
		pawn:RemoveWeapon(#pawn:GetPoweredWeapons()) --remove last weapon that SHOULD be the one previously added.
	end
end

local function HOOK_onNextTurnHook()	
	missionData().beforeItemRecov = {}
end

local function EVENT_onModsLoaded()
	modapiext:addPawnUndoMoveHook(HOOK_pawnUndoMove)
	modApi:addNextTurnHook(HOOK_onNextTurnHook)
end

modApi.events.onModsLoaded:subscribe(EVENT_onModsLoaded)