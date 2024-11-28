local this = {}
local path = mod_loader.mods[modApi.currentMod].scriptPath
local resources = mod_loader.mods[modApi.currentMod].resourcePath
--local fmw = require(path.."fmw/api") 

modApi:appendAsset("img/mortar_temp_icon.png", resources.."img/mortar_temp_icon.png")
modApi:appendAsset("img/shells/icon_standard_shell.png", resources.."img/shells/icon_standard_shell.png")
modApi:appendAsset("img/shells/icon_napalm_shell.png", resources.."img/shells/icon_napalm_shell.png")
modApi:appendAsset("img/shells/icon_acid_shell.png", resources.."img/shells/icon_acid_shell.png")
modApi:appendAsset("img/shells/icon_smoke_shell.png", resources.."img/shells/icon_smoke_shell.png")

modApi:appendAsset("img/effects/shotup_standardshell_missile.png", resources.."img/effects/shotup_standardshell_missile.png")
modApi:appendAsset("img/effects/shotup_napalmshell_missile.png", resources.."img//effects/shotup_napalmshell_missile.png")
modApi:appendAsset("img/effects/shotup_acidshell_missile.png", resources.."img/effects/shotup_acidshell_missile.png")
modApi:appendAsset("img/effects/shotup_smokeshell_missile.png", resources.."img/effects/shotup_smokeshell_missile.png")

-------------------- SPRITES --------------------
local mod = mod_loader.mods[modApi.currentMod]
local scriptPath = mod.scriptPath
local resourcePath = mod.resourcePath
modApi:appendAsset("img/modes/icon_resupply.png", resourcePath.."img/modes/icon_resupply.png")
modApi:appendAsset("img/modes/icon_strafe.png",   resourcePath.."img/modes/icon_strafe.png")


-------------------- MODE 1: Strafe run --------------------
	
truelch_DeliveryMode1 = {
	aFM_name = "Strafing run",						 -- required
	aFM_desc = "Leap over a tile and bombard it.",	 -- required
	aFM_icon = "img/shells/icon_standard_shell.png", -- required (if you don't have an image an empty string will work) 
	-- aFM_limited = 2, 							 -- optional (FMW will automatically handle uses for weapons)
	-- aFM_handleLimited = false 					 -- optional (FMW will no longer automatically handle uses for this mode if set)
}

CreateClass(truelch_DeliveryMode1)

function truelch_DeliveryMode1:targeting(point)
	local points = {}
	for dir = DIR_START, DIR_END do
		local curr = DIR_VECTORS[dir]*2 + point
		if not Board:IsBlocked(curr, PATH_PROJECTILE) then
			points[#points+1] = curr
		end
	end
	return points
end

function truelch_DeliveryMode1:fire(p1, p2, se)
	local dir = GetDirection(p2 - p1)
	
	local move = PointList()
	move:push_back(p1)
	move:push_back(p2)
	
	local distance = p1:Manhattan(p2)
	
	se:AddBounce(p1,2)
	if distance == 1 then
		se:AddLeap(move, 0.5)--small delay between move and the damage, attempting to make the damage appear when jet is overhead
	else
		se:AddLeap(move, 0.25)
	end

	--[[
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
	]]
end


-------------------- MODE 2: Supply drop --------------------

truelch_DeliveryMode2 = truelch_DeliveryMode1:new{
	aFM_name = "Supply drop",
	aFM_desc = "Drop a Supply Box that reloads weapons.",
	aFM_icon = "img/shells/icon_napalm_shell.png",
	aFM_limited = 2,
    aFM_twoClick = true,
}

function truelch_DeliveryMode2:second_targeting(p1, p2) 
    return Ranged_TC_BounceShot.GetSecondTargetArea(Ranged_TC_BounceShot, p1, p2)
end

function truelch_DeliveryMode2:second_fire(p1, p2, p3)
    return Ranged_TC_BounceShot.GetFinalEffect(Ranged_TC_BounceShot, p1, p2, p3)
end


-------------------- WEAPON --------------------

truelch_Delivery = aFM_WeaponTemplate:new{
	Name = "Delivery",
	Description = "Drop various playloads.",
	Class = "Science",
    TwoClick = true, 
	Icon = "mortar_temp_icon.png",
	LaunchSound = "/weapons/back_shot",
	aFM_ModeList = {"truelch_DeliveryMode1", "truelch_DeliveryMode2"},
	aFM_ModeSwitchDesc = "Click to change Mortar shells.",
	TipImage = {
		Unit = Point(2,2) 
	}
}

function truelch_Delivery:GetTargetArea(point)
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

function truelch_Delivery:GetSkillEffect(p1, p2)
	local se = SkillEffect()
	local currentShell = self:FM_GetMode(p1)
	
	if self:FM_CurrentModeReady(p1) then 
		_G[currentShell]:fire(p1, p2, se)
		--se:AddSound(_G[currentShell].impactsound)
	end

	return se
end

function truelch_Delivery:IsTwoClickException(p1,p2)
	return not _G[self:FM_GetMode(p1)].aFM_twoClick 
end

function truelch_Delivery:GetSecondTargetArea(p1, p2)
	local currentShell = _G[self:FM_GetMode(p1)]
    local pl = PointList()
    
	if self:FM_CurrentModeReady(p1) and currentShell.aFM_twoClick then 
		pl = currentShell:second_targeting(p1, p2)
	end
    
    return pl 
end

function truelch_Delivery:GetFinalEffect(p1, p2, p3) 
    local se = SkillEffect()
	local currentShell = _G[self:FM_GetMode(p1)]

	if self:FM_CurrentModeReady(p1) and currentShell.aFM_twoClick then 
		se = currentShell:second_fire(p1, p2, p3)  
	end
    
    return se 
end

return this 