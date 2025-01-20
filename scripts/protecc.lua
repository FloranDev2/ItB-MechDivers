----------------------------------------------- IMPORTS -----------------------------------------------

local mod = modApi:getCurrentMod()
local scriptPath = mod.scriptPath


----------------------------------------------- MISSION / GAME -----------------------------------------------

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

    --[1] proteccPawn, [2] redirectedDamage
    if mission.truelch_MechDivers.proteccData == nil then
        mission.truelch_MechDivers.proteccData = {}
    end

    if mission.truelch_MechDivers.proteccLastWeaponId == nil then
        mission.truelch_MechDivers.proteccLastWeaponId = {}
    end

    return mission.truelch_MechDivers
end


----------------------------------------------- CUSTOM FUNCTIONS -----------------------------------------------

--Should the Eagle Mech be a protecc pawn too or just the Emancipator and the Patriot Mechs?
local proteccPawns = { "truelch_EagleMech", "truelch_EmancipatorMech", "truelch_PatriotMech" }

local function isProteccPawn(pawn)
    if pawn == nil then return false end

    for _, proteccPawn in pairs(proteccPawns) do
        if pawn:GetType() == proteccPawn then
            return true
        end
    end

    return false
end

--TODO: check if a Mech is in the loc of one of the effects
--It seems that Train_Move is called everytime you do something and hijack my logic...
--I wonder if there are other neutral stuff that do the same shit.
--OR VEK QUEUED ATTACKS???
--Anyway, I'm just gonna check if the pawn using the weapon is a protecc pawn
----> wait no, a deployable could use a weapon and a protecc pawn needs to defend against it...
--GAAAH
local function protecc(pawn, skillEffect, weaponId)
    if skillEffect == nil or skillEffect.effect == nil then
        return
    end

    if weaponId == nil or weaponId == "" then
        return
    end

    if type(weaponId) == 'table' then
        weaponId = weaponId.__Id
    end

    --thankfully this should cover all cases it didn't worked
    if not skillEffect.q_effect:empty() then
        --LOG("HERE!!! queued effect detected --> weaponId: "..weaponId)
        return
    end

    --LOG(string.format("--------- protecc -> weaponId: %s", weaponId))

    missionData().proteccLastWeaponId = weaponId
    missionData().proteccData = {} --clear

    for i = 1, skillEffect.effect:size() do
        local damageRedirected = 0
        local spaceDamage = skillEffect.effect:index(i)
        
        if spaceDamage.iDamage > 0 and Board:IsBuilding(spaceDamage.loc) then
            --LOG(string.format("sd -> loc: %s, damage: %s", spaceDamage.loc:GetString(), tostring(spaceDamage.iDamage)))
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
                spaceDamage.sImageMark = "combat/icons/icon_guard_glow.png" --moved the icon to the protected building

                if damageRedirected > 0 then
                    --Old stuff
                    --local redir = SpaceDamage(proteccPawn:GetSpace(), damageRedirected)
                    --skillEffect:AddScript([[Board:AddAlert(]]..proteccPawn:GetSpace():GetString()..[[, "Patriotism")]])
                    --skillEffect:AddDamage(redir)                    

                    --Save data to mission data
                    --[1] proteccPawn
                    table.insert(missionData().proteccData, { proteccPawn, damageRedirected })

                    --Do some fake damage preview and apply damage only in applyProtecc (because Mech using weapon that moves them will prevent them to received damage)
                    local dmgVal = damageRedirected
                    if dmgVal < 0 then dmgVal = 0 end --wait wait wait, I need to also check REPAIR damage, no??
                    if dmgVal > 15 then dmgVal = 15 end

                    local imageName = "combat/icons/icon_protecc_"

                    if proteccPawn:IsAcid() then
                        dmgVal = dmgVal * 2
                        imageName = imageName.."acid_"
                    end

                    imageName = imageName..tostring(dmgVal)..".png"

                    --LOG("imageName: "..imageName)

                    local fakeRedirDmg = SpaceDamage(proteccPawn:GetSpace(), 0)
                    --LOG("proteccPawn: "..proteccPawn:GetMechName()..", pos: "..proteccPawn:GetSpace():GetString())
                    fakeRedirDmg.sImageMark = imageName

                    skillEffect:AddDamage(fakeRedirDmg) --will it break the loop if we add space damage to the skill effect?
                end

            end
        end
    end
end

local function applyProtecc(weaponId)
    if type(weaponId) == 'table' then weaponId = weaponId.__Id end

    --[[
    if missionData().proteccLastWeaponId ~= nil then
        LOG(string.format("--------- applyProtecc -> weaponId: %s, proteccLastWeaponId: %s", weaponId, missionData().proteccLastWeaponId))
    else
        LOG("--------- applyProtecc -> nil stuff")
    end
    ]]

    if missionData().proteccLastWeaponId == weaponId then
        local effect = SkillEffect()

        for _, data in pairs(missionData().proteccData) do
            --Extract data (reminder: indexes start at 1 and not 0 *sigh*)
            pwn = data[1]
            dmg = data[2]

            --Apply damage
            local redir = SpaceDamage(pwn:GetSpace(), dmg)
            effect:AddScript([[Board:AddAlert(]]..pwn:GetSpace():GetString()..[[, "Patriotism")]])
            effect:AddScript(string.format("Board:AddAlert(%s, Patriotism", pwn:GetSpace():GetString()))
            effect:AddDamage(redir)
        end

        Board:AddEffect(effect)
    end

    --Clear protecc data in any case
    missionData().proteccData = {}
end


----------------------------------------------- HOOKS -----------------------------------------------

--Save stuff for protecc and wait HOOK_onSkillEnd to apply them?
local HOOK_onSkillBuild = function(mission, pawn, weaponId, p1, p2, skillEffect)
    if not isGame() or not isMission() then return end
    protecc(pawn, skillEffect, weaponId)
end

local HOOK_onFinalEffectBuild = function(mission, pawn, weaponId, p1, p2, p3, skillEffect)
    if not isGame() or not isMission() then return end
    protecc(pawn, skillEffect, weaponId)
end

--Apply stuff now?
local HOOK_onSkillEnd = function(mission, pawn, weaponId, p1, p2)
    if not isGame() or not isMission() then return end
    applyProtecc(weaponId)
end

local HOOK_onFinalEffectEnd = function(mission, pawn, weaponId, p1, p2, p3)
    if not isGame() or not isMission() then return end
    applyProtecc(weaponId)
end


----------------------------------------------- HOOKS / EVENTS SUBSCRIPTION -----------------------------------------------

local function EVENT_onModsLoaded()
    modapiext:addSkillBuildHook(HOOK_onSkillBuild)
    modapiext:addFinalEffectBuildHook(HOOK_onFinalEffectBuild)

    modapiext:addSkillEndHook(HOOK_onSkillEnd)
    modapiext:addFinalEffectEndHook(HOOK_onFinalEffectEnd)
end

modApi.events.onModsLoaded:subscribe(EVENT_onModsLoaded)