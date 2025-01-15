local this = {}
local path = mod_loader.mods[modApi.currentMod].scriptPath
local resources = mod_loader.mods[modApi.currentMod].resourcePath

local test_p1
local test_p2

atlas_ShellStd = {
	aFM_name = "Standard Shell",												 -- required
	aFM_desc = "High-explosive shell that explodes upon impact.",				 -- required
	aFM_icon = "img/modes/icon_minigun.png",	 						 -- required (if you don't have an image an empty string will work) 
	-- aFM_limited = 2, 														 -- optional (FMW will automatically handle uses for weapons)
	-- aFM_handleLimited = false 												 -- optional (FMW will no longer automatically handle uses for this mode if set) 
	minrange = 2,
	maxrange = 8,
	innerDamage = 2,
	innerEffect = nil,
	innerPush = false,
	innerAnim = "ExploArt2",
	innerBounce = 2, 
	AOE = true, 
	outerDamage = 1,
	outerEffect = nil, -- "Fire", "Smoke", "Acid", "Frozen" 
	outerPush = true,
	outerAnim = "explopush1_",
	outerBounce = 1,
	impactsound = "/impact/generic/explosion_large",
	image = "effects/shotup_tribomb_missile.png",
}

CreateClass(atlas_ShellStd)

-- these functions, "targeting" and "fire," are arbitrary
function atlas_ShellStd:targeting(point)
	local points = {}

	for dir = 0, 3 do
		for i = self.minrange, self.maxrange do
			local curr = point + DIR_VECTORS[dir]*i
			points[#points+1] = curr
		end
	end
	return points
end

function atlas_ShellStd:fire(p1, p2, se)
	local direction = GetDirection(p2 - p1)

	local damage = SpaceDamage(p2, self.innerDamage)
	
	if ANIMS[self.innerAnim .. direction] then
		damage.sAnimation = self.innerAnim .. direction
	else
		damage.sAnimation = self.innerAnim
	end	
	
	if self.innerPush then damage.iPush = DIR_VECTORS[direction] end
	if self.innerEffect then damage['i' .. self.innerEffect] = 1 end
		
	se:AddArtillery(damage, self.image) 
	se:AddBounce(p2, self.innerBounce)

	if self.AOE then
        for dir = 0, 3 do
			local aoeD = SpaceDamage(p2 + DIR_VECTORS[dir], self.outerDamage)
				
			if ANIMS[self.outerAnim .. dir] then 
				aoeD.sAnimation = self.outerAnim .. dir
			else
				aoeD.sAnimation = self.outerAnim
			end
			
			if self.outerPush then aoeD.iPush = dir end
			if self.outerEffect then aoeD['i' .. self.outerEffect] = 1 end
				
			se:AddDamage(aoeD) 
			se:AddBounce(p2 + DIR_VECTORS[dir], self.outerBounce) 
		end	
	end	
end


atlas_ShellFire = atlas_ShellStd:new{
	aFM_name = "Napalm Shell",
	aFM_desc = "Explosive shell that sets an area on fire.",
	aFM_icon = "img/modes/icon_rocket_pod.png",
	--aFM_limited = 2,
    aFM_twoClick = true,
    
	innerDamage = 1, 
	innerEffect = "Fire",
	innerAnim = "ExploAir2",
	outerDamage = 0,
	outerEffect = "Fire",
	outerAnim = "explopush2_",
	image = "effects/shotup_tribomb_missile.png",
}

function atlas_ShellFire:second_targeting(p1, p2) 
    return Ranged_TC_BounceShot.GetSecondTargetArea(Ranged_TC_BounceShot, p1, p2)
end

function atlas_ShellFire:second_fire(p1, p2, p3)
    return Ranged_TC_BounceShot.GetFinalEffect(Ranged_TC_BounceShot, p1, p2, p3)
end

function atlas_ShellFire:isTwoClickExc(p1, p2)

	if test_p1 == nil then
		LOG("test_p1 is nil!")
	else
		LOG("test_p1: "..test_p1:GetString())
	end

	if test_p2 == nil then
		LOG("test_p2 is nil!")
	else
		LOG("test_p2: "..test_p2:GetString())
	end


	if p1 == nil or p2 == nil then
		LOG(">>> atlas_ShellFire:isTwoClickExc(PROBLEM WITH P1 AND / OR P2) <<<")
		if p1 == nil then LOG("p1 == nil") end
		if p2 == nil then LOG("p2 == nil") end
	else
		LOG(string.format(">>> atlas_ShellFire:isTwoClickExc(p1: %s, p2: %s)", p1:GetString(), p2:GetString()))
	end

	--FOR SOME FUCKING REASON P2 IS NIL	
	--if Board:IsPawnSpace(p2) then
	if Board:IsPawnSpace(test_p2) then
		LOG("------- return true")
		return true
	else
		LOG("------- return false")
		return false
	end
end

atlas_Mortar = aFM_WeaponTemplate:new{
	Name = "Mortar",
	Description = "bloop",
	Class = "Ranged",
    TwoClick = true, 
	Icon = "weapons/truelch_patriot_weapons.png",
	LaunchSound = "/weapons/back_shot",
	aFM_ModeList = {"atlas_ShellStd", "atlas_ShellFire"},
	aFM_ModeSwitchDesc = "Click to change Mortar shells.",
	TipImage = {
		Unit = Point(2,2) 
	}
}


function atlas_Mortar:GetTargetArea(point)
	local pl = PointList()
	local currentShell = _G[self:FM_GetMode(point)]
    
	if self:FM_CurrentModeReady(point) then 
		local points = currentShell:targeting(point)
		
		for _, p in ipairs(points) do
			pl:push_back(p)
		end
	end
	 
	return pl
end

function atlas_Mortar:GetSkillEffect(p1, p2)
	local se = SkillEffect()
	local currentShell = self:FM_GetMode(p1)
	
	if self:FM_CurrentModeReady(p1) then 
		_G[currentShell]:fire(p1, p2, se)
		se:AddSound(_G[currentShell].impactsound)
	end

	return se
end

function atlas_Mortar:IsTwoClickException(p1, p2)

	if p1 == nil or p2 == nil then
		LOG(">>> atlas_Mortar:IsTwoClickException(PROBLEM WITH P1 AND / OR P2) <<<")
		if p1 == nil then LOG("p1 == nil") end
		if p2 == nil then LOG("p2 == nil") end
	else
		LOG(string.format(">>> atlas_Mortar:IsTwoClickException(p1: %s, p2: %s)", p1:GetString(), p2:GetString()))
	end

	test_p1 = p1
	test_p2 = p2

	if _G[self:FM_GetMode(p1)].isTwoClickExc then
		LOG("----------- [IF] isTwoClickExc exists!")
		local mode = self:FM_GetMode(p1)
		LOG("----------- mode: "..tostring(mode).." p1, p2 after:...")

		if p1 == nil or p2 == nil then
			if p1 == nil then LOG("p1 == nil") end
			if p2 == nil then LOG("p2 == nil") end
		else
			LOG(string.format("p1: %s, p2: %s", p1:GetString(), p2:GetString()))
			LOG(string.format("test_p1: %s, test_p2: %s", p1:GetString(), p2:GetString()))
		end

		local isTCexc = _G[self:FM_GetMode(p1)].isTwoClickExc(p1, p2)
		LOG("-----------> isTCexc: "..tostring(isTCexc))
		return _G[self:FM_GetMode(p1)].isTwoClickExc(p1, p2)
	else
		LOG("----------- [ELSE] isTwoClickExc DOES NOT EXIST")
		local isTCexc = not _G[self:FM_GetMode(p1)].aFM_twoClick
		LOG("-----------> isTCexc: "..tostring(isTCexc))
		return not _G[self:FM_GetMode(p1)].aFM_twoClick
	end
end

function atlas_Mortar:GetSecondTargetArea(p1, p2)
	local currentShell = _G[self:FM_GetMode(p1)]
    local pl = PointList()
    
	if self:FM_CurrentModeReady(p1) and currentShell.aFM_twoClick then 
		pl = currentShell:second_targeting(p1, p2)
	end
    
    return pl 
end

function atlas_Mortar:GetFinalEffect(p1, p2, p3) 
    local se = SkillEffect()
	local currentShell = _G[self:FM_GetMode(p1)]

	if self:FM_CurrentModeReady(p1) and currentShell.aFM_twoClick then 
		se = currentShell:second_fire(p1, p2, p3)  
	end
    
    return se 
end

return this 