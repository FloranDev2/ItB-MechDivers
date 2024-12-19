--[[
#squad
#corp

#ceo_full
#ceo_first
#ceo_second

#self_mech
#self_full
#self_first
#self_second

#main_mech
#main_full
#main_first
#main_second
]]

--[[
How'd you like this taste of Freedom?
Requesting Air Support.
You've served Democracy well, extraction awaits. (awaiting for extraction)
Democracy prevails once more. (extraction)
You've done your duty. You may extract with honor.
Injury? What injury?
Hold Position!
Hellbomb armed, clear the area! (for renfield bomb?)
You have maintained our way of life
Here come the cavalry!

You will never destroy our way of life!
Today you've carved another foothold in the long climb to Liberty.
Defend Democracy at any cost.


For prosperity!
Freedom forever.
Liberty save me! (-> critical health)
]]


return {
    -- Game States
    Gamestart = {
		"Greetings fellow Super Citizens. Time to deliver some Democracy!",
		"We won't let them take our Freedom.",
		"DEMOCRACY TIME!",
	},
    FTL_Found = {
		"We should present this to the Ministry of Truth and of Science.",
	},
    FTL_Start = {
		"I hope this... thing share our values.",
	},
    Gamestart_PostVictory = {
		"DEMOCRACY!",
		"#self_second, reporting. Super Earth always triomphed and always will!",
	},
    Death_Revived = {
		"Sweet democracy! My leg... is healed?",
		"I'm not short of freedom.",
	},
    Death_Main = {
		"#self_second, proud to have served under your democratic command!",
		"My #self_mech is falling apart, but not my faith in Democra...",
		"FOR SUPER EEEAAARRG",
	},
    Death_Response = {
		"#main_second died! Another hero falling to these undemocratic abominations.",
		"We'll have to continue on without #main_second!",
	},
    Death_Response_AI = {
		"This rookie died a hero!",
	},
    TimeTravel_Win = {
		"Democracy prevails.",
		"I'll deliver Democracy in every timelines!",
	},
    Gameover_Start = {
		"We tried. We failed.",
		"Our best. It wasn't enough.",
	},
    Gameover_Response = {
		"Jumping to a new timeline. I'm sure they'll have a use for my experience.",
		"One more try. Next time, we'll get it right.",
	},
    
    -- UI Barks
    Upgrade_PowerWeapon = {
		"Ministry of Science is working double time it seems.",
		"Niiiice!",
	},
    Upgrade_NoWeapon = {
		"What? I mean, I have faith in your command.",
		"I'll beat the shit of the bugs with my own hands.",
	},
    Upgrade_PowerGeneric = {
		"Maximum democractic power.",
		"Super Engineering did a nice job on this.",
	},
    
    -- Mid-Battle
    MissionStart = {
		"Democracy time.",
		"You'll have a taste of Liber-Tea!",
		"FREEDOM TIME!",
	},
    Mission_ResetTurn = {
		"That was weird.",
		"Time is the new best ally of Democracy!",
	},
    MissionEnd_Dead = {
		"Aaah, the taste of uncontested managed Democracy.",
		"Democracy won't suffer any enemy!",
	},
    MissionEnd_Retreat = {
		"Come back taste some more Democracy!",
		"They are fleeing against the herald of Freedom!",
	},

    PodIncoming = {
		"Time Pod on my scope!",
		"Weapons from the future! Maybe this will help our chances.",
	},
    PodResponse = {
		"An Hell Pod! What a magnificient sight!",
		"Protect that Hell Pod!",
	},
    PodCollected_Self = {
		"Mine now.",
		"Contents of the Pod are secure.",
	},
    PodDestroyed_Obs = {
		"A war can't be won without weapons.",
		"We needed that. It's dust now...",
	},
    Secret_DeviceSeen_Mountain = {
		"Got a strange reading from that mountain.",
	},
    Secret_DeviceSeen_Ice = {
		"Got a strange reading from under that ice.",
	},
    Secret_DeviceUsed = {
		"Sample recovered!",
	},

    Secret_Arriving = {
		"I've never seen a Hell Pod like that!",
	},
    Emerge_Detected = {
		"They'll get a taste of Freedom soon enough.",
	},
    Emerge_Success = {
		"Say hello to Democracy!",
	},
    Emerge_FailedMech = {
		"I won't let you free as long as you won't accept Freedom.",
		"My heroic #self_mech blocked the Vek.",
	},
    Emerge_FailedVek = {
		"They're hindered by their own vile kind.",
	},

    -- Mech State
    Mech_LowHealth = {
		"My life for Democracy!",
		"Sweet Democracy! My arm!",
		"Sweet Liberty...",
	},
    Mech_Webbed = {
		"These subforms of life only use traitorous tactics.",
		"Webbing, uh? More like undemocratic action.",
		"Sweet Freedom, what in Super Earth is this shit?",
	},
    Mech_Shielded = {
		"They're not ready for this!",
		"I'm protected by Democracy!",
	},
    Mech_Repaired = {
		"Repairs done, now time for some democratic delivery...",
		"All good, let's get back at bugs killing!",
	},
    Pilot_Level_Self = {
		"I'll be a 10-Star General in no time!",
		"Proud Super Citizen reporting!",
		"Glorious day for Democracy!",
	},
    Pilot_Level_Obs = {
		"You'll be a 5-Star General in no time!",
		"You're the pride of Democracy!",
	},
    Mech_ShieldDown = {
		"Shield is down, but Democracy will protect me anyway!",
		"Requesting air support!",
	},

    -- Damage Done
    Vek_Drown = {
		"This sea is surely very democratic.",
		"Water is the new best ally of Democracy !",
	},
    Vek_Fall = {
		"This chasm is surely very democratic.",
		"Being an undemocratic scum sure is a bottomless pit.",
	},
    Vek_Smoke = {
		"This should blind it.",
		"That smokescreen should keep it from attacking.",
	},
    Vek_Frozen = {
		"I-cey, Democracy come in any form.",
		"This Vek is a bit less undemocratic.",
	},
    VekKilled_Self = {
		"Get some! GET SOOOOOME!!!",
		"I'm doing my part!",
	},
    VekKilled_Obs = {
		"Clearing these lands from filthy bugs, one at a time!",
		"This one is for you, Democracy!",
		"This disgusting bug has been freed from its own existence!",
	},
    VekKilled_Vek = {
		"They couldn't live while being this undemocratic.",
		"It seems that these creatures want to repent and earn their Super Citizenship!",
	},

    DoubleVekKill_Self = {
		"Double kill!",
		"Super Earth! That's for you!",
	},
    DoubleVekKill_Obs = {
		"Good job fellow Mech Divers!",
		"Two less threats for Democracy in one shot!",
	},
    DoubleVekKill_Vek = {
		"Yes! Democratize yourself, you undemocratic bastards!",
		"Doube kill! Wait what?",
	},

    MntDestroyed_Self = {
		"Clearing the rubble.",
		"Let's get these rocks out of the way.",
	},
    MntDestroyed_Obs = {
		"This mountain wasn't democratic anyway.",
		"Another blockade of Freedom democratized!",
	},
    MntDestroyed_Vek = {
		"They're clearing the rubble.",
		"The Vek must not like rocks.",
	},

    PowerCritical = {
		"Save the Grid, save the Democracy!",
		"GIVE EVERYTHING YOU GOT! WE CANNOT LET DEMOCRACY DIE!!!",
	},
    Bldg_Destroyed_Self = {
		"I've failed Democracy!",
		"These Super Citizens gave their life for our future!",
	},
    Bldg_Destroyed_Obs = {
		"You've got patriots' blood on your hands! You better surpass yourself",
		"Ministry of Truth will have a talk with you after this mission.",
	},
    Bldg_Destroyed_Vek = {
		"Sweet Democracy! Avenge these innocent Super Citizens!",
		"This is Malevelon Creek all over again.",
	},
    Bldg_Resisted = {
		"Super Earth protects!",
		"I never doubted Democracy, neither did these Super Citizens!",
	},
	
	-- Shared Mission Events
	Mission_Train_TrainStopped = {
		"Super Train's been damaged. Protect the cargo!",
		"Don't let that Super Train take another hit, or we'll lose the cargo too!",
	},
	Mission_Train_TrainDestroyed = {
		"Lost the Super Train.",
	},
	Mission_Block_Reminder = {
		"Keep those bugs under the ground, demolition team will deal with them later!",
	},
	
	-- Archive Mission Events
	Mission_Tanks_Activated = {
		"Tank you!",
		"Oh-oh! Democracy time!",
	},
	Mission_Tanks_PartialActivated = {
		"One heroic tank made it.",
	},
	Mission_Satellite_Destroyed = {
		"This Super Satellite fell to the enemy of Democracy.",
	},
	Mission_Satellite_Imminent = {
		"That Super Satellite is about to launch.",
	},
	Mission_Satellite_Launch = {
		"This rocket is espacing to the one place that hasn't been corrupted by communism... SPACE!!!",
		"Democracy's pride!",
	},
	Mission_Dam_Reminder = {
		"Damocracy can't suffer to wait.",
	},
	Mission_Dam_Destroyed = {
		"DAMOCRACY!!!",
	},
	Mission_Mines_Vek = {
		"These patriotic mines are a great tool!",
	},
	Mission_Airstrike_Incoming = {
		"Eagle inbound.",
		"Air support in coming!",
	},
	
	-- R.S.T. Mission Events
	Mission_Force_Reminder = {
		"Gotta clear those mountains or the Bugs will infest them.",
	},
	Mission_Lightning_Strike_Vek = {
		"This undemocratic bug was smiting by pure Justice!",
		"Thunder is the new best ally of Democracy!",
	},
	Mission_Terraform_Destroyed = {
		"Terraformer sounded like a commie tool anyway.",
	},
	Mission_Terraform_Attacks = {
		"This is the taste of Democracy!",
		"Purge these lands to rebuild Democracy!",
	},
	Mission_Cataclysm_Falling = {
		"Don't fall, these are full of undemocratic things.",
		"The ground cannot support our Democracy payload!",
	},
	Mission_Solar_Destroyed = {
		"Super Solar panel lost!",
	},
	
	-- Pinnacle Mission Events
	BotKilled_Self = {
		"Die communist scum!",
		"I can't stand the sight of these Automaton commies!",
	},
	BotKilled_Obs = {
		"Yes, die communist scum!",
		"Good job! I can't stand the sight of these Automaton commies!",
	},
	Mission_Factory_Destroyed = {
		"This factory was a bit too much communist anyway.",
		"Objective accomplished! Right? RIGHT??!",
	},
	Mission_Factory_Spawning = {
		"Zenith are traitors to Democracy.",
		"Is this Cyberstan?!",
	},
	Mission_Reactivation_Thawed = {
		"That ice isn't holding them!",
		"Vek is on the move again!",
	},
	Mission_Freeze_Mines_Vek = {
		"N-ICE!",
		"Interesting commie technology.",
	},
	Mission_SnowStorm_FrozenVek = {
		"These bugs are temporarily democratized",
		"This weather is democratic.",
	},
	Mission_SnowStorm_FrozenMech = {
		"De... mo... cr... icy",
		"Fresh freedom!",
	},
	
	-- Detritus Mission Events
	Mission_Barrels_Destroyed = {
		"I'll drink to that.",
		"Let the Vek soak in that.",
	},
	Mission_Disposal_Destroyed = {
		"Doesn't look like we can salvage that disposal unit, commander.",
		"Shame to lose such a potent weapon.",
	},
	Mission_Disposal_Disposal = {
		"Nothing is going to be left standing after that.",
		"Those mountains will simply dissolve away, in the face of that.",
	},
	Mission_Power_Destroyed = {
		"Doesn't look like we can salvage that power plant, commander.",
		"Grid power decreasing!",
	},
	Mission_Belt_Mech = {
		"Here we go!",
		"Uncommanded relocation underway!",
	},
	Mission_Teleporter_Mech = {
		"Country TP'ies, take me home, to the democracy I belong!",
	},
	
	-- Meridia Mission Events
	Mission_lmn_Convoy_Destroyed = {
		"This heroic convoy fell as a martyr of Democracy!",
	},
	Mission_lmn_FlashFlood_Flood = {
		"I wish this would flood our enemies with Democracy.",
	},
	Mission_lmn_Geyser_Launch_Mech = {
		"I wonder if these Geysers adhere to democratic values.",
	},
	Mission_lmn_Geyser_Launch_Vek = {
		"That's a lot of pressure!",
		"That should give the Vek something to think about.",
	},
	Mission_lmn_Volcanic_Vent_Erupt_Vek = {
		"That should give the Vek something to think about.",
		"This island is turning up the heat.",
	},
	Mission_lmn_Wind_Push = {
		"Winds of Liberty!",
	},
	
	Mission_lmn_Runway_Imminent = {
		"Stay clear of that runway, #squad.",
	},
	Mission_lmn_Runway_Crashed = {
		"Eagle down!",
	},
	Mission_lmn_Runway_Takeoff = {
		"Eagle away.",
	},
	Mission_lmn_Greenhouse_Destroyed = {
		"That Super Greenhouse was destroyed.",
		"That greenhouse didn't survive.",
	},
	Mission_lmn_Geothermal_Plant_Destroyed = {
		"That Super Geothermal Plant was destroyed.",
	},
	Mission_lmn_Hotel_Destroyed = {
		"Don't let them destroy our way of life!",
	},
	Mission_lmn_Agroforest_Destroyed = {
		"This Super Agroforest was destroyed by the enemy of Democracy.",
	},
	
-- tosx missions
	-- Island missions
	Mission_tosx_Juggernaut_Destroyed = {
		"Juggernaut destroyed.",
	},
	Mission_tosx_Juggernaut_Ram = {
		"I don't trust this Automaton-looking ball.",
	},
	Mission_tosx_Zapper_On = {
		"Tesla tower democratized!",
	},
	Mission_tosx_Zapper_Destroyed = {
		"This tesla tower fell.",
	},
	Mission_tosx_Warper_Destroyed = {
		"This Super Portal Tender is down but its pride remains high!",
	},
	Mission_tosx_Battleship_Destroyed = {
		"This Super Battleship sank but its pride is eternal!",
	},
	
	-- Island missions 2
	Mission_tosx_Siege_Now = {
		"FOR SUPER EEEAAAARTH!",
		"They surrounded us? Nice, we just need to fire in every direction now!",
	},
	Mission_tosx_Plague_Spread = {
		"Stand clear, #squad!",
		"That thing is a walking deathtrap!",
	},
	
	-- AE
	Mission_ACID_Storm_Start = {
		"A.C.I.D.? As in Awesome Civilized Infallible Democracy?",
	},	
	Mission_ACID_Storm_Clear = {
		"Sky is now as pure a Democracy!",
		"Storm controller democratized!.",
	},	
	Mission_Wind_Mech = {
		"Winds of Democracy!",
	},	
	Mission_Repair_Start = {
		"Requesting repairs!",
	},	
	Mission_Hacking_NewFriend = {
		"Reject the commies, return to Democracy!",
		"This Automaton has been freed from Communism and embraced Democracy!",
	},	
	Mission_Shields_Down = {
		"The undemocratic veil fell!",
	},
	
	-- Final
	MissionFinal_Start = {
		"Democracy runs through our veins, but our Mechs need their own share of democratic juice too!",
	},
	MissionFinal_StartResponse = {
		"I see the pylons inbound. Ready for Grid connection.",
	},
	MissionFinal_FallResponse = {
		"What in the Freedom?!",
	},
	MissionFinal_Bomb = {
		"We need the biggest payload Super Earth can offer!",
	},
	MissionFinal_CaveStart = {
		"This is Democracy's judgement day. Protect that Hell Bomb, #squad.",
	},
	MissionFinal_BombArmed = {
		"Hell Bomb armed, clear the area!",
	},
	
	-- Watchtower missions
	Mission_tosx_Sonic_Destroyed = {
		"The Super Disruptor has been destroyed by the enemies of Democracy.",
	},
	Mission_tosx_Tanker_Destroyed = {
		"Super Tanker's crew died with honor.",
	},
	Mission_tosx_TankerFull_Destroyed = {
		"Watchtower is crawling with capable scavengers; I'm sure Akai will find someone to retrieve the water from that wreckage.",
		"Knowing Akai, he's already got a salvage team en route to recover the water from that wreck.",
	},
	Mission_tosx_Rig_Destroyed = {
		"Doesn't look like we can salvage that War Rig, commander.",
		"Lost the War Rig.",
		"Shame to lose such a weapon with such potential.",
	},
	Mission_tosx_GuidedKill = {
		"Looks like that targeting data was spot on.",
		"Feed it a missile!",
	},
	Mission_tosx_NuclearSpread = {
		"Watch out for the fallout!",
	},
	Mission_tosx_RaceReminder = {
		"Let's manage this race as the Ministry watches over our beautiful Democracy!",
	},
	Mission_tosx_MercsPaid = {
		"This is the price of Freedom!",
	},
	Mission_tosx_RigUpgraded = {
		"Rare samples acquired by the Rig!",
	},
	
	--Far Line missions
	Mission_tosx_Delivery_Destroyed = {
		"Our supplies has been wasted by these vile minions!",
	},
	Mission_tosx_Sub_Destroyed = {
		"Heroic Super Sub sunk!",
	},
	Mission_tosx_Buoy_Destroyed = {
		"Oh buoy.",
	},
	Mission_tosx_Rigship_Destroyed = {
		"Heroic Super Ship sunk.",
	},
	Mission_tosx_SpillwayOpen = {
		"Water is enjoying Freedom!",
	},
	Mission_tosx_OceanStart = {
		"This is as vast as our Freedom.",
	},
}