truelch_Test = Skill:new{
    --Infos
	Name = "Test",
    Class = "Prime",
    Description = "Test",
	PowerCost = 1,

    --Art
	Icon = "weapons/truelch_dual_autocannon.png",
	Sound = "", --"/general/combat/explode_small"
	LaunchSound = "", --"/weapons/modified_cannons"
	ImpactSound = "", --"/impact/generic/explosion"

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

function truelch_Test:GetTargetArea(point)
    local ret = PointList()    

    for j = 0, 7 do
        for i = 0, 7 do
            local curr = Point(i, j)
            ret:push_back(curr)
        end
    end

    return ret
end

function truelch_Test:GetSkillEffect(p1, p2)
    local ret = SkillEffect()

    --https://gist.github.com/Tarmean/bf415d920eecb4b2bbdd32de2ba75924
    local damage = SpaceDamage(p2, 2)
    --damage.sSound = "/impact/generic/explosion"
    --damage.sSound = "/ui/battle/mech_drop" --doesn't work
    --damage.sSound = "/mech/distance/artillery/death" --works
    --damage.sSound = "/props/pylon_impact"
    --damage.sSound = "/props/pylon_fall"
    damage.sSound = "/mech/land" --THIS
    ret:AddDamage(damage)

    return ret
end