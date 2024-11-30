-------------------- IMPORTS --------------------

local this = {}
local mod = mod_loader.mods[modApi.currentMod]
local scriptPath = mod.scriptPath
local resourcePath = mod.resourcePath


-------------------- MODE 1: ??? --------------------
	
truelch_PatriotWeaponsMode1 = {
	aFM_name = "Minigun",					       -- required
	aFM_desc = "???", -- required
	aFM_icon = "img/modes/icon_strafe.png",        -- required (if you don't have an image an empty string will work) 
	-- aFM_limited = 2, 						   -- optional (FMW will automatically handle uses for weapons)
	-- aFM_handleLimited = false 				   -- optional (FMW will no longer automatically handle uses for this mode if set)
}

CreateClass(truelch_PatriotWeaponsMode1)

function truelch_PatriotWeaponsMode1:targeting(point)
	local points = {}
	for dir = DIR_START, DIR_END do
		local curr = DIR_VECTORS[dir]*2 + point
		if not Board:IsBlocked(curr, PATH_PROJECTILE) then
			points[#points+1] = curr
		end
	end
	return points
end

function truelch_PatriotWeaponsMode1:fire(p1, p2, se)

end


-------------------- MODE 2: ??? --------------------

truelch_PatriotWeaponsMode2 = truelch_PatriotWeaponsMode1:new{
	aFM_name = "Rocket pod",
	aFM_desc = "???",
	aFM_icon = "img/modes/icon_resupply.png",
	aFM_limited = 2,
}

function truelch_PatriotWeaponsMode2:targeting(point)

end

function truelch_PatriotWeaponsMode2:fire(p1, p2, se)

end


-------------------- WEAPON --------------------

truelch_PatriotWeapons = aFM_WeaponTemplate:new{
	Name = "Patriot's weapons",
	Description = "Drop various playloads.",
	Class = "Prime",
	Icon = "weapons/truelch_delivery.png",
	Rarity = 1,
	PowerCost = 1,

	--Artillery Arc
	ArtilleryHeight = 0,

    --TwoClick = true,
	LaunchSound = "/weapons/bomb_strafe",

	aFM_ModeList = { "truelch_PatriotWeaponsMode1", "truelch_PatriotWeaponsMode2" },
	aFM_ModeSwitchDesc = "Click to change mode.",

	TipImage = {
		Unit = Point(2, 2)
	}
}

function truelch_PatriotWeapons:GetTargetArea(point)
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

function truelch_PatriotWeapons:GetSkillEffect(p1, p2)
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