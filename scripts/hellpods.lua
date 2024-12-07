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

    return mission.truelch_MechDivers
end


----------------------------------------------- HOOKS -----------------------------------------------

local function HOOK_onNextTurnHook()
    if Game:GetTeamTurn() ~= TEAM_PLAYER then return end

    --LOG("Hell pods spawn loop: (count: "..tostring(#missionData().hellPods)..")")
    --Kill pawns, play anim and spawn items
    for _, hellPod in pairs(missionData().hellPods) do
        local effect = SkillEffect() --so I can have delays

        --Retrieve data
        local loc = hellPod[1]
        local item = hellPod[2]

        --LOG(" -> loc: "..loc:GetString()..", item: "..item)

        --Play anim
        --local dropAnim = SpaceDamage(loc, DAMAGE_DEATH)
        local dropAnim = SpaceDamage(loc, 0)

        --dropAnim.sAnimation = "" --TODO: Hell Pod drop animation
        effect:AddDamage(dropAnim)

        --Delay
        effect:AddDelay(0.5) --enough?

        --[[
        https://gist.github.com/Tarmean/bf415d920eecb4b2bbdd32de2ba75924
        /props/pylon_fall
        /props/pylon_impact
        /ui/battle/mech_drop
        ]]
        --TODO: play sound
        local sfx = SpaceDamage(loc, 0)
        sfx.sSound = "/ui/battle/mech_drop" --that should be it
        effect:AddDamage(sfx)

        --Dust
        for dir = DIR_START, DIR_END do
            local curr = loc + DIR_VECTORS[dir]
            local dust = SpaceDamage(curr, 0)
            dust.sAnimation = "airpush_"..dir --is it the one use for Mechs' deployment?
            effect:AddDamage(dust)
        end

        --Kill damage (regardless of what's under)
        local killSd = SpaceDamage(loc, DAMAGE_DEATH)
        effect:AddDamage(killSd)

        --Lil' delay (idk if it'd destroy the item otherwise)
        effect:AddDelay(0.1)

        --Add item
        local spawnItem = SpaceDamage(loc, 0)
        spawnItem.sItem = item
        effect:AddDamage(spawnItem)

        --Add effect to the board
        Board:AddEffect(effect)
    end

    --Clear
    missionData().hellPods = {}

end


----------------------------------------------- HOOKS / EVENTS SUBSCRIPTION -----------------------------------------------

local function EVENT_onModsLoaded()
    modApi:addNextTurnHook(HOOK_onNextTurnHook)
end

modApi.events.onModsLoaded:subscribe(EVENT_onModsLoaded)