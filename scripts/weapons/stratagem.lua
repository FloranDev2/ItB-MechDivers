----------------------------------------------- IMPORTS -----------------------------------------------

local mod = mod_loader.mods[modApi.currentMod]
local scriptPath = mod.scriptPath
weaponArmed = require(scriptPath.."libs/weaponArmed")

----------------------------------------------- CUSTOM FUNCTIONS -----------------------------------------------

local function isStratagemWeapon(weapon)
    if type(weapon) == 'table' then
        weapon = weapon.__Id
    end
    return string.find(weapon, "truelch_Stratagem") ~= nil
end


----------------------------------------------- STRATAGEMS CODES -----------------------------------------------

--[[
Let's use the same convention as ItB for directions:
1073741906: 0 UP ▲ ⬆️ ⇧
1073741903: 1 RIGHT ► ⮕ ⇨
1073741905: 2 DOWN ▼ ⬇️ ⇩
1073741904: 3 LEFT ◄ ⬅️ ⇦
]]

stratagems = {}

--[1]: code, [2]: weapon, [3]: isFreeAction?

--Support Weapons (is free action!)
table.insert(stratagems, { "03201", "truelch_mg43MachineGun",        false }) -- ▼ ◄ ▼ ▲ ► MG-43 Machine Gun: if immobile: more damage?
table.insert(stratagems, { "03102", "truelch_apw1AntiMaterialRifle", false }) -- ▼ ◄ ► ▲ ▼ APW-1 Anti-Material Rifle: can't shoot melee and range 2
table.insert(stratagems, { "03", "truelch_apw1AntiMaterialRifle",    false }) -- ▼ ◄ M-105 Stalwart

--Orbital Strikes
table.insert(stratagems, { "12300",  "truelch_orbitalGatlingBarrage", true }) -- ► ▼ ◄ ▲ ▲   Orbital Gatling Barrage
table.insert(stratagems, { "111",    "truelch_orbitalAirbustStrike",  true }) -- ► ► ►       Orbital Airbust Strike
table.insert(stratagems, { "112312", "truelch_orbital120mmHEBarrage", true }) -- ► ► ▼ ◄ ► ▼ Orbital 120mm HE Barrage

--Test
--[[
LOG("\n\n\n------------- stratagems (length: "..tostring(#stratagems)..")")
for i, j in ipairs(stratagems) do
    --LOG(" ---> i: "..tostring(i))
    --LOG(" ---> j: "..tostring(j))

    LOG(" ---> i: "..tostring(i))
    LOG(" ---> j[1]: "..tostring(j[1]))
    LOG(" ---> j[2]: "..tostring(j[2]))
end
]]
--Result:
---> i: 1
---> j[1]: 03211
---> j[2]: MG-43 Machine Gun
---> i: 2
---> j[1]: 12300
---> j[2]: Orbital Gatling Barrage

local function isStratagemCode(code)
    for i, j in ipairs(stratagems) do
        --LOG("")
        if j[1] == code then
            LOG("Found corresponding stratagem!")
            return j --[1] -> code [2] -> weapon's name
        end
    end
end


----------------------------------------------- QTE (KEY HANDLER) -----------------------------------------------

--[[
Let's use the same convention as ItB for directions:
1073741906: 0 UP ▲
1073741903: 1 RIGHT ►
1073741905: 2 DOWN ▼
1073741904: 3 LEFT ◄
]]

local isStratagemArmed = false
local currentString = ""
local maxSize = 5

local HANDLER_onKeyReleased = function(scancode) --scancode is an int, not a string
    --LOGF("-------- Key with scancode %s is being released and processed", scancode)
    --LOG("-------- type: "..type(scancode))

    if isStratagemArmed then
        if scancode     == 1073741906 then --UP
            currentString = currentString + "0"
        elseif scancode == 1073741905 then --DOWN
            currentString = currentString + "2"
        elseif scancode == 1073741904 then --LEFT
            currentString = currentString + "3"
        elseif scancode == 1073741903 then --RIGHT
            currentString = currentString + "1"
        end

        LOG("currentString: "..currentString)

        if #currentString > maxSize then
            LOG("Failed QTE!")
        --elseif
        end
    end


end

modApi.events.onKeyReleased:subscribe(HANDLER_onKeyReleased)


----------------------------------------------- WEAPON ARMED -----------------------------------------------

weaponArmed.events.onWeaponArmed:subscribe(function(skill, pawnId)
    local pawn = Game:GetPawn(pawnId)

    --[[
    LOGF("Pawn %s armed weapon %s",
        tostring(pawn:GetMechName()),
        tostring(skill.__Id)
    )
    ]]

    if isStratagemWeapon(skill) then
        LOG(" ---> is stratagem!")
        isStratagemArmed = true
    end
end)

weaponArmed.events.onWeaponUnarmed:subscribe(function(skill, pawnId)
    -- A weapon can be unarmed from exiting to main menu,
    -- so pawn might not exist.
    local pawn = Game and Game:GetPawn(pawnId) or nil

    --[[
    LOGF("Pawn %s unarmed weapon %s",
        tostring(pawn and pawn:GetMechName() or nil),
        tostring(skill.__Id)
    )
    ]]

    isStratagemArmed = false
end)


----------------------------------------------- WEAPON -----------------------------------------------
local function getStratagemDescription()
    return "Will this work?!"
end

--[[
Free action?
New stratagem foreach game?
Upgrades unlock new stratagem categories? Increase chances to have a good stratagem?
1073741906: 0 UP    ▲ ⬆️  ⇧
1073741903: 1 RIGHT ► ⮕ ⇨
1073741905: 2 DOWN  ▼ ⬇️  ⇩
1073741904: 3 LEFT  ◄ ⬅️ ⇦
]]
truelch_Stratagem = Skill:new{
    --Infos
    Name = "Stratagem",
    --Description = "Request a supply pod for next turn to an empty tile. Any unit under the drop zone will die.",
    Description = getStratagemDescription(), --it works! I can dynamically change the weapon's description during the game!
    Class = "", --"Any"
    Icon = "weapons/truelch_stratagem.png", --tmp

    --Shop
    Rarity = 1,
    PowerCost = 0,

    --Upgrades
    --Upgrades = 2,
    --UpgradeCost = { 1, 2 },

    --Gameplay
    Range = 2,

    --Tip image
    --I think I'll need just a custom logic to display the possibilities
    --CustomTipImage = "Support_Repair_Tooltip",
    TipImage = {
        Unit   = Point(2, 2),
        --Enemy  = Point(2, 1),
        Target = Point(2, 1),
        CustomPawn = "truelch_PatriotMech",

        --Second_Origin = Point(2, 2),
        --Second_Target = Point(3, 2),
        Enemy3 = Point(3, 3),
    }
}


----------------------------------------------- TIP IMAGE -----------------------------------------------

function truelch_Stratagem:GetTargetArea_TipImage(point)
    local ret = PointList()

    for j = 0, 7 do
        for i = 0, 7 do
            local curr = Point(i, j)
            ret:push_back(curr)
        end
    end

    return ret
end

function truelch_Stratagem:GetTargetArea_Normal(point)
    local ret = PointList()

    --Diamond shaped area
    --Bruh, I don't like it, I'll just do a square shape area
    --[[
    local size = self.Range
    local center = point
    local corner = center - Point(size, size)
    local p = Point(corner)
    for i = 0, ((size*2+1)*(size*2+1)) do
        local diff = center - p
        local dist = math.abs(diff.x) + math.abs(diff.y)
        if Board:IsValid(p) and dist <= size then
            ret:push_back(p)
        end
        p = p + VEC_RIGHT
        if math.abs(p.x - corner.x) == (size*2+1) then
            p.x = p.x - (size*2+1)
            p = p + VEC_DOWN
        end
    end
    ]]

    for j = -self.Range, self.Range do
        for i = -self.Range, self.Range do
            local curr = point + Point(i, j)
            local isItem = Board:GetItem(curr) == nil
            if curr ~= point and Board:IsValid(curr) and not Board:IsBlocked(curr, PATH_PROJECTILE) and
                not Board:IsPod(curr) and isItem == false then
                ret:push_back(curr)
            end
        end
    end
    
    return ret
end

--Range 3 around mech instead?
function truelch_Stratagem:GetTargetArea(point)
    if not Board:IsTipImage() then
        return self:GetTargetArea_Normal(point)
    else
        return self:GetTargetArea_TipImage(point)
    end
end


----------------------------------------------- GET SKILL EFFECT -----------------------------------------------

customTipImageIndex = 0
customTipImageIndexMax = 1

--Drop Weapon
function truelch_Stratagem:GSE_TI0()
    local ret = SkillEffect()


    customTipImageIndex = 1
    return ret
end

function truelch_Stratagem:GSE_TI1()
    local ret = SkillEffect()


    customTipImageIndex = 0 --tmp
    return ret
end


function truelch_Stratagem:GetSkillEffect_TipImage(p1, p2)
    if customTipImageIndex == 0 then
        return self:GSE_TI0()
    elseif customTipImageIndex == 1 then
        return self:GSE_TI1()
    --else customTipImageIndex = 0 end --safety
    else
        return self:GSE_TI0()
    end
end

function truelch_Stratagem:GetSkillEffect_Normal(p1, p2)
    local ret = SkillEffect()

    local damage = SpaceDamage(p2, 0)

    ret:AddArtillery(damage, "effects/shotup_tribomb_missile.png")


    --ret:AddScript([[
    --]])

    return ret
end

function truelch_Stratagem:GetSkillEffect(p1, p2)
    if not Board:IsTipImage() then
        return self:GetSkillEffect_Normal(p1, p2)
    else
        return self:GetSkillEffect_TipImage(p1, p2)
    end
end

----------------------------------------------- HOOKS -----------------------------------------------

--[[
When a new mission starts, acquire a new stratagem!
I'm considering
]]