--Interesting (and undocumented?): IsPassiveSkill("tatu_Acid_Passive")

--[[
Good to know: new Mech spawned with this won't be at index 0 - 2 in the list of pawns, and won't have an idea between 0 - 2 either.
So getting mechs by looping from 0 to 2 doesn't work anymore!
]]

truelch_Reinforcements_Passive = PassiveSkill:new{
	--Infos
	Name = "Reinforcements",
	Description = "Everytime a Mech dies, drop a new Mech randomly on the map.",
	PowerCost = 1,
	Icon = "weapons/truelch_reinforcement_passive.png",

	--Upgrades
	Upgrades = 1,
	UpgradeCost = { 1 },

	--Passive
	Passive = "truelch_Reinforcements_Passive",

	--Tip image
	TipImageRespawns = { Point(0, 0), Point(2, 2) },
	TipImage = {
		Unit = Point(2, 3),
		CustomPawn = "truelch_EagleMech",
		Friendly = Point(1, 1),
		Friendly2 = Point(2, 1),
	}
}

Weapon_Texts.truelch_Reinforcements_Passive_Upgrade1 = "Faster respawn"

truelch_Reinforcements_Passive_A = truelch_Reinforcements_Passive:new{
	UpgradeDescription = "Reinforcements come now instantly!",
	Passive = "truelch_Reinforcements_Passive_A", --test
}

function truelch_Reinforcements_Passive:GetSkillEffect_TipImage()
	local ret = SkillEffect()

	--Kill mechs
	local damage = SpaceDamage(Point(1, 1), DAMAGE_DEATH)
	--damage.bHide = true
	ret:AddDamage(damage)

	local damage = SpaceDamage(Point(2, 1), DAMAGE_DEATH)
	--damage.bHide = true
	ret:AddDamage(damage)

	--Respawns
    for _, respawn in pairs(self.TipImageRespawns) do
    	LOG("respawn: "..respawn:GetString())
    	--Drop Anim
		local dropAnim = SpaceDamage(respawn, 0)
        dropAnim.sAnimation = "truelch_anim_pod_land"
        ret:AddDamage(dropAnim)

        ret:AddDelay(2) --enough?

        ret:AddScript("Board:StartShake(0.5)")

        for dir = DIR_START, DIR_END do
            local curr = respawn + DIR_VECTORS[dir]
            local dust = SpaceDamage(curr, 0)
            dust.sAnimation = "airpush_"..dir --is it the one use for Mechs' deployment?
            ret:AddDamage(dust)
        end

        local damage = SpaceDamage(respawn, 0)
        damage.sPawn = "truelch_PatriotMech"
        ret:AddDamage(damage)
    end

	return ret
end

--Useless?
function truelch_Reinforcements_Passive:GetSkillEffect(p1, p2)
	--Is not called?
	--LOG("truelch_Reinforcements_Passive:GetSkillEffect")

	--return self:GetSkillEffect_TipImage()
	if Board:IsTipImage() then
		return self:GetSkillEffect_TipImage()
	else
		local ret = SkillEffect()
		return ret
	end
end