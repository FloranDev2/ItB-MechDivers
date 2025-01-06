local mod = mod_loader.mods[modApi.currentMod]

local path = mod.scriptPath

local scriptPath = mod.scriptPath
local resourcePath = mod.resourcePath

local this = {}
local read
local readEnabled

--local test = Point(1, 2) + nil

--In reality, I'm just changing A.I. pilot portrait (to hell diver portrait)
function this:changeMenuBackground(truelchMod)
	--LOG("----------------------------------- Changing hangar background...")
	local rootPathOnDisc = truelchMod.resourcePath

	local function appendDir(path) 
		local dirs = mod_loader:enumerateDirectoriesIn(rootPathOnDisc..path) 
		local images = mod_loader:enumerateFilesIn(rootPathOnDisc..path) 

		LOG("appendDir("..path..")")
		for _, file in ipairs(images) do
			LOG("file: "..file)
			--LOG("rootPathOnDisc: "..rootPathOnDisc)
			modApi:appendAsset(
				path..file,
				rootPathOnDisc..path..file
			)
		end

		for _, dir in ipairs(dirs) do
			appendDir(path..dir.."/")
		end
	end

	--Old
	--appendDir("img/")
	appendDir("img/portraits/pilots/") --anyway, if I can only replace images, this is simpler

	--[[
	--This works
	local truelch_images = {
		"/portraits/pilots/Pilot_Artificial.png",
		"/portraits/pilots/Pilot_Artificial_2.png",
		"/portraits/pilots/Pilot_Artificial_blink.png",
	}

	--This doesn't
	local truelch_scripts = {
		"personalities/pilots.csv"
	}

	for _, file in ipairs(truelch_images) do
		local dst = "img"..file
		local src = resourcePath.."/img/"..file
		modApi:appendAsset(dst, src)
		--LOG("image -> src: "..tostring(src).." -> dst: "..tostring(dst))
	end

	for _, file in ipairs(truelch_scripts) do
		local dst = "scripts/"..file
		local src = scriptPath..file
		modApi:appendAsset(dst, src)
		--LOG("script -> src: "..tostring(src).." -> dst: "..tostring(dst))
	end
	]]
end

function this:init(truelchMod)
	--[[
	modApi:addGenerationOption(
		"DisplayCustomWotPMenu",
		titleTxt,
		tipTxt,
		{
			enabled = false
		}
	)
	]]

	--- PLAY CUSTOM BACKGROUND ---
	--[[
	if readEnabled and achvOk then
		this:changeMenuBackground(truelchMod)
	end
	]]

	this:changeMenuBackground(truelchMod)
end

function this:load(truelchMod, options)
	--LOG("modifiedHanager -> load")
end

return this