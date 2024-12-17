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
    if GAME.truelch_MechDivers.stratagems == nil then
        GAME.truelch_MechDivers.stratagems = {}
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

    --[[
    shots = 1 -> 3 (depending on the movement)
    mg43ShootStatus[pawn:GetId()] = { shots, dir }
    Example:
    mg43ShootStatus[0] = { 3, -1 }
    ]]
    if mission.truelch_MechDivers.mg43ShootStatus == nil then
        mission.truelch_MechDivers.mg43ShootStatus = {}
    end

    --
    if mission.truelch_MechDivers.isCharged == nil then
        mission.truelch_MechDivers.isCharged = {}
    end

    return mission.truelch_MechDivers
end

----------------------------------------------- DEBUG -----------------------------------------------
--[[
function debugMissionData(msg)
    LOG("=== debugMissionData("..msg..") ===")
    LOG("mg43ShootStatus:")
    for i, elem in pairs(missionData().mg43ShootStatus) do
        LOG(string.format("i: %s -> shots: %s, dir: %s", tostring(i), tostring(elem[1]), tostring(elem[2])))
    end

    LOG("isCharged:")
    for i, elem in pairs(missionData().isCharged) do
        LOG(string.format("i: %s -> isCharged: ", tostring(i), tostring(elem)))
    end
end
]]

--because putting this logic directly in the AddScript didn't work for some reason...
function truelch_setCharged(pawnId, value)
    missionData().isCharged[pawnId] = value
end

--it seems I also need to do that for that
function truelch_setShootStatus(pawnId, dir)
    --LOG("truelch_setShootStatus(pawnId: "..tostring(pawnId)..", dir: "..tostring(dir)..")")
    if missionData().mg43ShootStatus[Pawn:GetId()] == nil then
        missionData().mg43ShootStatus[Pawn:GetId()] = { 3, dir } --if we're in this case, we assume the Mech didn't move
    else
        missionData().mg43ShootStatus[Pawn:GetId()][2] = dir
    end
end



--Test
--[[
local testList = {}
testList[42] = true
testList[43] = false
LOG("testList: "..save_table(testList))
for i, elem in pairs(testList) do
    LOG(string.format("i: %s, elem: %s", tostring(i), tostring(elem)))
end
LOG("---> testList[42]: "..tostring(testList[42]))
]]

--[[
Result:
    testList: { 
    [43] = false, 
    [42] = true 
    }

    i: 43, elem: false
    i: 42, elem: true
]]


----------------------------------------------- SUPPORT WEAPONS -----------------------------------------------

--"A machine gun designed for stationary use. Trades higher power for increased recoil and reduced accuracy.",
truelch_Mg43MachineGun = Skill:new{
	--Infos
	Name = "MG-43 Machine Gun",
    Class = "",
    Description = "Shoot a pushing projectile dealing 1 damage."..
        "\nShoot again just before the Vek act if the Mech moved less than half its move (rounded down)."..
        "\nShoot a third projectile at the end of Vek turn if the Mech was immobile.".. --BRRRRRRT
        "\n\nThis weapon will be removed at the end of the mission.",

	--Art
	Icon = "weapons/truelch_strat_mg43.png",
	Sound = "/general/combat/explode_small",
	LaunchSound = "/weapons/modified_cannons",
	ImpactSound = "/impact/generic/explosion",
    Projectile = "effects/shot_mechtank",
    Explosion = "",

	--Gameplay
    Limited = 6, --funnily enough, shots fired by queued attack and 3rd shot also consume this
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
        Target = Point(2, 3),

        Enemy  = Point(2, 3),
        Enemy2 = Point(2, 2),
        Enemy3 = Point(2, 1),

        Building = Point(0, 1),

        CustomEnemy = "Scarab1",
    }
}


function truelch_Mg43MachineGun:GetTargetArea(point)
    --LOG("truelch_Mg43MachineGun:GetTargetArea(point)")
    return Board:GetSimpleReachable(point, INT_MAX, false) --I guess
end


function truelch_Mg43MachineGun:TipImmobile(p1, p2)
    local ret = SkillEffect()
    local direction = GetDirection(p2 - p1)

    --Prepare enemy attack
    local damage = SpaceDamage(0)
    damage.bHide = true
    damage.sScript = "Board:GetPawn(Point(2,1)):FireWeapon(Point(0,1),1)"
    ret:AddDamage(damage)

    --(No move) -> nothing todo
    Board:AddAlert(p1, "No move -> 3 shots")

    ret:AddDelay(0.5)

    --1st shot    
    damage = SpaceDamage(Point(2, 3), self.Damage, direction)
    ret:AddProjectile(p1, damage, self.Projectile, FULL_DELAY)
    --Board:AddAlert(p1, "1st shot (instantly)") --isn't displayed

    ret:AddDelay(1)

    --2nd shot
    damage = SpaceDamage(Point(2, 2), self.Damage, direction)
    ret:AddProjectile(p1, damage, self.Projectile, FULL_DELAY)
    --Board:AddAlert(p1, "2nd shot (before enemies turn)") --isn't displayed

    ret:AddDelay(1)

    --3rd shot
    damage = SpaceDamage(Point(2, 1), self.Damage, direction)
    ret:AddProjectile(p1, damage, self.Projectile, NO_DELAY)
    --Board:AddAlert(p1, "3rd shot (after enemies turn)") --isn't displayed

    return ret
end

function truelch_Mg43MachineGun:TipHalfMove(p1, p2)
    local ret = SkillEffect()
    local direction = GetDirection(p2 - p1)

    --Prepare enemy attack
    local damage = SpaceDamage(0)
    damage.bHide = true
    damage.sScript = "Board:GetPawn(Point(2,1)):FireWeapon(Point(0,1),1)"
    ret:AddDamage(damage)

    --Half move
    local mech = Board:GetPawn(p1)
    mech:SetSpace(Point(3, 4))
    ret:AddMove(Board:GetPath(Point(3, 4), p1, PATH_GROUND), FULL_DELAY)
    Board:AddAlert(p1, "Half move -> 2 shots")

    ret:AddDelay(0.5)

    --1st shot    
    damage = SpaceDamage(Point(2, 3), self.Damage, direction)
    ret:AddProjectile(p1, damage, self.Projectile, FULL_DELAY)

    ret:AddDelay(1)

    --2nd shot
    damage = SpaceDamage(Point(2, 2), self.Damage, direction)
    ret:AddProjectile(p1, damage, self.Projectile, FULL_DELAY)

    --Enemy attack

    return ret
end

function truelch_Mg43MachineGun:TipFullMove(p1, p2)
    local ret = SkillEffect()
    local direction = GetDirection(p2 - p1)

    --Prepare enemy attack
    local damage = SpaceDamage(0)
    damage.bHide = true
    damage.sScript = "Board:GetPawn(Point(2,1)):FireWeapon(Point(0,1),1)"
    ret:AddDamage(damage)

    --Full move
    local mech = Board:GetPawn(p1)
    mech:SetSpace(Point(1, 2))
    ret:AddMove(Board:GetPath(Point(1, 2), p1, PATH_GROUND), FULL_DELAY)
    Board:AddAlert(p1, "More than half move -> 1 shot")

    --1st shot    
    damage = SpaceDamage(Point(2, 3), self.Damage, direction)
    ret:AddProjectile(p1, damage, self.Projectile, FULL_DELAY)

    --Enemy attack

    return ret
end

function truelch_Mg43MachineGun:GetSkillEffect_TipImage(p1, p2)
    --LOG("truelch_Mg43MachineGun:GetSkillEffect_TipImage -> self.TipStage: "..tostring(self.TipStage))

    if self.TipStage == 1 then
        self.TipStage = 2
        return self:TipImmobile(p1, p2)
    elseif self.TipStage == 2 then
        self.TipStage = 3
        return self:TipHalfMove(p1, p2)
    else
        self.TipStage = 1
        return self:TipFullMove(p1, p2)
    end
end

local isThirdShot = false --test
function truelch_Mg43MachineGun:GetSkillEffect_Normal(p1, p2)
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
    ret:AddProjectile(p1, damage, self.Projectile, NO_DELAY)

    if not isThirdShot and isMission() then
        --Save direction:
        ret:AddScript(string.format("truelch_setShootStatus(%s, %s)", Pawn:GetId(), tostring(direction)))

        --[[
        if missionData().mg43ShootStatus[Pawn:GetId()] ~= nil then
            LOG("status -> "..tostring(missionData().mg43ShootStatus[Pawn:GetId()]))
        end
        ]]

        --Additional queued shot (OR add to mission data to shoot AFTER enemy turn)
        if missionData().mg43ShootStatus[Pawn:GetId()] == nil then
            missionData().mg43ShootStatus[Pawn:GetId()] = { 3, direction }
        end

        local shots = missionData().mg43ShootStatus[Pawn:GetId()][1]

        if shots >= 2 then
            local queuedDamage = nil
            if self.QueuedPush == 1 then
                queuedDamage = SpaceDamage(target, self.QueuedDamage, direction)
            else
                queuedDamage = SpaceDamage(target, self.QueuedDamage)
            end
            ret:AddQueuedProjectile(queuedDamage, self.Projectile)
        end
    end

    --Return
    return ret
end

function truelch_Mg43MachineGun:GetSkillEffect(p1, p2)
    --LOG("truelch_Mg43MachineGun:GetSkillEffect(p1, p2)")
    if not Board:IsTipImage() then
        return self:GetSkillEffect_Normal(p1, p2)
    else
        return self:GetSkillEffect_TipImage(p1, p2)
    end
end


--A high-caliber sniper rifle effective over long distances against light vehicle armor. This rifle must be aimed downscope.
--Sniper: minimum range, PULL, (or confuse if at a certain range), or TC (p2 == p3 => confuse, otherwise pull?)
truelch_Apw1AntiMaterielRifle = Skill:new{
    --Infos
    Name = "APW-1 Anti-Materiel Rifle",
    Class = "",
    Description = "Shoot a powerful projectile at long range that pulls."..
        "\nMinimum range: 2.",

    --Art
    Icon = "weapons/brute_sniper.png", --TMP
    Sound = "/general/combat/explode_small",
    LaunchSound = "/weapons/raining_volley",
    ImpactSound = "/impact/generic/explosion",
    ProjectileArt = "effects/shot_sniper",
    Explosion = "",

    --Gameplay
    Limited = 2,
    MinRange = 2,
    Damage = 2,

    --Tip image
    TipImage = {
        Unit   = Point(2, 4),
        Target = Point(2, 1),
        Enemy  = Point(2, 1),
    }
}

function truelch_Apw1AntiMaterielRifle:GetTargetArea(point)
    local ret = PointList()
    for dir = DIR_START, DIR_END do
        for i = self.MinRange, 7 do
            local curr = Point(point + DIR_VECTORS[dir] * i)
            if Board:IsValid(curr) then
                ret:push_back(curr)
            end
            
            if not Board:IsValid(curr) or Board:IsBlocked(curr, PATH_PROJECTILE) then
                break
            end
        end
    end
    return ret
end

function truelch_Apw1AntiMaterielRifle:GetSkillEffect(p1, p2)
    local ret = SkillEffect()
    local pullDir = GetDirection(p1 - p2)
    --LOG("pullDir: "..tostring(pullDir))
    local target = GetProjectileEnd(p1, p2)
    local damage = SpaceDamage(target, self.Damage, pullDir)
    ret:AddProjectile(damage, self.ProjectileArt)
    return ret
end


--Flam-40: ignite a tile and pull inward lateral tiles?
truelch_Flam40Flamethrower = Skill:new{
    --Infos
    Name = "FLAM-40 Flamethrower",
    Class = "",
    Description = "Ignite a target and pull inward an adjacent tile.\nRange: 2 - 4.",

    --Art
    Icon = "weapons/prime_flamethrower.png",
    --Sound = "/general/combat/explode_small",
    LaunchSound = "/weapons/artillery_volley",
    ImpactSound = "/impact/generic/explosion",
    UpShot = "effects/shotup_ignite_fireball.png",

    --Artillery Arc
    ArtilleryHeight = 0,

    --Gameplay
    TwoClick = true,
    --Limited = 2,
    MinRange = 2,
    MaxRange = 4,

    --Tip image
    TipImage = {
        Unit   = Point(2, 4),
        Enemy  = Point(3, 2),
        Target = Point(2, 2),
        Second_Click = Point(3, 2),
    }
}

function truelch_Flam40Flamethrower:GetTargetArea(point)
    local ret = PointList()
    for dir = DIR_START, DIR_END do
        for i = self.MinRange, self.MaxRange do
            local curr = Point(point + DIR_VECTORS[dir] * i)
            if Board:IsValid(curr) then
                ret:push_back(curr)
            else
                break
            end
        end
    end
    return ret
end

function truelch_Flam40Flamethrower:GetSkillEffect(p1, p2)
    local ret = SkillEffect()

    local damage = SpaceDamage(p2, 0)
    damage.sAnimation = "ExploArt2" --tmp?
    damage.iFire = 1
    ret:AddArtillery(damage, self.UpShot)

    return ret
end

function truelch_Flam40Flamethrower:GetSecondTargetArea(p1, p2)
    local ret = PointList()

    for dir = DIR_START, DIR_END do
        local curr = p2 + DIR_VECTORS[dir]
        if Board:IsValid(curr) then
            ret:push_back(curr)
        end
    end

    return ret
end

function truelch_Flam40Flamethrower:GetFinalEffect(p1, p2, p3)
    local ret = self:GetSkillEffect(p1, p2)
    local direction = GetDirection(p2 - p3)
    local damage = SpaceDamage(p3, 0)
    damage.iPush = direction
    damage.sAnimation = "airpush_"..direction
    ret:AddDamage(damage)
    return ret
end

--???: Channel a powerful attack for the next turn. Channeling still does a little effect (push + fire?)
--RS-422 Railgun or LAS-99 Quasar Cannon
truelch_Rs422Railgun = Skill:new{
    --Infos
    Name = "RS-422 Railgun",
    Class = "",
    Description = "Charges a powerful projectile that'll be released next turn.\nCharging the attack push back an adjacent tile.",

    --Art
    Icon = "weapons/brute_sniper.png",
    --Sound = "/general/combat/explode_small",
    LaunchSound = "/weapons/artillery_volley",
    ImpactSound = "/impact/generic/explosion",
    ProjectileArt = "effects/shot_sniper",

    --Gameplay
    Damage = 3,

    --Tip image
    TipIndex = 0,
    TipImage = {
        Unit   = Point(2, 3),
        Enemy  = Point(2, 1),
        Enemy2 = Point(3, 3),
        Target = Point(3, 3),
        Second_Origin = Point(2, 3),
        Second_Target = Point(2, 1),
    }
}

function truelch_Rs422Railgun:GetTargetArea_TipImage(point)
    --LOG("truelch_Rs422Railgun:GetTargetArea_TipImage(point)")
    local ret = PointList()
    for dir = DIR_START, DIR_END do
        for i = 1, 7 do
            local curr = Point(point + DIR_VECTORS[dir] * i)
            if Board:IsValid(curr) then
                ret:push_back(curr)
            end
        
            if not Board:IsValid(curr) or Board:IsBlocked(curr, PATH_PROJECTILE) then
                break
            end
        end
    end
    return ret
end

function truelch_Rs422Railgun:GetTargetArea_Normal(point)
    local ret = PointList()

    if isMission() and missionData().isCharged and  missionData().isCharged[Board:GetPawn(point):GetId()] then
        --Charged: projectile
        for dir = DIR_START, DIR_END do
            for i = 1, 7 do
                local curr = Point(point + DIR_VECTORS[dir] * i)
                if Board:IsValid(curr) then
                    ret:push_back(curr)
                end
            
                if not Board:IsValid(curr) or Board:IsBlocked(curr, PATH_PROJECTILE) then
                    break
                end
            end
        end
    else
        --Not charged: melee push back
        for dir = DIR_START, DIR_END do
            local curr = Point(point + DIR_VECTORS[dir])
            if Board:IsValid(curr) then
                ret:push_back(curr)
            end
        end
    end

    return ret
end


function truelch_Rs422Railgun:GetTargetArea(point)
    if not Board:IsTipImage() then
        return self:GetTargetArea_Normal(point)
    else
        return self:GetTargetArea_TipImage(point)
    end
end

function truelch_Rs422Railgun:GetSkillEffect_TipImage(p1, p2)
    --LOG("truelch_Rs422Railgun:GetSkillEffect_TipImage")

    local ret = SkillEffect()
    local dir = GetDirection(p2 - p1)

    if self.TipIndex == 0 then
        Board:AddAlert(p1, "Charging...")
        local damage = SpaceDamage(p2, 0)
        damage.iPush = dir
        damage.sAnimation = "airpush_"..dir
        ret:AddDamage(damage)

        self.TipIndex = 1
    else
        Board:AddAlert(p1, "Charged!")
        local target = GetProjectileEnd(p1, p2)
        local damage = SpaceDamage(target, self.Damage, dir)
        ret:AddProjectile(damage, self.ProjectileArt)

        self.TipIndex = 0
    end

    return ret
end

function truelch_Rs422Railgun:GetSkillEffect_Normal(p1, p2)
    --LOG("truelch_Rs422Railgun:GetSkillEffect_Normal")
    local ret = SkillEffect()
    local dir = GetDirection(p2 - p1)

    if isMission() and missionData().isCharged and missionData().isCharged[Board:GetPawn(p1):GetId()] then
        --Charged
        local target = GetProjectileEnd(p1, p2)
        local damage = SpaceDamage(target, self.Damage, dir)
        ret:AddProjectile(damage, self.ProjectileArt)
        ret:AddScript(string.format("truelch_setCharged(%s, false)", tostring(Pawn:GetId())))

    else
        --Not charged
        local damage = SpaceDamage(p2, 0)
        damage.iPush = dir
        damage.sAnimation = "airpush_"..dir
        ret:AddDamage(damage)
        ret:AddScript(string.format("truelch_setCharged(%s, true)", tostring(Pawn:GetId())))
    end

    return ret
end

function truelch_Rs422Railgun:GetSkillEffect(p1, p2)
    if not Board:IsTipImage() then
        return self:GetSkillEffect_Normal(p1, p2)
    else
        return self:GetSkillEffect_TipImage(p1, p2)
    end
end


----------------------------------------------- UTILITY FUNCTIONS -----------------------------------------------

local stratagemWeapons = {
    "truelch_Mg43MachineGun",
    "truelch_Apw1AntiMaterielRifle",
    "truelch_Flam40Flamethrower",
    "truelch_Rs422Railgun",
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

local function isMg43(weaponId)
    if type(weaponId) == 'table' then
        weaponId = weaponId.__Id
    end

    --Need to improve that if I do upgrade versions of the weapon!
    if weaponId == "truelch_mg43MachineGun" then
        return true
    end

    return false
end

local function destroyAllStratagemWeapons()
    LOG("destroyAllStratagemWeapons()")
    --Look through all Mechs. Remember, respawned Mechs aren't in 0 - 2 index range
    --Need to try this:
    --for _, p in pairs(extract_table(Board:GetPawns(TEAM_MECH))) do
    --Will it work for newly spawned pawns?
    local size = Board:GetSize()
    for j = 0, size.y do
        for i = 0, size.x do
            local pawn = Board:GetPawn(Point(i, j))
            if pawn ~= nil and pawn:IsMech() then
                local weapons = pawn:GetPoweredWeapons()
                for k = 1, 3 do
                    if isStratagemWeapon(weapons[k]) then
                        LOG("---------------> Is stratagem weapon!!! -> REMOVE")
                        pawn:RemoveWeapon(k)
                    end
                end
            end
        end
    end
end


----------------------------------------------- HOOKS -----------------------------------------------

local function HOOK_onNextTurnHook()
    if Game:GetTeamTurn() == TEAM_PLAYER then
        local size = Board:GetSize()
        for j = 0, size.y do
            for i = 0, size.x do
                local pawn = Board:GetPawn(Point(i, j))
                if pawn ~= nil and pawn:IsMech() and isMission() and missionData().mg43ShootStatus ~= nil and missionData().mg43ShootStatus[pawn:GetId()] ~= nil then
                    --{ shots, dir }
                    local shots = missionData().mg43ShootStatus[pawn:GetId()][1]
                    local dir = missionData().mg43ShootStatus[pawn:GetId()][2]
                    local weapons = pawn:GetPoweredWeapons()
                    for k = 1, 3 do
                        local weapon = weapons[k]
                        if isMg43(weapon) and shots >= 3 and dir ~= -1 then
                            --LOG("=========================== THIRD SHOT ===========================")
                            Board:AddAlert(pawn:GetSpace(), "Mg43's 3rd shot!")
                            missionData().mg43ShootStatus[pawn:GetId()] = { 0, -1 } --reset
                            isThirdShot = true
                            pawn:FireWeapon(pawn:GetSpace() + DIR_VECTORS[dir], k) --wait, it might launch again the 2nd and 3rd shots!
                            isThirdShot = false
                        end
                    end
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
    if weaponId == "Move" then
        --LOG("p1: "..p1:GetString().." -> p2: "..p2:GetString())
        local dist = p1:Manhattan(p2)
        local move = pawn:GetMoveSpeed()
        --LOG("move: "..tostring(move))
        --Board:AddAlert(p2, "Dist: "..tostring(dist).."/"..tostring(move))

        --Move cannot be a 0 distance
        if isMission() and missionData().mg43ShootStatus ~= nil then

            --Attempt to fix the nil value below --->
            if missionData().mg43ShootStatus[pawn:GetId()] == nil then --this seems to be the one I needed
                --LOG("[A] missionData().mg43ShootStatus[pawn:GetId()] == nil")
                missionData().mg43ShootStatus[pawn:GetId()] = { 3, -1 } --safe init again
            elseif missionData().mg43ShootStatus[pawn:GetId()][1] == nil then
                --LOG("[B] missionData().mg43ShootStatus[pawn:GetId()][1] == nil")
                missionData().mg43ShootStatus[pawn:GetId()] = { 3, -1 } --safe init again
            end
            -- <--- Attempt to fix the nil value below

            if dist <= math.floor(0.5 * move) then
                --LOG("less than half move!")
                missionData().mg43ShootStatus[pawn:GetId()][1] = 2
            else
                --LOG("more than half move!")
                missionData().mg43ShootStatus[pawn:GetId()][1] = 1 --attempt to index field '?' (a nil value)
            end
        end
    end

    if isMg43(weaponId) then
        local dir = GetDirection(p2 - p1)
        missionData().mg43ShootStatus[pawn:GetId()][2] = dir
    end
end

local HOOK_PawnUndoMove = function(mission, pawn, undonePosition)
    if not isMission() then return end

    if missionData().mg43ShootStatus[pawn:GetId()] == nil then
        missionData().mg43ShootStatus[pawn:GetId()] = { 3, -1 }
    else
        missionData().mg43ShootStatus[pawn:GetId()][1] = 3 --3: not moved, 2: half moved or less, 1: more than half move
    end    
end



--Maybe it makes more sense to do that at mission start rather than mission end?
local HOOK_onMissionStarted = function(mission)
    --LOG("HOOK_onMissionStarted")
    destroyAllStratagemWeapons()

    --Reset Mg43 shoot status
    local size = Board:GetSize()
    for j = 0, size.y do
        for i = 0, size.x do
            local pawn = Board:GetPawn(Point(i, j))
            if pawn ~= nil and pawn:IsMech() then
                missionData().mg43ShootStatus[pawn:GetId()] = { 3, -1 } --shots, dir (default: -1)
            end
        end
    end
end

local HOOK_onMissionTestStarted = function(mission)
    --LOG("HOOK_onMissionTestStarted")
    destroyAllStratagemWeapons()
end

--Maybe I need to keep this one
local HOOK_onMissionEnded = function(mission)
    --LOG("HOOK_onMissionEnded")
    destroyAllStratagemWeapons()
end

--This causes a null ref to Board!
--[[
local HOOK_onMissionTestEnded = function(mission)
    LOG("HOOK_onMissionTestEnded")
    destroyAllStratagemWeapons()
end
]]

----------------------------------------------- HOOKS / EVENTS SUBSCRIPTION -----------------------------------------------

local function EVENT_onModsLoaded()
    --M43
    modApi:addNextTurnHook(HOOK_onNextTurnHook)
    modapiext:addSkillEndHook(HOOK_onSkillEnd)
    modapiext:addPawnUndoMoveHook(HOOK_PawnUndoMove)

    --Destroy stratagem weapons
    modApi:addMissionStartHook(HOOK_onMissionStarted)
    modApi:addTestMechEnteredHook(HOOK_onMissionTestStarted)

    modApi:addMissionEndHook(HOOK_onMissionEnded)
    --modApi:addTestMechExitedHook(HOOK_onMissionTestEnded)
end

modApi.events.onModsLoaded:subscribe(EVENT_onModsLoaded)