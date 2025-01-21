--[[
	The goal of this script is to replace the AI pilot with custom dialogs / personality (etc.) with an Mech Diver (expendable) pilot?
]]

--- "CORP" PILOT -> Veteran Mech Diver ---

local path = GetParentPath(...)
local pilot_dialog = require(path.."pilot_dialog")
local mod = modApi:getCurrentMod()
local resourcePath = mod.resourcePath

-- add pilot images
--[[
modApi:appendAsset("img/portraits/npcs/truelch_mechDiver.png",       resourcePath.."img/portraits/pilots/Pilot_Artificial.png")
modApi:appendAsset("img/portraits/npcs/truelch_mechDiver_2.png",     resourcePath.."img/portraits/pilots/Pilot_Artificial_2.png")
modApi:appendAsset("img/portraits/npcs/truelch_mechDiver_blink.png", resourcePath.."img/portraits/pilots/Pilot_Artificial_blink.png")
]]

modApi:appendAsset("img/portraits/npcs/truelch_hellbreacher.png",       resourcePath.."img/portraits/pilots/Pilot_HellBreacher.png")
modApi:appendAsset("img/portraits/npcs/truelch_hellbreacher_2.png",     resourcePath.."img/portraits/pilots/Pilot_HellBreacher_2.png")
modApi:appendAsset("img/portraits/npcs/truelch_hellbreacher_blink.png", resourcePath.."img/portraits/pilots/Pilot_HellBreacher_blink.png")

-- create personality
local personality = CreatePilotPersonality("MechDiver")
personality:AddDialogTable(pilot_dialog)

-- add our personality to the global personality table
Personality["MechDiver"] = personality

-- create pilot
-- reference the personality we created
-- reference the pilot images we added
CreatePilot{
	Id = "Pilot_MechDiver",
	Personality = "MechDiver",
	Rarity = 0,
	Cost = 1,
	Portrait = "npcs/truelch_hellbreacher",
	--Name = "Test", --V3
	Voice = "/voice/detritus",
}

modApi:addPilotDrop{id = "Pilot_MechDiver", recruit = true }


--- "A.I. pilot" replacement -> Newbie Mech Diver ---

--Stupid test
--_G["Pilot_Artificial"].Name = "Some Cool Name" --doesn't work


--[[
_G["truelch_mech_diver"] = {} --V2
_G["truelch_mech_diver"].Name = "Some Cool Name" --V2
]]

--Mech Diver
CreatePilot{
	Id = "Pilot_Artificial",
	Personality = "MechDiver",
	Rarity = 0,
	Sex = SEX_MALE,
	--Maybe I can add my own name id in a separate .csv or by script
	--Into the Breach/scripts/personalities/pilots.csv

	--Name = "Mech Diver", --Doesn't work
	--Name = "Pilot_Artificial_Name", --V1 (doesn't work)
	--Name = "truelch_mech_diver", --V2
	--Name = "Pilot_MechDiver", --V3

	Voice = "/voice/archive",
}


local function HOOK_PreMissionAvailable(mission)
	--_G["Pilot_Artificial"].Name = "Some Cool Name" --V1 (doesn't work)

	--_G["truelch_mech_diver"] = {} --V2 (doesn't work)
	--_G["truelch_mech_diver"].Name = "Some Cool Name" --V2 (doesn't work)

	--_G["Pilot_Artificial"].Name = "Pilot_MechDiver" --V3 (doesn't work)
end

local function EVENT_onModsLoaded()
	modApi:addPreMissionAvailableHook(HOOK_PreMissionAvailable)
	--Metalo's suggestion:
	--modApi.modLoaderDictionary["Pilot_Artificial"].Name = "Test1"
	--modApi.modLoaderDictionary["Pilot_Artificial_Name"] = "Test2"	
end

modApi.events.onModsLoaded:subscribe(EVENT_onModsLoaded)
