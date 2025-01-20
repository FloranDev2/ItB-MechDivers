--Interesting (and undocumented?): IsPassiveSkill("tatu_Acid_Passive")

--[[
Good to know: new Mech spawned with this won't be at index 0 - 2 in the list of pawns, and won't have an idea between 0 - 2 either.
So getting mechs by looping from 0 to 2 doesn't work anymore!
]]

truelch_Reinforcements_Passive = PassiveSkill:new{
	--Infos
	Name = "Reinforcements",
	Description = "The first time a Mech is destroyed, drop a new Mech randomly on the map the next turn.",
	PowerCost = 1,
	Icon = "weapons/truelch_reinforcement_passive.png",

	--Upgrades
	Upgrades = 1,
	UpgradeCost = { 1 },
	FastRespawn = false, --for tip image

	--Passive
	Passive = "truelch_Reinforcements_Passive",

	--Tip image
	TipIndex = 0,
	TipImage = {
		Unit = Point(2, 3),
		CustomPawn = "truelch_EagleMech",
		Target = Point(2, 2),
		Friendly = Point(1, 1),
	}
}

Weapon_Texts.truelch_Reinforcements_Passive_Upgrade1 = "Faster respawn"

truelch_Reinforcements_Passive_A = truelch_Reinforcements_Passive:new{
	UpgradeDescription = "Reinforcements come now instantly!",
	FastRespawn = true,
	Passive = "truelch_Reinforcements_Passive_A", --test
}

function truelch_Reinforcements_Passive:GSE0(p1, p2)
	local ret = SkillEffect()

	--Dead mech(s)
	local damage = SpaceDamage(Point(1, 1), DAMAGE_DEATH)
	damage.bHide = true
	ret:AddDamage(damage)

	return ret
end

function truelch_Reinforcements_Passive:GSE1(p1, p2)
	local ret = SkillEffect()

	Board:GetPawn(Point(1, 1)):SetHealth(0)

	if self.FastRespawn then
		Board:AddAlert(Point(2, 3), "Same turn")		
	else
		Board:AddAlert(Point(2, 3), "New turn")
	end

	ret:AddDelay(2)

    local pawnType = Board:GetPawn(Point(1, 1)):GetType() --or this? Edit: at least this works
    local newMech = PAWN_FACTORY:CreatePawn(pawnType) --this works! And also have the correct palette (idk how, but that's great)
    newMech:SetMech()
    Board:SpawnPawn(newMech, Point(1, 2))

	return ret
end

function truelch_Reinforcements_Passive:GetSkillEffect(p1, p2)
	--LOG("truelch_Reinforcements_Passive:GetSkillEffect -> fast respawn: "..tostring(self.FastRespawn))

	if self.TipIndex == 0 then
		self.TipIndex = 1
		return self:GSE0(p1, p2)
	else
		self.TipIndex = 0
		return self:GSE1(p1, p2)
	end
end