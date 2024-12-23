truelch_DualAutocannons = Skill:new{
    --Infos
	Name = "Dual Autocannons",
    Class = "Prime",
    Description = "Cannons that can shoot a pushing projectile from the left or from the right."..
        "\nIf the target is 2 tiles away or less, the projectile deal 1 damage.",
	PowerCost = 1,

    --Art
	Icon = "weapons/truelch_dual_autocannon.png",
	Sound = "/general/combat/explode_small",
	LaunchSound = "/weapons/modified_cannons",
	ImpactSound = "/impact/generic/explosion",
    ShortRangeProjectileArt = "effects/shot_mechtank", --damage
    LongRangeProjectileArt = "effects/shot_mechtank", --harmless

    --Gameplay
    Dual = false,
    ShortRangeDamage = 1,
    LongRangeDamage = 0,
    RangeThreshold = 2,

    --Upgrades
    Upgrades = 2,
    UpgradeCost = { 2, 3 },

    --Tip image
    TipImage = {
        Unit = Point(2, 3),
        Friendly = Point(1, 3),
        Target = Point(1, 1),
        Second_Target = Point(3, 1),
        Second_Origin = Point(2, 3),
        Enemy = Point(1, 2),
        Enemy2 = Point(3, 0),
        CustomPawn = "truelch_EmancipatorMech",
    }
}

Weapon_Texts.truelch_DualAutocannons_Upgrade1 = "Dual Shot"
Weapon_Texts.truelch_DualAutocannons_Upgrade2 = "+2 Damage"

truelch_DualAutocannons_A = truelch_DualAutocannons:new{
    UpgradeDescription = "Can shoot from both cannons.\nYou need to target the middle line to shoot both.",
    Dual = true,
    TipImage = {
        Unit     = Point(2, 3),
        Friendly = Point(1, 3),
        Target   = Point(2, 2),
        Enemy    = Point(1, 2),
        Enemy2   = Point(3, 0),
        CustomPawn = "truelch_EmancipatorMech",
    }
}

truelch_DualAutocannons_B = truelch_DualAutocannons:new{
    UpgradeDescription = "Increases short range damage by 2.",
    ShortRangeDamage = 3,
}

truelch_DualAutocannons_AB = truelch_DualAutocannons:new{
    Dual = true,
    ShortRangeDamage = 3,
    TipImage = {
        Unit     = Point(2, 3),
        Friendly = Point(1, 3),
        Target   = Point(2, 2),
        Enemy    = Point(1, 2),
        Enemy2   = Point(3, 0),
        CustomPawn = "truelch_EmancipatorMech",
    }
}

function truelch_DualAutocannons:GetTargetArea(point)
    local ret = PointList()
    for dir = DIR_START, DIR_END do
        for i = 1, 7 do
            local curr = Point(point + DIR_VECTORS[dir] * i)

            if self.Dual then
                if Board:IsValid(curr) then
                    ret:push_back(curr)
                end
            end

            --yeah... not ideal (cannot shoot only from one side when shooting toward a nearby border tile)
            --if i > 1 or not self.Dual then --> doesn't work because the points still superpose
            if i > 1 then
                --LEFT
                local left = curr - DIR_VECTORS[(dir + 1)% 4]
                if Board:IsValid(left) then
                    ret:push_back(left)
                end

                --RIGHT
                local right = curr + DIR_VECTORS[(dir + 1)% 4]
                if Board:IsValid(right) then
                    ret:push_back(right)
                end
            end
        end
    end
    return ret
end

--Add pull to the start?
function truelch_DualAutocannons:Shot(ret, start, dir)
    --Pull (Super Recoil Blast)
    local pullDir = (dir + 2)% 4
    local pullD = SpaceDamage(start, 0, pullDir)
    pullD.sAnimation = "airpush_"..pullDir
    ret:AddDamage(pullD)

    local target = GetProjectileEnd(start, start + DIR_VECTORS[dir], PATH_PROJECTILE)
    local dist = start:Manhattan(target)
    
    if dist <= self.RangeThreshold then
        --Short range
        local damage = SpaceDamage(target, self.ShortRangeDamage, dir)
        ret:AddProjectile(start, damage, self.ShortRangeProjectileArt, NO_DELAY) --thx tosx! (the delay is also mandatory)
    else
        --Long range
        local damage = SpaceDamage(target, self.LongRangeDamage, dir)
        ret:AddProjectile(start, damage, self.ShortRangeProjectileArt, NO_DELAY) --thx tosx! (the delay is also mandatory)
    end
end

function truelch_DualAutocannons:GetSkillEffect(p1, p2)
    local ret = SkillEffect()
    local direction = GetDirection(p2 - p1)

    local left  = p1 - DIR_VECTORS[(direction + 1)% 4]
    local right = p1 + DIR_VECTORS[(direction + 1)% 4]

    if p2.x == p1.x or p2.y == p1.y then --Both
        self:Shot(ret, left, direction)
        self:Shot(ret, right, direction)
    elseif p2.x == left.x or p2.y == left.y then
        self:Shot(ret, left, direction)
    elseif p2.x == right.x or p2.y == right.y then
        self:Shot(ret, right, direction)
    else
        LOG("What?")
    end

    return ret
end