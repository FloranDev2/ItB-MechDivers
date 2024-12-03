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
	--Description = "Shoot a pushing projectile. Shoot again at the start of next turn if the Mech moved 1 tile or less.".. --or didn't use ALL its move?
    --    "\nThis weapon will be removed at the end of the mission.",
    Description = "Shoot a pushing projectile dealing 1 damage."..
        "\nShoot again just before the Vek act if the Mech moved less than half its move (rounded down)."..
        "\nShoot a third projectile at the end of Vek turn if the Mech was immobile.".. --BRRRRRRT
        "\n\nThis weapon will be removed at the end of the mission.",

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

    --Tip image
    --Gonna do it reverse to show the full effect without having to wait one year...
    --Step 1: immobile -> 3 projectiles. Step 2: half-move: ->
    TipStage = 1,
    TipImage = {
        Unit   = Point(2, 4),
        Target = Point(2, 2),

        Enemy  = Point(2, 3),
        Enemy2 = Point(2, 2),
        Enemy3 = Point(2, 0),

        Building = Point(0, 0),

        CustomEnemy = "Scarab1",
    }
}


function truelch_mg43MachineGun:GetTargetArea(point)
    return Board:GetSimpleReachable(point, INT_MAX, false) --I guess
end


function truelch_mg43MachineGun:TipImmobile(p1, p2)
    --From confuse shot
    --[[
    local ret = SkillEffect()
    ret.piOrigin = Point(2,3)
    local damage = SpaceDamage(0)
    damage.bHide = true
    damage.sScript = "Board:GetPawn(Point(2,1)):FireWeapon(Point(2,2),1)"
    ret:AddDamage(damage)
    damage = SpaceDamage(0)
    damage.bHide = true
    damage.fDelay = 1.5
    ret:AddDamage(damage)
    local damage = SpaceDamage(p2,0,DIR_FLIP)
    damage.bHide = true
    damage.sAnimation = "ExploRepulse3"--"airpush_"..GetDirection(p2 - p1)
    ret:AddProjectile(damage,"effects/shot_confuse")
    return ret
    ]]

    local ret = SkillEffect()

    --Prepare enemy attack

    --(No move) -> nothing todo
    --Board:AddAlert("")

    --1st shot

    --2nd shot

    --3rd shot

    return ret
end

function truelch_mg43MachineGun:TipHalfMove(p1, p2)
    --Prepare enemy attack

    --Half move

    --1st shot

    --2nd shot
end

function truelch_mg43MachineGun:TipFullMove(p1, p2)
    --Prepare enemy attack

    --Full move

    --1 shot

    --Enemy attack
end

function truelch_mg43MachineGun:GetSkillEffect_TipImage(p1, p2)
    if self.TipStage == 1 then
        self.TipStage = 2
        return self:TipImmobile(p1, p2)
    elseif self.TipStage == 2 then
        self.TipStage = 3
        return self:TipHalfMove(p1, p2)
    else
        self.TipStage = 1
        self:TipHalfMove(p1, p2)
    end
end

function truelch_mg43MachineGun:GetSkillEffect_Normal(p1, p2)
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

function truelch_mg43MachineGun:GetSkillEffect(p1, p2)
    if not Board:IsTipImage() then
        self:GetSkillEffect_Normal(p1, p2)
    else
        self:GetSkillEffect_TipImage(p1, p2)
    end
end


--Sniper: minimum range, PULL, (or confuse if at a certain range), or TC (p2 == p3 => confuse, otherwise pull?)
--[[
    Icon = "weapons/brute_sniper.png",
    ProjectileArt = "effects/shot_sniper",
    LaunchSound = "/weapons/raining_volley",
    ImpactSound = "/impact/generic/explosion",
]]

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

    --[[
    if weaponId == "truelch_mg43MachineGun" then

    end
    ]]
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