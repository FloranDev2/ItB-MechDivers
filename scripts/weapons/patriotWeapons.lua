-------------------- IMPORTS --------------------

local this = {}
local mod = mod_loader.mods[modApi.currentMod]
local scriptPath = mod.scriptPath
local resourcePath = mod.resourcePath


-------------------- MODE 1: MINIGUN --------------------

--Can KO efffects work with FMW?
--OnKill = "Brute_KO_Combo_OnKill",

truelch_PatriotWeaponsMode1 = {
	aFM_name = "Minigun",					       -- required
	aFM_desc = "Shoot a projectile that deals damage equal to health lost by the target + 1."..
		"\nIf it kills it, shoot a projectile from the dead unit that pushes and deal damage equal to excess damage.", -- required
	aFM_icon = "img/modes/icon_minigun.png",       -- required (if you don't have an image an empty string will work) 
	-- aFM_limited = 2, 						   -- optional (FMW will automatically handle uses for weapons)
	-- aFM_handleLimited = false 				   -- optional (FMW will no longer automatically handle uses for this mode if set)

	ProjectileArt = "effects/shot_mechtank",
}

CreateClass(truelch_PatriotWeaponsMode1)

function truelch_PatriotWeaponsMode1:targeting(point)
	local points = {}
	for dir = DIR_START, DIR_END do
		for i = 1, 7 do
			local curr = DIR_VECTORS[dir]*i + point
			points[#points+1] = curr
			if not Board:IsValid(curr) or Board:IsBlocked(curr, PATH_PROJECTILE) then
				break
			end
		end
	end
	return points
end

function truelch_PatriotWeaponsMode1:fire(p1, p2, se)
	local direction = GetDirection(p2 - p1)

	local target = GetProjectileEnd(p1, p2, PATH_PROJECTILE)

	local damage = 1
	local pawn = Board:GetPawn(p2)
	if pawn ~= nil then
		damage = damage + pawn:GetMaxHealth() - pawn:GetHealth()
	end

	local spaceDamage = SpaceDamage(target, damage)
	se:AddProjectile(spaceDamage, self.ProjectileArt)

	if Board:IsDeadly(spaceDamage, Pawn) then
		local target2 = GetProjectileEnd(p2, p2 + DIR_VECTORS[direction], PATH_PROJECTILE)
		local excessDamage = damage
		local deadPawn = Board:GetPawn(p2)
		if deadPawn ~= nil then
			--I hope I'm making a reliable damage calculator
			if deadPawn:IsShield() or deadPawn:IsFrozen() then --Shouldn't trigger IsDeadly then?
				LOG("--------- WTF? shield or frozen")
				excessDamage = 0
			elseif deadPawn:IsAcid() then
				excessDamage = damage * 2 --effective damage
			elseif deadPawn:IsArmor() then
				excessDamage = damage - 1
			end

			--Subtract health
			excessDamage = excessDamage - deadPawn:GetHealth()

			if excessDamage <= 0 then
				LOG("--------- Shouldn't happen")
				return
			end

			local sd2 = SpaceDamage(target2, excessDamage)
			sd2.iPush = direction

			se:AddProjectile(target, sd2, self.ProjectileArt, FULL_DELAY)
		end
	end
end


-------------------- MODE 2: ROCKET POD --------------------

truelch_PatriotWeaponsMode2 = truelch_PatriotWeaponsMode1:new{
	aFM_name = "Rocket pod",
	aFM_desc = "Shoot a powerful rocket diagonally that deals 3 damage. Deal 1 damage to adjacent tiles if the target unit dies.",
	aFM_icon = "img/modes/icon_rocket_pod.png",
	aFM_limited = 1,
}

function truelch_PatriotWeaponsMode2:targeting(point)
	local points = {}
	local offsets = { Point(-1, -1), Point(-1, 1), Point(1, -1), Point(1, 1) }
	for range = 1, 3 do
        for _, offset in pairs(offsets) do
        	local curr = offset*range + point
        	points[#points+1] = curr
        end
	end
	return points
end

--Oh that gave me an idea: it could shoot to all these 4 corners!
--[[
local z = math.abs(p2.x - p1.x)
local offset = { Point(-1, -1), Point(-1, 1), Point(1, -1), Point(1, 1) }
for _, offset in pairs(offset) do
	local curr = point + range * offset
	local spaceDamage = SpaceDamage(curr, 3)
	se:AddArtillery(spaceDamage, "effects/shotup_ignite_fireball.png")
end
]]
function truelch_PatriotWeaponsMode2:fire(p1, p2, se)
    local spaceDamage = SpaceDamage(p2, 3)    
    se:AddArtillery(spaceDamage, "shotup_missileswarm.png")

    for dir = DIR_START, DIR_END do
    	local curr = p2 + DIR_VECTORS[dir]
    	local spaceDamage = SpaceDamage(curr, 1)
    end
end


-------------------- WEAPON --------------------

truelch_PatriotWeapons = aFM_WeaponTemplate:new{
	Name = "Patriot's weapons",
	Description = "Drop various playloads.",
	Class = "Prime",
	Icon = "weapons/truelch_patriot_weapons.png",
	Rarity = 1,
	PowerCost = 1,

	--KO
	OnKill = "Enhanced effect",

	--Artillery Arc
	ArtilleryHeight = 0,

    --TwoClick = true,
	LaunchSound = "/weapons/bomb_strafe",

	aFM_ModeList = { "truelch_PatriotWeaponsMode1", "truelch_PatriotWeaponsMode2" },
	aFM_ModeSwitchDesc = "Click to change mode.",

	TipImage = {
		Unit          = Point(2, 3),
		Target        = Point(2, 2),
		CustomEnemy   = "Scarab1",
		Enemy         = Point(2, 2),
		Enemy2        = Point(2, 1),
		Second_Target = Point(2, 2),
		Second_Origin = Point(2, 3),
		CustomPawn = "truelch_PatriotMech",
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