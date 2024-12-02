----------------------------------------------- MISSION / GAME FUNCTIONS -----------------------------------------------

local function isGame()
    return true
        and Game ~= nil
        and GAME ~= nil
end

local function gameData()
    if GAME.truelch_MechDivers == nil then
        GAME.truelch_MechDivers = {}
    end

    --Acquired stratagems
    if GAME.truelch_MechDivers.Stratagems == nil then
        GAME.truelch_MechDivers.Stratagems = {}
    end

    return GAME.truelch_MechDivers
end

local function isMission()
    local mission = GetCurrentMission()

    return true
        and isGame()
        and mission ~= nil
        and mission ~= Mission_Test
end

local function missionData()
    local mission = GetCurrentMission()

    if mission.truelch_MechDivers == nil then
        mission.truelch_MechDivers = {}
    end

    --List of pawn elligible to shoot again
    --Wait, I can just queue another attack!
    --Depends if I want it to happen before or after the enemies play
    --[[
    if mission.truelch_MechDivers.m43DoubleShots == nil then
        mission.truelch_MechDivers.m43DoubleShots = {}
    end
    ]]

    return mission.truelch_MechDivers
end


----------------------------------------------- UTILITY FUNCTIONS -----------------------------------------------

local stratagemWeapons = {
    "truelch_mg43MachineGun",
}

local function isStratagemWeapon(weaponId)
    if type(weaponId) == 'table' then
        weaponId = weaponId.__Id
    end

    for _, stratagemWeapon in pairs(stratagemWeapons) do
        if weaponId == stratagemWeapon then
            return true
        end
    end

    return false
end


----------------------------------------------- SUPPORT WEAPONS -----------------------------------------------

--Description = "A machine gun designed for stationary use. Trades higher power for increased recoil and reduced accuracy.",
--Class = "Any", --Actually need to not specify a class so that I can AddWeapon

--Can we have upgraded drop weapons?
truelch_mg43MachineGun = Skill:new {
	--Infos
	Name = "MG-43 Machine Gun",
    Class = "", --test
	Description = "Shoot a pushing projectile. Shoot again at the start of next turn if the Mech moved 1 tile or less.".. --or didn't use ALL its move?
        "\nThis weapon will be removed at the end of the mission.",
	PowerCost = 0, --Can I also remove this?

	--Art
	Icon = "weapons/brute_tankmech.png",
	Sound = "/general/combat/explode_small",
	LaunchSound = "/weapons/modified_cannons",
	ImpactSound = "/impact/generic/explosion",
    Projectile = "effects/shot_mechtank",
    Explosion = "",

	--Gameplay
	Damage = 1,
    Push = 1,
    QueuedDamage = 1,
    QueuedPush = 1,

	TipImage = StandardTips.Ranged,
}


function truelch_mg43MachineGun:GetTargetArea(point)
    return Board:GetSimpleReachable(point, INT_MAX, false) --I guess
end

function truelch_mg43MachineGun:GetSkillEffect(p1, p2)
    --Some vars
    local ret = SkillEffect()
    local direction = GetDirection(p2 - p1)            
    local target = GetProjectileEnd(p1, p2)
    
    --Regular shot
    local damage = nil
    if self.Push == 1 then
        damage = SpaceDamage(target, self.Damage, direction)
    else
        damage = SpaceDamage(target, self.Damage)
    end
    ret:AddProjectile(damage, self.Projectile)

    --Additional queued shot (OR add to mission data to shoot AFTER enemy turn)
    local queuedDamage = nil
    if self.QueuedPush == 1 then
        queuedDamage = SpaceDamage(target, self.QueuedDamage, direction)
    else
        queuedDamage = SpaceDamage(target, self.QueuedDamage)
    end
    ret:AddQueuedProjectile(queuedDamage, self.Projectile)

    --Return
    return ret
end



----------------------------------------------- ??? WEAPONS -----------------------------------------------


----------------------------------------------- TEST -----------------------------------------------

--[[
truelch_testQueueWeapon = Skill:new{
    --Infos
    Name = "Test queue weapon",
    Description = "Queue an attack lowl.",
    PowerCost = 0,
    --Art
    Icon = "weapons/brute_tankmech.png",

    --TipImage = StandardTips.Ranged,
}

function truelch_testQueueWeapon:GetTargetArea(point)
    local ret = PointList()

    for j = 0, 7 do
        for i = 0, 7 do
            local curr = Point(i, j)
            ret:push_back(curr)
        end
    end

    return ret
end

function truelch_testQueueWeapon:GetSkillEffect(p1, p2)
    local ret = SkillEffect()
    local dir = GetDirection(p2 - p1)
    ret:AddQueuedArtillery(SpaceDamage(p2, 2), "effects/shotup_crab1.png")
    return ret
end
]]


----------------------------------------------- HOOKS -----------------------------------------------

local function HOOK_onNextTurnHook()
    --if Game:GetTeamTurn() == TEAM_PLAYER then
	if Game:GetTeamTurn() == TEAM_ENEMY then --might be even more funny
        --Going through all mechs like this instead of 0 -> 1 because freshly spawned Mech don't have 0 - 2 ids
        local size = Board:GetSize()
        for j = 0, size.y do
        	for i = 0, size.x do
        		local pawn = Board:GetPawn(Point(i, j))
        		if pawn ~= nil and pawn:IsMech() then
                    --pawn:FireWeapon() --TODO
        		end
        	end
        end
    end
end

local HOOK_onSkillEnd = function(mission, pawn, weaponId, p1, p2)
    if type(weaponId) == 'table' then
        weaponId = weaponId.__Id
    end

    --better use the pawn move hook to track the distance
    --if weaponId == "Move" then

    if weaponId == "truelch_mg43MachineGun" then

    end
end

local HOOK_onMissionEnded = function(mission)
    LOG("Mission end!")
    --Destroy all stratagem weapons

    --Look through all Mechs. Remember, respawned Mechs aren't in 0 - 2 index range
    local size = Board:GetSize()
    for j = 0, size.y do
        for i = 0, size.x do
            local pawn = Board:GetPawn(Point(i, j))
            if pawn ~= nil and pawn:IsMech() then
                local weapons = pawn:GetPoweredWeapons()
                for k = 0, 3 do
                    if isStratagemWeapon(weapons[k]) then
                        LOG("---------------> Is stratagem weapon!!! -> REMOVE")
                        pawn:RemoveWeapon(k)
                    end
                end
            end
        end
    end
end

----------------------------------------------- HOOKS / EVENTS SUBSCRIPTION -----------------------------------------------

local function EVENT_onModsLoaded()
    modApi:addNextTurnHook(HOOK_onNextTurnHook)
    modapiext:addSkillEndHook(HOOK_onSkillEnd)
    modApi:addMissionEndHook(HOOK_onMissionEnded)
end

modApi.events.onModsLoaded:subscribe(EVENT_onModsLoaded)