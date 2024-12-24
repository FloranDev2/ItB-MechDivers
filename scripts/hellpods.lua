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

local function missionData()
    local mission = GetCurrentMission()

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

    return mission.truelch_MechDivers
end


----------------------------------------------- HOOKS -----------------------------------------------

local function computeDrops(list)
    --LOG("computeDrops (count: "..tostring(#list)..")")
    --Kill pawns, play anim and spawn items

    --for _, hellPod in pairs(missionData().hellPods) do
    for _, hellPod in pairs(list) do

        local effect = SkillEffect() --so I can have delays

        --Retrieve data
        local loc = hellPod[1]
        local item = hellPod[2]        

        --LOG(" -> loc: "..loc:GetString()..", item: "..item)

        --Play anim
        local dropAnim = SpaceDamage(loc, 0)
        dropAnim.sAnimation = "truelch_anim_pod_land"
        effect:AddDamage(dropAnim)

        --Delay
        effect:AddDelay(2) --enough?

        effect:AddScript("Board:StartShake(0.5)")

        --[[
        https://gist.github.com/Tarmean/bf415d920eecb4b2bbdd32de2ba75924
        /props/pylon_fall
        /props/pylon_impact
        /ui/battle/mech_drop
        ]]
        --TODO: play sound
        local sfx = SpaceDamage(loc, 0)
        sfx.sSound = "/ui/battle/mech_drop" --that should be it. It doesn't seem to play a sound...
        effect:AddDamage(sfx)

        --Dust
        for dir = DIR_START, DIR_END do
            local curr = loc + DIR_VECTORS[dir]
            local dust = SpaceDamage(curr, 0)
            dust.sAnimation = "airpush_"..dir --is it the one use for Mechs' deployment?
            effect:AddDamage(dust)
        end

        --Kill damage (regardless of what's under)
        local pawn = Board:GetPawn(loc)
        if pawn ~= nil then            
            local killSd = SpaceDamage(loc, DAMAGE_DEATH)
            effect:AddDamage(killSd)

            if pawn:IsEnemy() then
                truelch_completeDropKill()
            end

            --Lil' delay (idk if it'd destroy the item otherwise)
            effect:AddDelay(0.5) --doesn't work to prevent item being recovered / destroyed
        end

        --Add item
        local spawnItem = SpaceDamage(loc, 0)
        spawnItem.sItem = item
        effect:AddDamage(spawnItem)

        --Add effect to the board
        Board:AddEffect(effect)
        --LOG("-------------- Here")
    end
end

local function HOOK_onNextTurnHook()
    if Game:GetTeamTurn() == TEAM_PLAYER then
        missionData().items = {}
        computeDrops(missionData().hellPods)

        for _, data in pairs(missionData().hellPods) do
            --LOG("--------- added data to items!")
            table.insert(missionData().items, data)
        end

        missionData().hellPods = {}
        --modApi:runLater(function()
        --[[
        --So the unit on the loc won't recover (or destroy) the item
        for _, hellPod in pairs(missionData().hellPods) do
            --Add item
            local spawnItem = SpaceDamage(loc, 0)
            spawnItem.sItem = item
            effect:AddDamage(spawnItem)

            --Add effect to the board
            Board:AddEffect(effect)
        end

        --Clear
        missionData().hellPods = {}
        ]]

        --LOG("-------- HERE (modApi:runLater)")
        --end)

    --elseif Game:GetTeamTurn() == TEAM_ENEMY then
        --LOG("---------------------- CLEAR")
        
    end
end

local HOOK_onTurnReset = function(mission)
    --LOG("HOOK_onTurnReset")
    --computeDrops()
    --computeDrops(missionData().items)

    --LOG("TEST SET ITEM")
    --Board:SetItem(Point(0, 0), "truelch_Item_WeaponPod_Mg43") --doesn't work

    modApi:runLater(function()
        --Board:SetItem(Point(0, 0), "truelch_Item_WeaponPod_Mg43") --WORKS!!!!
        computeDrops(missionData().items)
    end)
end


----------------------------------------------- HOOKS / EVENTS SUBSCRIPTION -----------------------------------------------

local function EVENT_onModsLoaded()
    modApi:addNextTurnHook(HOOK_onNextTurnHook)
    modapiext:addResetTurnHook(HOOK_onTurnReset)
end

modApi.events.onModsLoaded:subscribe(EVENT_onModsLoaded)