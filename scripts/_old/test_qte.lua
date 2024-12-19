--[[
1073741906: UP ▲
1073741905: DOWN ▼
1073741904: LEFT ◄
1073741903: RIGHT ►
]]

local handler = function(scancode)
    LOGF("Key with scancode %s is being released and processed", scancode)
    LOG("-------- type: "..type(scancode))

    if scancode     == 1073741906 then --UP
        LOG(" -> Up!")
    elseif scancode == 1073741905 then --DOWN
        LOG(" -> Down!")
    elseif scancode == 1073741904 then --LEFT
        LOG(" -> Left!")
    elseif scancode == 1073741903 then --RIGHT
        LOG(" -> Right!")
    end
end

modApi.events.onKeyReleased:subscribe(handler)