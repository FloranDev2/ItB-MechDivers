----------------------------------------------- IMPORTS -----------------------------------------------

local mod = modApi:getCurrentMod()
local scriptPath = mod.scriptPath


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


----------------------------------------------- HOOKS -----------------------------------------------

--TODO: check if a Mech is in the loc of one of the effects
local function protecc(pawn, skillEffect)
    if skillEffect == nil or skillEffect.effect == nil then
        return
    end

    local damageRedirected = 0

    for i = 1, skillEffect.effect:size() do
        local spaceDamage = skillEffect.effect:index(i);
        if spaceDamage.iDamage > 0 then
            damageRedirected = damageRedirected + spaceDamage.iDamage
            spaceDamage.iDamage = 0
        end
    end

    --[[
    if damageRedirected > 0 then
        local redir = spaceDamage(pawn:GetSpace(), damageRedirected)
        skillEffect:AddDamage(redir)
    end
    ]]
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