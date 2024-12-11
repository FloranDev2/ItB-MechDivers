--Example from tosx:
--[[
tosx_Deploy_Fighter = Pawn:new{
	Name = "Fighter",
	Health = 1,
	MoveSpeed = 3,
	Image = "tosx_Fighter_img",
	SkillList = { "tosx_Deploy_FighterShot" },
	SoundLocation = "/mech/flying/jet_mech/",
	ImageOffset = imageOffset,
	DefaultTeam = TEAM_PLAYER,
	ImpactMaterial = IMPACT_METAL,
	Flying = true,
	Corpse = false,
}
tosx_Deploy_FighterA = tosx_Deploy_Fighter:new{
	SkillList = { "tosx_Deploy_FighterShot_2" , "tosx_Deploy_FighterShot" },
}
tosx_Deploy_FighterB = tosx_Deploy_Fighter:new{
	SkillList = { "tosx_Deploy_FighterShot_2" },
}
tosx_Deploy_FighterAB = tosx_Deploy_Fighter:new{
	SkillList = { "tosx_Deploy_FighterShot_2" },
	MoveSpeed = 6,
}
]]

local mechDiversBlack = modApi:getPaletteImageOffset("truelch_MechDiversBlack")


-------------------- TURRETS --------------------

--Make turrets autonomous? As in they just shot a random enemy in sight?

--[[
-- locate our mech assets.
local deployablePath = path .."img/deployables/" --truelch

-- iterate our files and add the assets so the game can find them.
for _, file in ipairs(files) do
	modApi:appendAsset("img/units/player/"..file, deployablePath..file)
end

-- create animations for our mech with our imported files.
-- note how the animations starts searching from /img/
local a = ANIMS
a.tatu_scout_drone =	a.MechUnit:new{ Image = "units/player/tatu_scout_drone.png",       PosX = -18, PosY = -8 }
a.tatu_scout_dronea =	a.MechUnit:new{ Image = "units/player/tatu_scout_drone_a.png",     PosX = -18, PosY = -8, NumFrames = 4 }
a.tatu_scout_droned =	a.MechUnit:new{ Image = "units/player/tatu_scout_drone_death.png", PosX = -18, PosY = -8, NumFrames = 10, Loop = false, Time = 0.14 }
a.tatu_scout_drone_ns =	a.MechIcon:new{ Image = "units/player/tatu_scout_drone_ns.png" }

-- make a list of our files.
local files = {
	"tatu_scout_drone.png",
	"tatu_scout_drone_a.png",
	"tatu_scout_drone_death.png",
	"tatu_scout_drone_ns.png",
}
]]

truelch_Amg43MachineGunSentry = Pawn:new{
	Name = "A/MG-43 Machine Gun Sentry",
	Health = 1,
	MoveSpeed = 0,
	Image = "SmallTank1", --TODO
	SkillList = { "truelch_Amg43MachineGunSentry_Weapon" },
	SoundLocation = "/mech/flying/jet_mech/",
	ImageOffset = mechDiversBlack,
	DefaultTeam = TEAM_PLAYER,
	ImpactMaterial = IMPACT_METAL,
	Corpse = false,
	Neutral = true, --test!
}
AddPawn("truelch_Amg43MachineGunSentry")

--"Neutral" weapon
truelch_Amg43MachineGunSentry_Weapon = Skill:new{  
	Name = "Machine Gun",
	Description = "Shoots a projectile at a random aligned enemy.",
	Icon = "weapons/deploy_tank.png",
	Class = "Unique",
	Damage = 1,
	ProjectileArt = "effects/shot_mechtank", --TMP
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
		
	--return self:ScoreList(self:GetSkillEffect(p1,p2).q_effect, true)
	--return self:ScoreList(self:GetSkillEffect(p1, p2).effect, true) --will this work?
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

--Regular weapon
--[[
truelch_Amg43MachineGunSentry_Weapon = Skill:new{  
	Name = "Machine Gun",
	Description = "TMP",
	Icon = "weapons/deploy_tank.png",
	Class = "Unique", --Class = "Unique",
	Damage = 1,
	ProjectileArt = "effects/shot_mechtank", --TMP
	TipImage = {
		Unit   = Point(2, 2),
		Enemy  = Point(2, 1),
		Target = Point(2, 1),
		CustomPawn = "truelch_Amg43MachineGunSentry"
	}
}

function truelch_Amg43MachineGunSentry_Weapon:GetTargetArea(point)
    local ret = PointList()

    for dir = DIR_START, DIR_END do
        for i = 1, 7 do
            local curr = Point(point + DIR_VECTORS[dir] * i)

            if Board:IsValid(curr) then
            	ret:push_back(curr)
        	end

            if not Board:IsValid(curr) or Board:IsBlocked(curr, PATH_PROJECTILE) then
            	break
            end
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
]]