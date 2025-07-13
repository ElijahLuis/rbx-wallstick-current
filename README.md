# Roblox Wallstick (Modernized)
A system for sticking characters to surfaces within Roblox, created by EgoMoose and modified by Nejinumanuma.

## How It Works
1. The server sets up collision groups, patches `StarterPlayerScripts` with a
camera modifier, and starts the replication service. 
2. When the local character spawns, `clientEntry.client` constructs a `Wallstick` instance. 
It creates a stripped clone of the character using `CharacterHelper` and aligns this "fake"
model to nearby surfaces found via raycasts. 
3. AlignPosition and AlignOrientation then pull the real humanoid to match, while `GravityCamera`- 
augmented by the camera modifier - rotates the view and `RotationSpring` smooths motion. 
5. The current surface part and offset are sent through `Wallstick.Replication` so the
server can relay orientation to other clients. Parameters like stick range and
fall timing come from `WallstickConfig`.

## Demo
A ready-made place to test the Wallstick module can be found at `demo/playground.rbxl`. 
You can also find videos created by EgoMoose which shows how it works:
- Example 1: https://github.com/user-attachments/assets/bd4efde2-9323-4db1-896c-6407263e458e
- Example 2: https://github.com/user-attachments/assets/2a0478de-6e1f-4676-b778-9709b9e3f18f
- Example 3: https://github.com/user-attachments/assets/c6d9a53d-f6c2-4924-9286-728e21b92ee8

## Installation
This module uses the Roblox open-source toolchain:  
**wally** for dependency management, **rojo** for syncing/building, and optionally **lune** for type safety.

1. Install the tools. Make sure they are available on your `PATH` or managed with [Rokit](https://github.com/rojo-rbx/rokit):

- [Wally](https://github.com/UpliftGames/wally)
- [Rojo](https://github.com/rojo-rbx/rojo). Also install the Roblox Studio plugin.
- [Lune](https://github.com/lune-org/lune/releases).

2. From the repository root, run `wally install` to fetch Lua dependencies. 
3. Start a live session with `rojo serve`. Then use the Rojo plugin on Roblox Studio to sync your session. 

When both "rojo serve" is running and Rojo plugin is connected, all changes made in your coding environment should now reflect in Roblox Studio. 

## Configuration
Key movement parameters can be tweaked in `ReplicatedStorage.WallstickConfig`.
Adjust values like `STICK_RANGE`, `DETECTION_SHAPE`, or `MAX_FALL_DISTANCE` to fit your game before building with Rojo.

## New Features (added by Nejinumanuma)
* **Avatar support** - both R6 and R15 characters are handled correctly.
* **Simple replication** - player orientation is replicated between clients via `Wallstick.Replication`.
* **Runtime streaming check** - the client warns when `StreamingEnabled` is on.
* **Terrain support** - players can now walk on terrain (still under testing)

## Limitations
* StreamingEnabled must be turned off. The system is not designed for streaming-enabled places.
* Replication only synchronizes wall stick offsets; complex movement or physics may still look different per client.

## Troubleshooting
* Ensure `workspace.Terrain` exists and contains solid terrain or ground parts. The character defaults to sticking to terrain when no other part is found.
* If the character does not attach, verify that Wally packages are installed and that Rojo successfully built the place. Missing packages will produce runtime warnings.

