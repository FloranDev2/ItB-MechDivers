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
		--Target = Point(2, 2), --useless?

		Friendly_Damaged = Point(1, 1),
		Friendly2_Damaged = Point(2, 1),
	}
}

Weapon_Texts.truelch_Reinforcements_Passive_Upgrade1 = "Faster respawn"

truelch_Reinforcements_Passive_A = truelch_Reinforcements_Passive:new{
	UpgradeDescription = "Reinforcements come now instantly!",
	Passive = "truelch_Reinforcements_Passive_A", --test
}

function truelch_Reinforcements_Passive:GetSkillEffect_TipImage()
	local ret = SkillEffect()

	--[[
	local board_size = Board:GetSize()
	for j = 0, board_size.y - 1 do
		for i = 0, board_size.x - 1 do		
			local pawn = Board:GetPawn(Point(i, j))
			if pawn:IsMech() then

			end
		end
	end
	]]

	--Respawns
    for _, respawn in pairs(self.TipImageRespawns) do
    	--
    end

	return ret
end

--Useless?
function truelch_Reinforcements_Passive:GetSkillEffect(p1, p2)
	if Board:IsTipImage() then
		return self:GetSkillEffect_TipImage()
	else
		local ret = SkillEffect()
		return ret
	end
end