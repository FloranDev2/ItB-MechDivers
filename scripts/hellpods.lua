----------------------------------------------- IMPORTS -----------------------------------------------

local mod = modApi:getCurrentMod()
local scriptPath = mod.scriptPath


----------------------------------------------- MISSION / GAME FUNCTIONS -----------------------------------------------

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

local function missionData(msg)
    local mission = GetCurrentMission()

    if mission == nil then
        LOG("hellpods.lua -> mission is nil -> msg: "..tostring(msg))
        return nil
    end

    if mission.truelch_MechDivers == nil then
        mission.truelch_MechDivers = {}
    end

    --Position, Item Name
    if mission.truelch_MechDivers.hellPods == nil then
        mission.truelch_MechDivers.hellPods = {}
    end

    if mission.truelch_MechDivers.items == nil then
        mission.truelch_MechDivers.items = {}
    end

    if mission.truelch_MechDivers.afterKill == nil then
        mission.truelch_MechDivers.afterKill = {}
    end

    return mission.truelch_MechDivers
end


----------------------------------------------- HOOKS -----------------------------------------------

local function computeDrops(list)
    --LOG("-------------- computeDrops (count: "..tostring(#list)..")")
    --Kill pawns, play anim and spawn items

    for _, hellPod in pairs(list) do

        local effect = SkillEffect() --so I can have delays

        --Retrieve data
        local loc  = hellPod[1]
        local item = hellPod[2]        

        --Play anim
        local dropAnim = SpaceDamage(loc, 0)
        dropAnim.sAnimation = "truelch_anim_pod_land"
        effect:AddDamage(dropAnim)

        --Delay
        effect:AddDelay(1.9)

        effect:AddScript("Board:StartShake(0.5)")
        
        local sfx = SpaceDamage(loc, 0)
        sfx.sSound = "/mech/land" --https://gist.github.com/Tarmean/bf415d920eecb4b2bbdd32de2ba75924
        effect:AddDamage(sfx)

        --Dust
        for dir = DIR_START, DIR_END do
            local curr = loc + DIR_VECTORS[dir]
            local dust = SpaceDamage(curr, 0)
            dust.sAnimation = "airpush_"..dir --is it the one use for Mechs' deployment?
            effect:AddDamage(dust)
        end

        --Kill damage (regardless of what's under)
        --NEW: nerfed to 1 damage
        local pawn = Board:GetPawn(loc)
        if pawn ~= nil then            
            --local killSd = SpaceDamage(loc, DAMAGE_DEATH) --old, but just to test item spawn again
            local killSd = SpaceDamage(loc, 1)
            effect:AddDamage(killSd)

            --Lil' delay (idk if it'd destroy the item otherwise)
            effect:AddDelay(0.5) --doesn't work to prevent item being recovered / destroyed
        else
            --No pawn: let's create the item now (otherwise, we wait to see if the pawn dies to create an item)
            --Add item
            local spawnItem = SpaceDamage(loc, 0)
            spawnItem.sItem = item
            effect:AddDamage(spawnItem)
        end

        --Add effect to the board
        Board:AddEffect(effect)
    end
end

local function HOOK_onNextTurnHook()
    if Game:GetTeamTurn() == TEAM_PLAYER then
        missionData("HOOK_onNextTurnHook - items reset").items = {}
        computeDrops(missionData("HOOK_onNextTurnHook - compute drops").hellPods)

        for _, data in pairs(missionData("HOOK_onNextTurnHook - for hell pods").hellPods) do
            table.insert(missionData("HOOK_onNextTurnHook - insert").items, data)
        end

        missionData("HOOK_onNextTurnHook").hellPods = {}    
    end
end

local HOOK_onTurnReset = function(mission)
    LOG("HOOK_onTurnReset")

    modApi:scheduleHook(550, function()
        if missionData("HOOK_onTurnReset - check") == nil then
            LOG("HOOK_onTurnReset -> mission data is nil!")
            return
        end
        computeDrops(missionData("HOOK_onTurnReset").items)
    end)
end

local truelch_delay = 0
local HOOK_onPawnKilled = function(mission, pawn)
    --LOG("HOOK_onPawnKilled -> "..pawn:GetMechName().." was killed. Loop: ("..tostring(#missionData().items)..")")

    for _, hellPod in pairs(missionData("HOOK_onPawnKilled - for").items) do --test
        local loc  = hellPod[1]
        local item = hellPod[2]

        --LOG(string.format("hellPod: loc: %s, item: %s", loc:GetString(), tostring(item)))

        if loc == pawn:GetSpace() then
            --LOG("pawn killed by drop!")
            if pawn:IsEnemy() then
                truelch_completeDropKill()
            end

            table.insert(missionData("HOOK_onPawnKilled - insert").afterKill, hellPod)
            truelch_delay = 500 --it... works?
        end
    end
end


local HOOK_onMissionUpdate = function(mission)
    if not isMission() then return end

    if truelch_delay > 0 then
        truelch_delay = truelch_delay - 1
        --LOG("truelch_delay: "..tostring(truelch_delay)..", is board busy: "..tostring(Board:IsBusy()))
    end 

    if #missionData("HOOK_onMissionUpdate - if afterkill > 0").afterKill > 0 and truelch_delay == 0 then
        local index = 1 --or maybe I could just treat one per frame, the first in the list
        for _, hellPod in pairs(missionData("HOOK_onMissionUpdate - for").afterKill) do

            local loc  = hellPod[1]
            local item = hellPod[2]

            local pawn = Board:GetPawn(loc)
            if pawn == nil then
                --LOG("[OK] Good: "..loc:GetString())

                if Board:IsValid(loc) and
                        not Board:IsBlocked(loc, PATH_PROJECTILE) and
                        not Board:IsPod(loc) and
                        not Board:IsTerrain(loc, TERRAIN_HOLE) and
                        not Board:IsTerrain(loc, TERRAIN_WATER) and
                        not Board:IsTerrain(loc, TERRAIN_LAVA) then
                    Board:SetItem(loc, item) --this still doesn't spawn an item. AAAAAAAH
                end


            else
                --LOG("[WAIT] Pawn found at: "..loc:GetString())
                --Corpse can f*ck our logic, maybe just remove the data
            end

            --in any case
            table.remove(missionData().afterKill, index)
            index = index - 1 --necessary, right?
        end
    end
end


----------------------------------------------- HOOKS / EVENTS SUBSCRIPTION -----------------------------------------------

local function EVENT_onModsLoaded()
    modApi:addNextTurnHook(HOOK_onNextTurnHook)
    modapiext:addResetTurnHook(HOOK_onTurnReset)
    modapiext:addPawnKilledHook(HOOK_onPawnKilled)
    modApi:addMissionUpdateHook(HOOK_onMissionUpdate)
end

modApi.events.onModsLoaded:subscribe(EVENT_onModsLoaded)