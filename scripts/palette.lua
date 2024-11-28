
--- MAIN YELLOW ---
--[[
modApi:addPalette({
		ID = "truelch_MechDivers",
		Name = "Mech Divers' Black",
		--Image = "img/units/player/gunship_ns.png",
		PlateHighlight = { 230, 230, 230 },	--lights
		PlateLight     = { 240, 240,  10 },	--main highlight
		PlateMid       = { 200, 150,   0 },	--main light
		PlateDark      = {  125, 75,   0 },	--main mid
		PlateOutline   = {  38,  31,   0 },	--main dark
		PlateShadow    = {  10,  10,  10 },	--metal dark
		BodyColor      = {  30,  30,  30 },	--metal mid
		BodyHighlight  = {  59,  59,  59 },	--metal light
})
]]

--- MAIN BLACK (TODO and TEST) ---
modApi:addPalette({
		ID = "truelch_MechDivers",
		Name = "Mech Divers' Black",
		--Image = "img/units/player/gunship_ns.png",
		PlateHighlight = {   5,  15,  75 },	--lights
		PlateLight     = { 150, 150, 150 }, --main highlight
		PlateMid       = {  75,  75,  75 }, --main light
		PlateDark      = {  30,  30,  30 },	--main mid
		PlateOutline   = {  10,  10,  10 },	--main dark
		PlateShadow    = {  125, 75,   0 },	--metal dark
		BodyColor      = { 200, 150,   0 },	--metal mid
		BodyHighlight  = { 240, 240,  10 },	--metal light
})
modApi:getPaletteImageOffset("truelch_MechDivers")