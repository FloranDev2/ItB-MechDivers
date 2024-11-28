local this = {}
local mod = mod_loader.mods[modApi.currentMod]
local scriptPath = mod.scriptPath
local resources = mod.resourcePath

local fmw = require(scriptPath.."fmw/api") 
--local tips = require(scriptPath.."libs/tutorialTips")

--Icons

--Just debug modes icons
for i = 1, 10 do
	modApi:appendAsset("img/modes/icon_1.png", resources.."img/modes/icon_1.png")
end

truelch_Mode1 = {
	aFM_name = "Mode1",
	aFM_desc = "Projectile that pushes its target.",
	aFM_icon = "img/shells/icon_standard_shell.png",

	aFM_limited = 2,

	--Art
	impactsound = "/impact/generic/explosion_large",
	Explo = "explopush1_",
	ProjectileArt = "effects/shot_m22_push", --ProjectileArt = "effects/shot_mechtank",
}

CreateClass(truelch_Mode1)

function truelch_Mode1:targeting(point)
	local points = {}
	
	for dir = 0, 3 do
		for i = 1, 8 do
			local curr = point + DIR_VECTORS[dir] * i

			if not Board:IsValid(curr) then --non valid points are point outside the map [0;7]
				break
			end

			points[#points+1] = curr

			if Board:IsBlocked(curr, PATH_PROJECTILE) then
				break
			end
		end
	end	

	return points
end

function truelch_ShellStd:fire(p1, p2, ret, dmg)
	local dir = GetDirection(p2 - p1)

	local target = GetProjectileEnd(p1, p2)

	if self.Push == 1 then
		local damage = SpaceDamage(target, dmg, dir)
		ret:AddProjectile(damage, self.ProjectileArt)
	else
		local damage = SpaceDamage(target, dmg)
		damage.iSmoke = 1
		ret:AddProjectile(damage, self.ProjectileArt)
	end
end

function truelch_ShellStd:GetProjectileEnd(p1, p2)
	profile = PATH_PROJECTILE
	local direction = GetDirection(p2 - p1)

	local target = p1 + DIR_VECTORS[direction]

	while not Board:IsBlocked(target, profile) do
		target = target + DIR_VECTORS[direction]
	end

	if not Board:IsValid(target) then
		target = target - DIR_VECTORS[direction]
	end
	
	return target
end

truelch_ShellSmoke = truelch_ShellStd:new{
	aFM_name = "Smoke Shell",
	aFM_desc = "Non-explosive shell that creates Smoke.",
	aFM_icon = "img/shells/icon_smoke_shell.png",	
	--Custom
	Push = 0,
	Smoke = 1,
	--Art
	impactsound = "/impact/generic/explosion_large",
	Explo = "explopush1_",
	ProjectileArt = "effects/shot_m22_smoke",
}

--truelch_M6Gun
truelch_FMW_M6Gun = aFM_WeaponTemplate:new{
	Name = "M6 Gun", --"M6 Gun"
	Description = "Versatile non-damaging gun that shoots either smoke or push shells.\nTo switch shell, arm the weapon and click on the shell icon on the right.",
	Class = "Science",
	Upgrades = 1,
	UpgradeCost = { 1 },
	Icon = "weapons/science_canisterround.png",
	--Icon = "science_canisterround.png", 	--Icon = "/weapons/science_canisterround.png",
	LaunchSound = "/weapons/back_shot",
	aFM_ModeList = {"truelch_ShellStd", "truelch_ShellSmoke"},
	aFM_ModeSwitchDesc = "Click to change shells.",

	--Custom!
	TipImage = StandardTips.Ranged,
	PowerCost = 0, --Setting it works (I set it to 0 because it's the value I want, but it works!)
	Damage = 0,
	Rarity = 1,
}
Weapon_Texts.truelch_FMW_M6Gun_Upgrade1 = "+1 Damage"

truelch_FMW_M6Gun_A = truelch_FMW_M6Gun:new{
	UpgradeDescription = "Both shells now deal 1 damage.",
	Damage = 1,
}

function truelch_FMW_M6Gun:GetTargetArea(point)
	local pl = PointList()
	
	local mission = GetCurrentMission()
	if mission and not Board:IsTipImage() and not IsTestMechScenario() then
		tips:Trigger("M6GunFMW", point)
	end	

	local currentShell = _G[self:FM_GetMode(point)]
	if self:FM_CurrentModeReady(point) then
		local points = currentShell:targeting(point)
		for _, p in ipairs(points) do
			pl:push_back(p)
		end
	end
	return pl
end

function truelch_FMW_M6Gun:GetSkillEffect(p1, p2)
	local se = SkillEffect()
	local currentShell = self:FM_GetMode(p1)
	
	if self:FM_CurrentModeReady(p1) then 
		_G[currentShell]:fire(p1, p2, se, self.Damage)
	end

	return se
end


---------------------------------------------------------------


truelch_TC_M6Gun = TankDefault:new{
	Name = "M6 Gun", --"M6 Gun"
	Class = "Science",
	Description = "Versatile non-damaging gun that shoots either smoke or push shells.\nSecond click behind the target pushes it, otherwise, smokes it.",
	Icon = "weapons/science_canisterround.png",
	Rarity = 1,

	LaunchSound = "/weapons/back_shot",
	ImpactSound = "/impact/generic/explosion_large",
	ProjectileArtSmoke = "effects/shot_m22_smoke",
	ProjectileArtPush = "effects/shot_m22_push",
	Explo = "explopush1_",

	PowerCost = 0,
	Damage = 0,

	TwoClick = true,
	ZoneTargeting = DIR,

	Upgrades = 1,
	UpgradeCost = { 1 },

	TipImage = {
		Unit = Point(2, 3),
		Enemy = Point(2, 1),
		Target = Point(2, 1),
		Second_Click = Point(2, 0),
	}
}

Weapon_Texts.truelch_TC_M6Gun_Upgrade1 = "+1 Damage"

truelch_TC_M6Gun_A = truelch_TC_M6Gun:new{
	UpgradeDescription = "Both shells now deal 1 damage.",
	Damage = 1,
}

function truelch_TC_M6Gun:GetSkillEffect(p1, p2)
	local ret = SkillEffect()
	local damage = SpaceDamage(p2, 0)
	local direction = GetDirection(p2 - p1)
	ret:AddDamage(damage)
	return ret
end

function truelch_TC_M6Gun:GetSecondTargetArea(p1, p2)
	local ret = PointList()
	local direction = GetDirection(p2 - p1)

	ret:push_back(p2)
	if Board:IsValid(p2 + DIR_VECTORS[direction]) then
		ret:push_back(p2 + DIR_VECTORS[direction])
	end
	
	return ret
end

function truelch_TC_M6Gun:GetFinalEffect(p1, p2, p3)
	local ret = SkillEffect()
	local target = GetProjectileEnd(p1, p2, PATH_PROJECTILE)
	local damage = SpaceDamage(target, self.Damage)

	if p3 == p2 then
		damage.iSmoke = 1
		ret:AddProjectile(damage, self.ProjectileArtSmoke)
	else
		local dir = GetDirection(p2 - p1)
		damage.iPush = dir
		damage.sAnimation = self.Explo .. dir
		ret:AddProjectile(damage, self.ProjectileArtPush)
	end

	return ret	
end

return this