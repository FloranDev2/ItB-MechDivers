local mod = mod_loader.mods[modApi.currentMod]
local path = mod.scriptPath
local this = {}
local read
local readEnabled

--In reality, I'm just changing A.I. pilot portrait (to hell diver portrait)
function this:changeMenuBackground(truelchMod)
	--LOG("----------------------------------- Changing hangar background...")
	local rootPathOnDisc = truelchMod.resourcePath

	local function appendDir(path) 
		local dirs = mod_loader:enumerateDirectoriesIn(rootPathOnDisc..path) 
		local images = mod_loader:enumerateFilesIn(rootPathOnDisc..path) 

		for _, file in ipairs(images) do
			modApi:appendAsset( 
				path..file, 
				rootPathOnDisc..path..file 
			) 
		end 

		for _, dir in ipairs(dirs) do
			appendDir(path..dir.."/") 
		end 
	end 

	appendDir("img/")
end

function this:init(truelchMod)
	LOG("modifiedHanager -> init")
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