# Hell Breachers (v1.1.2)
(previously named Mech Divers)

A cup of Liber-Tea.
Let's free Super Earth from these undemocratic Vek!

## Credits
Thanks the Discord community for helping me, especially tosx and Metalocif!
And of course, thanks a lot for tob260, doing some playtesting / QA and also mental support! ;D

## Disclaimer
This mod is highly experimental. I fixed all issues I knew in vanilla, but it's likely that other mods would crash with this mod, especially with the revive mechanic.
You've been warned!

## Description

### Emancipator Mech
Equipped with Dual Autocannons and Stratagems.
The Dual Autocannons can shoot from either side of the Mech.
The Stratagems are a collections of various call-ins, ranging from weapons' drop to orbital strikes.
One Stratagem is added to the available list at each mission's start.

### Patriot Mech
Equipped with a Machine Gun, a Rocket Pods and Stratagems.
Patriot's weapon is a weapon with two modes:
- Machine Gun: shoots a projectile that deals more damage if the target is damaged. If the target is killed, the projectile continues its trajectory, with damage equal to excess damage.
- Rocket Pods: shoots a limited-use powerful rocket diagonally. If it kills its target, it damages surrounding tiles.

### Shuttle Mech
Equipped with Delivery and Reinforcements passive.
Delivery has multiple uses:
- Strafe attack: leap and shoots lateral and front tiles while moving. The damage is reduced for each possible target (any unit or building), to a minimum of 1 damage.
Reinforcements call down new Mechs piloted by rooky pilots when a Mech is destroyed.

## Notes
This mod is likely to break with other mods since it does some "experimental stuff", especially with the Mechs' reinforcement mechanic, which REMOVES the destroyed Mech and create a new Mech.
This new Mech has a new id, so any mod that assumes that Mechs are Pawns with ids ranging from 0 to 2 will break with this.

## Known bugs / incompatibilies with other mods
- Sometimes, at the start of a mission, you'll get something like Stratagem Get Target Area encountered an error.
	-> Leaving an returning to the game should solve this error

- There are also case where the mod will cause error with other mods: (especially after a new Mech has been spawned)
	- Pilot Potluck (scripts/pilots/pilot_hedera.lua:191: attempt to index a nil value)
	- Vextra (scripts/achievements.lua:451: attempt to index local 'pawn' (a nil value))
	-> These errors don't crash the game or bug the weapon and it's even not visible, so you might no even notice these

- The biggest and most nasty error happens at the start of a run and make all FMWeapons unusable. At least, it doesn't happen during the run

Unfortunately, I couldn't pinpoint these errors yet.


## Versions

### v1.1.3
Some attempts to fix the continue bug. I hope it's enough.

### v1.1.2
Added more bots to the achievement: mostly deployable bots, but also mission bots.
Cleaned up unused image files.

### v1.1.1
Fixed the error that would randomly display a black screen stating that there is an issue with Stratagem targeting.

### v1.1.0
Squad's name changed to Hell Breachers (was Mech Divers). This was proposed by Generic and won the poll!

#### Gameplay changes

Patriot Mech:
- Reduced damage of Machine Gun and Rocket Pod by 1
- Added a 1-core upgrade to increase ALL damage by 1 (including rocket pod area of effect when KO upgrade is enabled)

Eagle Mech:
- HP reduced to 2 (from 3)
- Delivery's base range reduced from 3 to 2
- Delivery's range upgrade will effectively increase its range (from 2 to 3)
- New: with delivery's range upgrade, the Supply Drop can drop up to 2 supply (between start and end point)

Stratagems:
- 2 new stratagems:
   - Orbital walking barrage: deal 2 damage on two tiles. The barrage will move by one tile every turn until it detects a building
   - AX/LAS-5 "Guard Dog" Rover: a flying drone carrying a laser weapon (dealing 2 damage at range 1 and 1 damage to the other tiles)
- Weapon drops will now deal only 1 damage on units underneath instead of kill damage
- Smoke and fire airstrikes left and right tile will now push
- Weapons' drops can be called by the Shuttle Mech to be instant (like the airstrikes)
- You can store up to 2 stratagems (but you have no limit with the upgrade)

#### Improvements / polishing
- Delivery tip image improved:
   - Will display the Delivery's Supply drop mode
   - Won't display incorrect information anymore
- All stratagems can be tested in test mech mission!
- 500kg Bomb has more impactful effect (thx Metalocif for the suggestion!): added a Board Shake, some Bounce and better outer explosion effects.
- Added tosx' Frozen Hulks as bots in "Remember Malevelon Creek" achievement calculation
- Hell drops effects improved and unified (finally added the sound too!)
- A lot of visual improvements (charged effect for the railgun, airstrikes have now a preview effect, improved orbital icons, dual cannons' long / short range projectiles, added missing stratagem weapons icons)

Bug fixes:
- Fixed reinforcement passive (now, you can only respawn 1 Mech per mission at most)
- Patriotism redirected damage wasn't reset everytime it was evaluating a damage, resulting in new redirected damage being higher than expected
- Airstrikes and Orbital strikes will be able to target an occupied tile (as it should be)

### v1.0.0
Release!