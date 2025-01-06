local mod = mod_loader.mods[modApi.currentMod]

local path = mod.scriptPath

local scriptPath = mod.scriptPath
local resourcePath = mod.resourcePath

local this = {}

local read
local readEnabled

--In reality, I'm just changing A.I. pilot portrait (to hell diver portrait)
function this:replaceAssets(truelchMod)
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
	--LOG("replaceFiles -> init")

	--- READ FILE ---
	--https://www.tutorialspoint.com/lua/lua_file_io.htm
	--opens a file in read
	file = io.open(truelchMod.scriptPath.."/truelchSave/mySave.lua" , "r+")

	--sets the default input file as test.lua
	io.input(file)

	--prints the first line of the file
	read = io.read()
	--LOG("----------------------------------- read: "..tostring(read))

	--closes the open file
	io.close(file)

	readEnabled = read == "true"

	--LOG("----------------------------------- readEnabled: "..tostring(readEnabled))

	--- MOD OPTION ---
	modApi:addGenerationOption(
		"option_replace_ai_with_rookie",
		"A.I. Unit reskin",
		"Replace the A.I. Unit with a nameless Hell Breacher rookie pilot.",
		{
			enabled = true
		}
	)

	if readEnabled then
		this:replaceAssets(truelchMod)
	end

end

function this:load(truelchMod, options)
	--LOG("replaceFiles -> load")
	--Oh crap, I need to (re)implement my custom save system... *sigh*

	--LOG("----------------------------------- [LOAD] replaceFiles.load(options: "..tostring(options)..")")

	local enabled = options["option_replace_ai_with_rookie"].enabled --nil value

	--- WRITE FILE ---
	--https://www.tutorialspoint.com/lua/lua_file_io.htm
	--open
	file = io.open(truelchMod.scriptPath.."/truelchSave/mySave.lua" , "w+")

	--LOG("----------------------------------- file: "..tostring(file))

	--sets the default output file as test.lua (I guess it's needed to write?)
	io.output(file)

	--write
	if enabled then
		--LOG("----------------------------------- write true")
		io.write("true")
	else
		--LOG("----------------------------------- write false")
		io.write("false")
	end

	--close
	io.close(file)
end

return this