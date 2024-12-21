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
}

for _, file in ipairs(files) do
	modApi:appendAsset("img/units/player/"..file, depPath..file)
end

--- MG SENTY ---
local a = ANIMS
a.truelch_mg_sentry =    a.MechUnit:new{ Image = "units/player/truelch_mg_sentry.png",       PosX = -18, PosY = -8 }
a.truelch_mg_sentrya =   a.MechUnit:new{ Image = "units/player/truelch_mg_sentry_a.png",     PosX = -18, PosY = -8, NumFrames = 4 }
a.truelch_mg_sentryd =   a.MechUnit:new{ Image = "units/player/truelch_mg_sentry_death.png", PosX = -18, PosY = -8, NumFrames = 10, Loop = false, Time = 0.14 }
a.truelch_mg_sentry_ns = a.MechIcon:new{ Image = "units/player/truelch_mg_sentry_ns.png" }

--- MORTAR SENTY ---
local a = ANIMS
a.truelch_mortar_sentry =    a.MechUnit:new{ Image = "units/player/truelch_mortar_sentry.png",       PosX = -18, PosY = -8 }
a.truelch_mortar_sentrya =   a.MechUnit:new{ Image = "units/player/truelch_mortar_sentry_a.png",     PosX = -18, PosY = -8, NumFrames = 4 }
a.truelch_mortar_sentryd =   a.MechUnit:new{ Image = "units/player/truelch_mortar_sentry_death.png", PosX = -18, PosY = -8, NumFrames = 10, Loop = false, Time = 0.14 }
a.truelch_mortar_sentry_ns = a.MechIcon:new{ Image = "units/player/truelch_mortar_sentry_ns.png" }

--- TESLA TOWER ---
local a = ANIMS
a.truelch_tesla_tower =    a.MechUnit:new{ Image = "units/player/truelch_tesla_tower.png",       PosX = -18, PosY = -8 }
a.truelch_tesla_towera =   a.MechUnit:new{ Image = "units/player/truelch_tesla_tower_a.png",     PosX = -18, PosY = -8, NumFrames = 4 }
a.truelch_tesla_towerd =   a.MechUnit:new{ Image = "units/player/truelch_tesla_tower_death.png", PosX = -18, PosY = -8, NumFrames = 10, Loop = false, Time = 0.14 }
a.truelch_tesla_tower_ns = a.MechIcon:new{ Image = "units/player/truelch_tesla_tower_ns.png" }

--- GUARD DOG ---
local a = ANIMS
a.truelch_guard_dog =    a.MechUnit:new{ Image = "units/player/truelch_guard_dog.png",       PosX = -18, PosY = -8 }
a.truelch_guard_doga =   a.MechUnit:new{ Image = "units/player/truelch_guard_dog_a.png",     PosX = -18, PosY = -8, NumFrames = 4 }
a.truelch_guard_dogd =   a.MechUnit:new{ Image = "units/player/truelch_guard_dog_death.png", PosX = -18, PosY = -8, NumFrames = 10, Loop = false, Time = 0.14 }
a.truelch_guard_dog_ns = a.MechIcon:new{ Image = "units/player/truelch_guard_dog_ns.png" }

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
	Description = "Shoots a projectile at a random aligned enemy.",
	Class = "Unique",

	--Art
	Icon = "weapons/deploy_tank.png",
	ProjectileArt = "effects/shot_mechtank",

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
	local effect = SkillEffect()

	if Board:GetPawnTeam(p2) == TEAM_ENEMY then
		return 100 --no idea what the range should be
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
	--Image = "MechNano",
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
	Description = "Artillery strike.",
	Class = "Unique",

	--Art
	Icon = "weapons/ranged_artillery.png",
	UpShot = "effects/truelch_shotup_mortar.png", --TMP

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
	local effect = SkillEffect()

	local score = 0
	if Board:GetPawnTeam(p2) == TEAM_ENEMY then
		score = score + 100
	end

	for dir = DIR_START, DIR_END do
		local curr = p2 + DIR_VECTORS[dir]
		local pawn = Board:GetPawn(curr)
		if Board:IsBuilding() then
			score = score - 50
		elseif pawn ~= nil then
			if pawn:IsEnemy() then
				score = score + 50
			else
				score = score - 10
			end
		end
	end

	return score
end

function truelch_Am12MortarSentry_Weapon:GetTargetArea(point)
    local ret = PointList()

    for dir = DIR_START, DIR_END do
    	for i = 2, 7 do
        	local curr = point + DIR_VECTORS[dir]*i
        	local pawn = Board:GetPawn(curr)
	        if pawn ~= nil and pawn:IsEnemy() then
	        	ret:push_back(curr)
	    	end
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
	--Image = "MechScarab",
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
	Description = "Chain damage through adjacent targets.",
	Class = "Unique",

	--Art
	Icon = "weapons/deploy_tank.png",
	UpShot = "effects/shotup_tribomb_missile.png", --TMP

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
	local effect = SkillEffect()

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
	Name = "AX/AR-23 'Guard Dog'",
	Health = 1,
	MoveSpeed = 3,
	Image = "truelch_guard_dog",
	--Image = "MechJudo",
	SkillList = { "truelch_TeslaTower_Weapon" },
	SoundLocation = "/mech/flying/jet_mech/",
	ImageOffset = mechDiversBlack,
	DefaultTeam = TEAM_PLAYER,
	ImpactMaterial = IMPACT_METAL,
	Corpse = false,
	Neutral = true,
	Flying = true,
}
AddPawn("truelch_GuardDog")