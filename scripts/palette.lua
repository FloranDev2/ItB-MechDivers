--- MAIN YELLOW ---
modApi:addPalette({
		ID = "truelch_MechDiversYellow",
		Name = "Mech Divers' Yellow",
		Image = "img/units/player/emancipatorMech_ns.png", --Emancipator
		PlateHighlight = { 230, 230, 230 },	--lights
		PlateLight     = { 240, 240,  10 },	--main highlight
		PlateMid       = { 200, 150,   0 },	--main light
		PlateDark      = {  125, 75,   0 },	--main mid
		PlateOutline   = {  38,  31,   0 },	--main dark
		PlateShadow    = {  10,  10,  10 },	--metal dark
		BodyColor      = {  30,  30,  30 },	--metal mid
		BodyHighlight  = {  59,  59,  59 },	--metal light
})
modApi:getPaletteImageOffset("truelch_MechDiversYellow")

--- MAIN BLACK ---
modApi:addPalette({
		ID = "truelch_MechDiversBlack",
		Name = "Mech Divers' Black",
		Image = "img/units/player/patriotMech_ns.png", --Patriot / Eagle
		PlateHighlight = {  10,  10,  75 },	--lights
		PlateLight     = {  91,  92,  93 }, --main highlight
		PlateMid       = {  41,  42,  43 }, --main light
		PlateDark      = {  34,  34,  32 },	--main mid
		PlateOutline   = {  15,  15,  15 },	--main dark
		PlateShadow    = { 125,  75,  50 },	--metal dark
		BodyColor      = { 175, 100,  75 },	--metal mid
		BodyHighlight  = { 255, 208,  75 },	--metal light
})
modApi:getPaletteImageOffset("truelch_MechDiversBlack")