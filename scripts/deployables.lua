local mod = mod_loader.mods[modApi.currentMod]
local resourcePath = mod.resourcePath

local mechDiversBlack = modApi:getPaletteImageOffset("truelch_MechDiversBlack")

local depPath = resourcePath.."img/deployables/"

local files = {
	"truelch_mg_sentry.png",
	"truelch_mg_sentry_a.png",
	"truelch_mg_sentry_death.png",
	"truelch_mg_sentry_ns.png",

	"truelch_mortar_sentry.png",
	"truelch_mortar_sentry_a.png",
	"truelch_mortar_sentry_death.png",
	"truelch_mortar_sentry_ns.png",

	"truelch_tesla_tower.png",
	"truelch_tesla_tower_a.png",
	"truelch_tesla_tower_death.png",
	"truelch_tesla_tower_ns.png",

	"truelch_guard_dog.png",
	"truelch_guard_dog_a.png",
	"truelch_guard_dog_death.png",
	"truelch_guard_dog_ns.png",

	"truelch_guard_dog_laser.png",
	"truelch_guard_dog_laser_a.png",
	"truelch_guard_dog_laser_death.png",
	"truelch_guard_dog_laser_ns.png",
}

for _, file in ipairs(files) do
	modApi:appendAsset("img/units/player/"..file, depPath..file)
end

--- MG SENTY ---
local a = ANIMS
a.truelch_mg_sentry =    a.MechUnit:new{ Image = "units/player/truelch_mg_sentry.png",       PosX = -17, PosY = -11 }
a.truelch_mg_sentrya =   a.MechUnit:new{ Image = "units/player/truelch_mg_sentry_a.png",     PosX = -26, PosY = -18, NumFrames = 4 }
a.truelch_mg_sentryd =   a.MechUnit:new{ Image = "units/player/truelch_mg_sentry_death.png", PosX = -26, PosY = -18, NumFrames = 11, Loop = false, Time = 0.14 }
a.truelch_mg_sentry_ns = a.MechIcon:new{ Image = "units/player/truelch_mg_sentry_ns.png" }

--- MORTAR SENTY ---
local a = ANIMS
a.truelch_mortar_sentry =    a.MechUnit:new{ Image = "units/player/truelch_mortar_sentry.png",       PosX = -17, PosY = -11 }
a.truelch_mortar_sentrya =   a.MechUnit:new{ Image = "units/player/truelch_mortar_sentry_a.png",     PosX = -26, PosY = -18, NumFrames = 4 }
a.truelch_mortar_sentryd =   a.MechUnit:new{ Image = "units/player/truelch_mortar_sentry_death.png", PosX = -26, PosY = -18, NumFrames = 11, Loop = false, Time = 0.14 }
a.truelch_mortar_sentry_ns = a.MechIcon:new{ Image = "units/player/truelch_mortar_sentry_ns.png" }

--- TESLA TOWER ---
local a = ANIMS
a.truelch_tesla_tower =    a.MechUnit:new{ Image = "units/player/truelch_tesla_tower.png",       PosX = -18, PosY = -8 }
a.truelch_tesla_towera =   a.MechUnit:new{ Image = "units/player/truelch_tesla_tower_a.png",     PosX = -18, PosY = -8, NumFrames = 4 }
a.truelch_tesla_towerd =   a.MechUnit:new{ Image = "units/player/truelch_tesla_tower_death.png", PosX = -25, PosY = -12, NumFrames = 11, Loop = false, Time = 0.14 }
a.truelch_tesla_tower_ns = a.MechIcon:new{ Image = "units/player/truelch_tesla_tower_ns.png" }

--- GUARD DOG ---
local a = ANIMS
a.truelch_guard_dog =    a.MechUnit:new{ Image = "units/player/truelch_guard_dog.png",       PosX = -18, PosY = -8 }
a.truelch_guard_doga =   a.MechUnit:new{ Image = "units/player/truelch_guard_dog_a.png",     PosX = -18, PosY = -8, NumFrames = 4 }
a.truelch_guard_dogd =   a.MechUnit:new{ Image = "units/player/truelch_guard_dog_death.png", PosX = -18, PosY = -8, NumFrames = 9, Loop = false, Time = 0.14 }
a.truelch_guard_dog_ns = a.MechIcon:new{ Image = "units/player/truelch_guard_dog_ns.png" }

--- GUARD DOG (LASER) ---
local a = ANIMS
a.truelch_guard_dog_laser =    a.MechUnit:new{ Image = "units/player/truelch_guard_dog_laser.png",       PosX = -18, PosY = -8 }
a.truelch_guard_dog_lasera =   a.MechUnit:new{ Image = "units/player/truelch_guard_dog_laser_a.png",     PosX = -18, PosY = -8, NumFrames = 4 }
a.truelch_guard_dog_laserd =   a.MechUnit:new{ Image = "units/player/truelch_guard_dog_laser_death.png", PosX = -18, PosY = -8, NumFrames = 9, Loop = false, Time = 0.14 }
a.truelch_guard_dog_laser_ns = a.MechIcon:new{ Image = "units/player/truelch_guard_dog_laser_ns.png" }

----------------------------------------------------------------------------------------------------
---------------------------------------- MACHINE GUN SENTRY ----------------------------------------
----------------------------------------------------------------------------------------------------

truelch_Amg43MachineGunSentry = Pawn:new{
	Name = "A/MG-43 Machine Gun Sentry", --A/G-16 Gatling Sentry --A/AC-8 Autocannon Sentry
	Health = 1,
	MoveSpeed = 0,
	--Image = "MechLeap",
	Image = "truelch_mg_sentry",
	SkillList = { "truelch_Amg43MachineGunSentry_Weapon" },
	SoundLocation = "/mech/flying/jet_mech/",
	ImageOffset = mechDiversBlack,
	DefaultTeam = TEAM_PLAYER,
	ImpactMaterial = IMPACT_METAL,
	Corpse = false,
	Neutral = true, --test!
	Pushable = false,
}
AddPawn("truelch_Amg43MachineGunSentry")

--"Neutral" weapon
truelch_Amg43MachineGunSentry_Weapon = Skill:new{
	--Infos
	Name = "Machine Gun",
	Description = "Shoots a projectile at a random aligned enemy."..
		"\nIt tries to avoid buildings, but doesn't care at all about damage against allied units!",
	Class = "Unique",

	--Art
	Icon = "weapons/deploy_tank.png",
	ProjectileArt = "effects/shot_mechtank",

	LaunchSound = "/weapons/modified_cannons",
	ImpactSound = "/impact/generic/explosion",

	--Gameplay
	Damage = 1,

	--Tip image
	TipImage = {
		Unit   = Point(2, 2),
		Enemy  = Point(2, 1),
		Target = Point(2, 1),
		CustomPawn = "truelch_Amg43MachineGunSentry"
	}
}

function truelch_Amg43MachineGunSentry_Weapon:GetTargetScore(p1, p2)
	local target = Board:GetPawn(p2)

	if target ~= nil then
		local behind = p2 + DIR_VECTORS[GetDirection(p2 - p1)]
		if Board:IsBuilding(behind) and target:IsPushable() then --What's the difference between IsGuarding() and (not) IsPushable()??
			return -200 --I hope this will be enough to prevent bump damage toward buildings
		elseif target:IsEnemy() then
			return 100
		end
	end

	return -10
end

function truelch_Amg43MachineGunSentry_Weapon:GetTargetArea(point)
    local ret = PointList()

    for dir = DIR_START, DIR_END do    	
        local target = GetProjectileEnd(point, point + DIR_VECTORS[dir], PATH_PROJECTILE)

        local pawn = Board:GetPawn(target)

        if pawn ~= nil and pawn:IsEnemy() then
        	ret:push_back(target)
    	end
    end

    return ret
end

function truelch_Amg43MachineGunSentry_Weapon:GetSkillEffect(p1, p2)
    local ret = SkillEffect()
    local dir = GetDirection(p2 - p1)
    local target = GetProjectileEnd(p1, p2, PATH_PROJECTILE)
    local damage = SpaceDamage(target, self.Damage, dir)
    ret:AddProjectile(p1, damage, self.ProjectileArt, NO_DELAY)
    return ret
end




-----------------------------------------------------------------------------------------------
---------------------------------------- MORTAR SENTRY ----------------------------------------
-----------------------------------------------------------------------------------------------

truelch_Am12MortarSentry = Pawn:new{
	Name = "A/M-12 Mortar Sentry",
	Health = 1,
	MoveSpeed = 0,
	Image = "truelch_mortar_sentry",
	SkillList = { "truelch_Am12MortarSentry_Weapon" },
	SoundLocation = "/mech/flying/jet_mech/",
	ImageOffset = mechDiversBlack,
	DefaultTeam = TEAM_PLAYER,
	ImpactMaterial = IMPACT_METAL,
	Corpse = false,
	Neutral = true, --test!
	Pushable = false,
}
AddPawn("truelch_Am12MortarSentry")

--"Neutral" weapon?
truelch_Am12MortarSentry_Weapon = Skill:new{
	--Infos
	Name = "Mortar",
	Description = "Artillery strike that damages and pushes adjacent tiles.",
	Class = "Unique",

	--Art
	Icon = "weapons/ranged_artillery.png",
	UpShot = "effects/truelch_shotup_mortar.png",

	LaunchSound = "/weapons/artillery_volley",
	ImpactSound = "/impact/generic/explosion",

	--Gameplay
	CenterDamage = 1,
	OuterDamage = 1,

	--Tip image
	TipImage = {
		Unit     = Point(2, 3),
		Mountain = Point(2, 2),
		Enemy    = Point(2, 1),
		Target   = Point(2, 1),
		CustomPawn = "truelch_Am12MortarSentry"
	}
}

--If I do a weapon managed by the AI
function truelch_Am12MortarSentry_Weapon:GetTargetScore(p1, p2)
	local score = 0
	local pawn = Board:GetPawn(p2)
	if pawn ~= nil then
		if pawn:IsEnemy() then
			score = score + 100
		else
			score = score - 10
		end
	elseif Board:IsBuilding(p2) then
		score = score - 50
	end

	--Adjacent
	for dir = DIR_START, DIR_END do
		local curr = p2 + DIR_VECTORS[dir]
		pawn = Board:GetPawn(curr)
		if pawn ~= nil then
			local behind = curr + DIR_VECTORS[dir]
			if Board:IsBuilding(behind) and target:IsPushable() then --What's the difference between IsGuarding() and (not) IsPushable()??
				score = -100
				break
			elseif pawn:IsEnemy() then
				score = score + 50
			else
				score = score - 10
			end
		elseif Board:IsBuilding(curr) then
			score = -100
			break
		end
	end

	return score
end

function truelch_Am12MortarSentry_Weapon:GetTargetArea(point)
    local ret = PointList()

    for dir = DIR_START, DIR_END do
    	for i = 2, 7 do
    		local curr = point + DIR_VECTORS[dir]*i
    		ret:push_back(curr)
	    end
    end

    return ret
end

function truelch_Am12MortarSentry_Weapon:GetSkillEffect(p1, p2)
    local ret = SkillEffect()

    ret:AddBounce(p1, 1)

    local damage = SpaceDamage(p2, self.CenterDamage)
    damage.sAnimation = "ExploArt1"
    ret:AddArtillery(damage, self.UpShot)

    for dir = DIR_START, DIR_END do
    	local damage = SpaceDamage(p2 + DIR_VECTORS[dir], self.OuterDamage)
    	--damage.sAnimation = "airpush_"..dir
    	damage.sAnimation = "explopush1_"..dir
    	damage.iPush = dir
    	ret:AddDamage(damage)
    end

    return ret
end




---------------------------------------------------------------------------------------------
---------------------------------------- TESLA TOWER ----------------------------------------
---------------------------------------------------------------------------------------------

truelch_TeslaTower = Pawn:new{
	Name = "A/ARC-3 Tesla Tower",
	Health = 1,
	MoveSpeed = 0,
	Image = "truelch_tesla_tower",
	SkillList = { "truelch_TeslaTower_Weapon" },
	SoundLocation = "/mech/flying/jet_mech/",
	ImageOffset = mechDiversBlack,
	DefaultTeam = TEAM_PLAYER,
	ImpactMaterial = IMPACT_METAL,
	Corpse = false,
	Neutral = true, --test!
	Pushable = false,
}
AddPawn("truelch_TeslaTower")

--"Neutral" weapon?
truelch_TeslaTower_Weapon = Skill:new{
	--Infos
	Name = "Tesla Discharge",
	Description = "Chain damage through adjacent targets."..
		"\nIt doesn't care about friendly fire. (but at least, it won't damage buildings!)",
	Class = "Unique",

	--Art
	Icon = "weapons/prime_lightning.png",

	LaunchSound = "/weapons/electric_whip",

	--Gameplay
	Damage = 2,
	Buildings = false,

	--Tip image
	TipImage = {
		Unit   = Point(2, 3),
		Target = Point(2, 2),
		Enemy1 = Point(2, 2),
		Enemy2 = Point(2, 1),
		Enemy3 = Point(3, 1),
	}
}

--If I do a weapon managed by the AI
function truelch_TeslaTower_Weapon:GetTargetScore(p1, p2)
	local score = 0

	if Board:GetPawnTeam(p2) == TEAM_ENEMY then
		score = score + 100
	else
		score = score - 10
	end

	return score
end

function truelch_TeslaTower_Weapon:GetTargetArea(point)
    local ret = PointList()

    for dir = DIR_START, DIR_END do
    	ret:push_back(point + DIR_VECTORS[dir])
    end

    return ret
end

function truelch_TeslaTower_Weapon:GetSkillEffect(p1, p2)
	local ret = SkillEffect()
	local damage = SpaceDamage(p2, self.Damage)
	local hash = function(point) return point.x + point.y*10 end
	local explored = {[hash(p1)] = true}
	local todo = {p2}
	local origin = { [hash(p2)] = p1 }
	
	if Board:IsPawnSpace(p2) or (self.Buildings and Board:IsBuilding(p2)) then
		ret:AddAnimation(p1, "Lightning_Hit")
	end
	
	while #todo ~= 0 do
		local current = pop_back(todo)
		
		if not explored[hash(current)] then
			explored[hash(current)] = true
			
			if Board:IsPawnSpace(current) or (self.Buildings and Board:IsBuilding(current)) then
			
				local direction = GetDirection(current - origin[hash(current)])
				damage.sAnimation = "Lightning_Attack_"..direction
				damage.loc = current
				damage.iDamage = Board:IsBuilding(current) and DAMAGE_ZERO or self.Damage
				
				ret:AddDamage(damage)
				
				if not Board:IsBuilding(current) then
					ret:AddAnimation(current, "Lightning_Hit")
				end
				
				for i = DIR_START, DIR_END do
					local neighbor = current + DIR_VECTORS[i]
					if not explored[hash(neighbor)] then
						todo[#todo + 1] = neighbor
						origin[hash(neighbor)] = current
					end
				end
			end		
		end
	end

	return ret
end




-------------------------------------------------------------------------------------------
---------------------------------------- GUARD DOG ----------------------------------------
-------------------------------------------------------------------------------------------

truelch_GuardDog = Pawn:new{
	Name = [[AX/AR-23 "Guard Dog"]],
	Health = 1,
	MoveSpeed = 3,
	Image = "truelch_guard_dog",
	SkillList = { "truelch_GuardDog_Weapon" },
	SoundLocation = "/mech/flying/jet_mech/",
	ImageOffset = mechDiversBlack,
	DefaultTeam = TEAM_PLAYER,
	ImpactMaterial = IMPACT_METAL,
	Corpse = false,
	Neutral = true,
	Flying = true,
}
AddPawn("truelch_GuardDog")

--"Neutral" weapon
truelch_GuardDog_Weapon = Skill:new{
	--Infos
	Name = "AR-23P Liberator Penetrator",
	Description = "Shoot a projectile at melee range, prioritizing enemies adjacent with Mechs."..
		"It'll avoid bump damage towards buildings, but not against allies!",
	Class = "Unique",

	--Art
	Icon = "weapons/deploy_tank.png",
	ProjectileArt = "effects/shot_mechtank",

	LaunchSound = "/weapons/modified_cannons",
	ImpactSound = "/impact/generic/explosion",

	--Gameplay
	Damage = 1,

	--Tip image
	TipImage = {
		Unit     = Point(1, 2),
		Friendly = Point(2, 1),
		Enemy    = Point(1, 1),
		Target   = Point(1, 1),
		CustomPawn = "truelch_GuardDog"
	}
}

function truelch_GuardDog_Weapon:GetTargetScore(p1, p2)
	local score = -10

	local target = Board:GetPawn(p2)
	if target ~= nil and target:IsEnemy() then
		score = score + 50

		local forwardDir = GetDirection(p2 - p1)
		local behind = p2 + DIR_VECTORS[forwardDir]

		--What's the difference between IsGuarding() and IsPushable()??
		if Board:IsBuilding(behind) and target:IsPushable() then
			score = score -200 --I hope this will be enough to prevent bump damage toward buildings
		else
			for dir = DIR_START, DIR_END do
				local curr = p2 + DIR_VECTORS[dir]
				local adjacentPawn = Board:GetPawn(curr)
				if adjacentPawn ~= nil and adjacentPawn:IsMech() and curr ~= behind then
					score = score + 100
				end
			end
		end		
	end

	return score
end

function truelch_GuardDog_Weapon:GetTargetArea(point)
    local ret = PointList()

    for dir = DIR_START, DIR_END do
    	ret:push_back(point + DIR_VECTORS[dir])
    end

    return ret
end

function truelch_GuardDog_Weapon:GetSkillEffect(p1, p2)
    local ret = SkillEffect()
    local dir = GetDirection(p2 - p1)
    local damage = SpaceDamage(p2, self.Damage, dir)
    ret:AddProjectile(p1, damage, self.ProjectileArt, NO_DELAY)
    return ret
end




---------------------------------------------------------------------------------------------------
---------------------------------------- GUARD DOG (LASER) ----------------------------------------
---------------------------------------------------------------------------------------------------

truelch_GuardDogLaser = Pawn:new{
	Name = [[AX/LAS-5 "Guard Dog" Rover]],
	Health = 1,
	MoveSpeed = 3,
	Image = "truelch_guard_dog_laser",
	SkillList = { "truelch_GuardDogLaser_Weapon" },
	SoundLocation = "/mech/flying/jet_mech/",
	ImageOffset = mechDiversBlack,
	DefaultTeam = TEAM_PLAYER,
	ImpactMaterial = IMPACT_METAL,
	Corpse = false,
	Neutral = true,
	Flying = true,
}
AddPawn("truelch_GuardDogLaser")

--"Neutral" weapon
truelch_GuardDogLaser_Weapon = LaserDefault:new{
	--Infos
	Name = "LAS-5 Scythe",
	Description = "Fire a piercing beam that decreases in damage the further it goes."..
		"It'll avoid damaging buildings, but won't care about friendlies in the line of fire!",
	Class = "Unique",

	--Art
	Icon = "weapons/prime_laser.png",
	LaserArt = "effects/laser_push",

	--Gameplay
	Damage = 2,

	--Tip image
	TipImage = {
		Unit     = Point(2, 4),
		Enemy    = Point(2, 3),
		Friendly = Point(2, 1),
		Target   = Point(2, 3),
		Mountain = Point(2, 0)
	}
}

function truelch_GuardDogLaser_Weapon:GetTargetScore(p1, p2)
	local score = -10

	local dir = GetDirection(p2 - p1)

	for i = 1, 7 do
		local curr = p2 + DIR_VECTORS[dir] * i
		if Board:GetPawnTeam(curr) == TEAM_ENEMY then
			score = score + 100
		elseif Board:IsBuilding(curr) then
			score = -1000 --it still shot at a building, wtf??
			break
		elseif Board:IsBlocked(curr, PATH_PROJECTILE) then
			break
		end
	end

	return score
end

--We just evaluate all 4 directions so no need to put all the laser path (will be actually easier for target score calculation)
function truelch_GuardDogLaser_Weapon:GetTargetArea(point)
    local ret = PointList()

    for dir = DIR_START, DIR_END do
    	local curr = point + DIR_VECTORS[dir]
    	ret:push_back(point + DIR_VECTORS[dir])
    end

    return ret
end