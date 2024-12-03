--Credit: thx metalo to share a working snippet of code for side projectiles!

truelch_dualAutocannons = Skill:new{
    --Info
	Name = "Dual Autocannons",
    Class = "Prime",
    Description = "Shoot 2 pushing projectiles from either sides or just to one side. If the target is 2 tiles away or less, the projectile deal 1 damage.",
	PowerCost = 0,

    --Art
	Icon = "weapons/truelch_dual_autocannon.png",
	Sound = "/general/combat/explode_small",
	LaunchSound = "/weapons/modified_cannons",
	ImpactSound = "/impact/generic/explosion",
    ShortRangeProjectileArt = "effects/shot_mechtank", --damage
    LongRangeProjectileArt = "effects/shot_mechtank", --harmless

    --Gameplay
    ShortRangeDamage = 1,
    LongRangeDamage = 0,
    RangeThreshold = 2,

    --Tip image
    TipImage = {
        Unit   = Point(2, 4),
        Target = Point(2, 2),
        Enemy  = Point(1, 3),
        Enemy2 = Point(3, 1),
        CustomPawn = "truelch_EmancipatorMech",
    }
}

function truelch_dualAutocannons:GetTargetArea(point)
    --return Board:GetSimpleReachable(point, INT_MAX, false)

    LOG("truelch_dualAutocannons:GetTargetArea(point: "..point:GetString()..")")
    local ret = PointList()
    for dir = DIR_START, DIR_END do
        for i = 1, 7 do
            local curr = Point(point + DIR_VECTORS[dir] * i)
            if Board:IsValid(curr) then
                ret:push_back(curr)
                LOG(" ---------> added: "..curr:GetString())
            else
                break
            end

            --[[
            --Add sides! (to only shoot sideways if the player want)
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
            ]]
        end
    end
    
    return ret
end

function truelch_dualAutocannons:Shot(ret, p1, p2, offset, dir, i)
    local curr = p1 + offset * i
    local target = GetProjectileEnd(curr, p2 + offset * i)
    local damage = SpaceDamage(target, 1, dir)
    ret:AddProjectile(curr, damage, "effects/shot_mechtank", NO_DELAY)
end

function truelch_dualAutocannons:GetSkillEffect(p1, p2)
    local ret = SkillEffect()
    local dir = GetDirection(p2 - p1)
    local offset = DIR_VECTORS[(dir+1)%4]
    truelch_dualAutocannons:Shot2(ret, p1, p2, offset, dir, -1)
    truelch_dualAutocannons:Shot2(ret, p1, p2, offset, dir, 1)
    return ret
end