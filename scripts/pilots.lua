--[[
	The goal of this script is to replace the AI pilot with custom dialogs / personality (etc.) with an Mech Diver (expendable) pilot?
]]

--- "CORP" PILOT -> Veteran Mech Diver ---

local path = GetParentPath(...)
local pilot_dialog = require(path.."pilot_dialog")
local mod = modApi:getCurrentMod()
local resourcePath = mod.resourcePath

-- add pilot images
--Example from tosx:
--[[
modApi:appendAsset("img/portraits/npcs/tosx_rocks1.png", resourcePath.."img/corp/pilot.png")
modApi:appendAsset("img/portraits/npcs/tosx_rocks1_2.png", resourcePath.."img/corp/pilot_2.png")
modApi:appendAsset("img/portraits/npcs/tosx_rocks1_blink.png", resourcePath.."img/corp/pilot_blink.png")
]]
--Temporary stuff:
modApi:appendAsset("img/portraits/npcs/truelch_mechDiver.png",       resourcePath.."img/portraits/pilots/Pilot_Artificial.png")
modApi:appendAsset("img/portraits/npcs/truelch_mechDiver_2.png",     resourcePath.."img/portraits/pilots/Pilot_Artificial_2.png")
modApi:appendAsset("img/portraits/npcs/truelch_mechDiver_blink.png", resourcePath.."img/portraits/pilots/Pilot_Artificial_blink.png")

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
	Portrait = "npcs/truelch_mechDiver",
	Voice = "/voice/detritus",
}

modApi:addPilotDrop{id = "Pilot_MechDiver", recruit = true }


--- "A.I. pilot" replacement -> Newbie Mech Diver ---

--Original
--[[
CreatePilot{
	Id = "Pilot_Artificial",
	Personality = "Artificial",
	Rarity = 0,
	Name = "Pilot_Artificial_Name",
	Voice = "/voice/ai",
}
]]

--Mech Diver
CreatePilot{
	Id = "Pilot_Artificial",
	Personality = "Detritus",
	Rarity = 0,
	Sex = SEX_MALE,
	--Maybe I can add my own name id in a separate .csv or by script
	--Name = "Mech Diver", --Doesn't work
	Name = "Pilot_Artificial_Name", --Into the Breach/scripts/personalities/pilots.csv

	Voice = "/voice/archive",
}