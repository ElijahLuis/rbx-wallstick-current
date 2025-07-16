# Roblox Wallstick (Modernized)
A modular system for sticking characters to walls, ceilings, and terrain surfaces in Roblox.  
Originally created by [EgoMoose](https://github.com/EgoMoose) and modernized by [Nejinumanuma](https://github.com/ElijahLuis).

## How It Works
Wallstick allows characters to walk on arbitrary surfaces using a combination of raycasting, alignment constraints, and camera manipulation.

### Server
- Sets up collision groups
- Patches `StarterPlayerScripts` with a custom camera modifier
- Starts the replication service

### Client
- On character spawn, `clientEntry.client` creates a `Wallstick` instance
- A stripped-down clone of the character is created via `CharacterHelper`
- This "fake" model is aligned to nearby surfaces using raycasts
- `AlignPosition` and `AlignOrientation` guide the real character to match
- `GravityCamera` rotates the camera, smoothed with `RotationSpring`

### Replication
- Surface and offset data are sent through `Wallstick.Replication` so other clients can match orientation

### Configuration
- Tweak movement parameters via `ReplicatedStorage.WallstickConfig`:
- `STICK_RANGE`
- `DETECTION_SHAPE`
- `FALL_TIME_LIMIT`
- `MAX_DISTANCE`
- `REBOUND_FORCE_MULTIPLIER`
- `REBOUND_SOFT_TIME`
- `REBOUND_COOLDOWN`

## Demo
A ready-made place to test the Wallstick module can be found at `demo/playground.rbxl`. 
You can also find videos created by EgoMoose which shows how it works:
- Example 1: https://github.com/user-attachments/assets/bd4efde2-9323-4db1-896c-6407263e458e
- Example 2: https://github.com/user-attachments/assets/2a0478de-6e1f-4676-b778-9709b9e3f18f
- Example 3: https://github.com/user-attachments/assets/c6d9a53d-f6c2-4924-9286-728e21b92ee8

## Installation
Wallstick uses the Roblox open-source toolchain:

- [Wally](https://github.com/UpliftGames/wally) – dependency management  
- [Rojo](https://rojo.space) – syncing/building  
- [Lune](https://lune-lang.org) *(optional)* – type safety  
- [Rokit](https://github.com/LPGhatguy/rokit) *(optional)* – tool manager

1. Install Wally, Rojo, and optionally Lune
2. From the repository root, run `wally install` to fetch Lua dependencies. 
3. Start a live session with `rojo serve`. Then use the Rojo plugin on Roblox Studio to sync your session. 

When both "rojo serve" is running and Rojo plugin is connected, all changes made in your coding environment should now reflect in Roblox Studio. 

## Configuration
Key movement parameters can be tweaked in `ReplicatedStorage.WallstickConfig`.
Adjust values like `STICK_RANGE`, `DETECTION_SHAPE`, or the rebound options to fit your game before building with Rojo.

## New Features (added by Nejinumanuma)
* **Avatar support** - both R6 and R15 characters are handled gracefully.
* **Simple replication** - player orientation is replicated between clients via `Wallstick.Replication`.
* **Runtime streaming check** - the client warns when `StreamingEnabled` is on.
* **Terrain support** - players can now walk on terrain (still testing)

## Limitations
* StreamingEnabled must be turned off. The system is not designed for streaming-enabled places.
* Replication only synchronizes wall stick offsets; complex movement or physics may still look different per client.

## Troubleshooting
* Ensure `workspace.Terrain` exists and contains solid terrain or ground parts. The character defaults to sticking to terrain when no other part is found.
* If the character does not attach, verify that Wally packages are installed and that Rojo successfully built the place. Missing packages will produce runtime warnings.

