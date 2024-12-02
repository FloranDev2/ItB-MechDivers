----------------------------------------------- IMPORTS -----------------------------------------------

local mod = modApi:getCurrentMod()
local scriptPath = mod.scriptPath

--[[
function SpaceDamage:ListFields()
    return {
        "bEvacuate",
        "bHide",
        "bHideIcon",
        "bHidePath",
        "bKO_Effect",
        "bSimpleMark",
        "fDelay",
        "iAcid",
        "iCrack",
        "iDamage",
        "iFire",
        "iFrozen",
        "iInjure",
        "iPawnTeam",
        "iPush",
        "iShield",
        "iSmoke",
        "iTerrain",
        "loc",
        "sAnimation",
        "sImageMark",
        "sItem",
        "sPawn",
        "sScript",
        "sSound"
    }
end
]]


----------------------------------------------- MISSION / GAME FUNCTIONS -----------------------------------------------

--[[
local function isGame()
    return true
        and Game ~= nil
        and GAME ~= nil
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

    if mission.truelch_MechDivers.DeadMechs == nil then
        mission.truelch_MechDivers.DeadMechs = {}
    end

    return mission.truelch_MechDivers
end
]]

----------------------------------------------- CUSTOM FUNCTIONS -----------------------------------------------

--Should the Eagle Mech be a protecc pawn too or just the Emancipator and the Patriot Mechs?
local proteccPawns = { "EagleMech", "EmancipatorMech", "PatriotMech" }

local function isProteccPawn(pawn)
    if pawn == nil then return false end

    for _, proteccPawn in pairs(proteccPawns) do
        if pawn:GetType() == proteccPawn then
            return true
        end
    end

    return false
end


----------------------------------------------- HOOKS -----------------------------------------------

--TODO: check if a Mech is in the loc of one of the effects
local function protecc(pawn, skillEffect)
    if skillEffect == nil or skillEffect.effect == nil then
        return
    end

    local damageRedirected = 0

    for i = 1, skillEffect.effect:size() do
        local spaceDamage = skillEffect.effect:index(i);
        --LOG("spaceDamage.loc: "..spaceDamage.loc:GetString())
        if spaceDamage.iDamage > 0 and Board:IsBuilding(spaceDamage.loc) then
            local proteccPawn = nil

            for dir = DIR_START, DIR_END do
                local curr = spaceDamage.loc + DIR_VECTORS[dir]
                local pawn = Board:GetPawn(curr)
                if Board:IsValid(curr) and pawn ~= nil and isProteccPawn(pawn) then
                    proteccPawn = pawn
                end
            end

            if proteccPawn ~= nil then
                damageRedirected = damageRedirected + spaceDamage.iDamage
                spaceDamage.iDamage = 0

                if damageRedirected > 0 then
                    local redir = SpaceDamage(proteccPawn:GetSpace(), damageRedirected)
                    redir.sImageMark = "combat/icons/icon_protecc.png"
                    skillEffect:AddScript([[Board:AddAlert(]]..proteccPawn:GetSpace():GetString()..[[, "Patriotism")]])
                    skillEffect:AddDamage(redir)
                end

            end
        end
    end
end


local HOOK_onSkillBuild = function(mission, pawn, weaponId, p1, p2, skillEffect)
    protecc(pawn, skillEffect)
end

local HOOK_onFinalEffectBuildHook = function(mission, pawn, weaponId, p1, p2, p3, skillEffect)
    protecc(pawn, skillEffect)
end


----------------------------------------------- HOOKS / EVENTS SUBSCRIPTION -----------------------------------------------

local function EVENT_onModsLoaded()
    modapiext:addSkillBuildHook(HOOK_onSkillBuild)
    modapiext:addFinalEffectBuildHook(HOOK_onFinalEffectBuildHook)
end

modApi.events.onModsLoaded:subscribe(EVENT_onModsLoaded)