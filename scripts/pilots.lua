--[[
	The goal of this script is to replace the AI pilot with custom dialogs / personality (etc.) with an Mech Diver (expendable) pilot?
]]

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

--Add corp pilot: veteran Mech Diver