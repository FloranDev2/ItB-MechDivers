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
modApi:getPaletteImageOffset("truelch_MechDivers")