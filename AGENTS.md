## General Behavior
- Do not combine modules into a monolithic class. Modularity is intentional for readability, hot-swapping, and debugging.
- Avoid removing "helper" modules like CharacterHelper or GravityController even if they look redundant. These are decoupled for runtime clarity.
- Preserve async/yield logic. Don't inline waits or tween delays - Wallstick relies on precise frame-timing and Raycast hit validation.

When suggesting code changes:
- Use safe modular edits (CharacterHelper → update function)
- Avoid full rewrites unless explicitly requested

When modifying constants:
- Prefer WallstickConfig.luau edits over hardcoded values
- Do not rely on StarterPlayerScripts loading order - it’s customized by the server

## File Discovery and Loading
- Use default.project.json for file-to-instance mapping. Many files are not placed using directory name = instance name.
- ServerPackages/PlayerModule.lua is not a Roblox default. It is a patched module. Do not attempt to revert it.
- The root entry points are:
    - src/client/clientEntry.client.luau → Client-side runtime
    - src/server/init.server.luau → Server setup
    - src/shared/WallstickConfig.luau → Shared config values

## Character and Camera
- Wallstick uses clone-based alignment, not native Humanoid physics. The visible player is a decoy.
- Camera logic is custom-built in GravityCamera.luau using RotationSpring.
- Do not revert to Roblox's default CameraModule behavior. That system is intentionally patched via GravityCameraModifier.

## Troubleshooting and Debugging
- Refer to README.md and AGENTSLOG.md for additional context.

## Wallstick Directory
_Complete file tree of project (52 directories, 177 files)_
.
├── .gitattributes
├── .gitignore
├── .luaurc
├── .vscode
│   ├── selene.yml
│   └── settings.json
├── AGENTS.md
├── LICENSE
├── PROJECT_STRUCTURE.txt
├── Packages
│   ├── CharacterAnimate.lua
│   ├── CharacterSounds.lua
│   ├── RaycastHelper.lua
│   ├── Trove.lua
│   ├── TypedRemote.lua
│   └── _Index
│       ├── egomoose_character-animate@0.0.3
│       │   ├── Signal.lua
│       │   └── character-animate
│       │       ├── LICENSE
│       │       ├── README.md
│       │       ├── aftman.toml
│       │       ├── assets
│       │       │   └── baseplate.rbxl
│       │       ├── default.project.json
│       │       ├── develop.project.json
│       │       ├── selene.toml
│       │       ├── src
│       │       │   ├── AnimateR15.lua
│       │       │   ├── AnimateR6.lua
│       │       │   ├── ManualDirector.lua
│       │       │   └── init.lua
│       │       ├── test
│       │       │   ├── Animate
│       │       │   │   ├── PlayEmote.model.json
│       │       │   │   └── init.client.lua
│       │       │   └── init.server.lua
│       │       └── wally.toml
│       ├── egomoose_character-sounds@0.2.1
│       │   ├── Signal.lua
│       │   └── character-sounds
│       │       ├── LICENSE
│       │       ├── README.md
│       │       ├── aftman.toml
│       │       ├── assets
│       │       ├── default.project.json
│       │       ├── develop.project.json
│       │       ├── selene.toml
│       │       ├── src
│       │       │   ├── AtomicBinding.lua
│       │       │   ├── ManualDirector.lua
│       │       │   ├── SoundSystem.lua
│       │       │   └── init.lua
│       │       ├── stylua.toml
│       │       ├── test
│       │       │   ├── RbxCharacterSounds.client.lua
│       │       │   └── init.server.lua
│       │       └── wally.toml
│       ├── egomoose_raycast-helper@3.0.0
│       │   └── raycast-helper
│       │       ├── LICENSE
│       │       ├── default.project.json
│       │       ├── src
│       │       │   └── init.luau
│       │       ├── wally.lock
│       │       └── wally.toml
│       ├── sleitnick_trove@1.5.0
│       │   └── trove
│       │       ├── index.d.ts
│       │       ├── init.luau
│       │       ├── init.spec.luau
│       │       └── wally.toml
│       ├── sleitnick_typed-remote@0.2.0
│       │   └── typed-remote
│       │       ├── init.luau
│       │       └── wally.toml
│       └── stravant_goodsignal@0.2.1
│           └── goodsignal
│               ├── LICENSE
│               ├── README.md
│               ├── default.project.json
│               ├── src
│               │   └── init.lua
│               └── wally.toml
├── README.md
├── ServerPackages
│   ├── PlayerModule.lua
│   └── _Index
│       └── upliftgames_playermodule@675.1.6750723
│           └── playermodule
│               ├── README.md
│               ├── aftman.toml
│               ├── default.project.json
│               ├── src
│               │   ├── PlayerModulePatched
│               │   │   ├── CameraModule
│               │   │   │   ├── BaseCamera.lua
│               │   │   │   ├── BaseOcclusion.lua
│               │   │   │   ├── CameraInput.lua
│               │   │   │   ├── CameraToggleStateController.lua
│               │   │   │   ├── CameraUI.lua
│               │   │   │   ├── CameraUtils.lua
│               │   │   │   ├── ClassicCamera.lua
│               │   │   │   ├── Invisicam.lua
│               │   │   │   ├── LegacyCamera.lua
│               │   │   │   ├── MouseLockController.lua
│               │   │   │   ├── OrbitalCamera.lua
│               │   │   │   ├── Poppercam.lua
│               │   │   │   ├── TransparencyController.lua
│               │   │   │   ├── VRBaseCamera.lua
│               │   │   │   ├── VRCamera.lua
│               │   │   │   ├── VRVehicleCamera.lua
│               │   │   │   ├── VehicleCamera
│               │   │   │   │   ├── VehicleCameraConfig.lua
│               │   │   │   │   ├── VehicleCameraCore.lua
│               │   │   │   │   └── init.lua
│               │   │   │   ├── ZoomController
│               │   │   │   │   ├── Popper.lua
│               │   │   │   │   └── init.lua
│               │   │   │   └── init.lua
│               │   │   ├── CommonUtils
│               │   │   │   ├── CameraWrapper.lua
│               │   │   │   ├── CharacterUtil.lua
│               │   │   │   ├── ConnectionUtil.lua
│               │   │   │   └── FlagUtil.lua
│               │   │   ├── ControlModule
│               │   │   │   ├── BaseCharacterController.lua
│               │   │   │   ├── ClickToMoveController.lua
│               │   │   │   ├── ClickToMoveDisplay.lua
│               │   │   │   ├── DynamicThumbstick.lua
│               │   │   │   ├── Gamepad.lua
│               │   │   │   ├── Keyboard.lua
│               │   │   │   ├── PathDisplay.lua
│               │   │   │   ├── TouchJump.lua
│               │   │   │   ├── TouchThumbstick.lua
│               │   │   │   ├── VRNavigation.lua
│               │   │   │   ├── VehicleController.lua
│               │   │   │   └── init.lua
│               │   │   ├── Modifiers.lua
│               │   │   ├── Patch.lua
│               │   │   └── init.lua
│               │   ├── PlayerModuleUnpatched
│               │   │   ├── CameraModule
│               │   │   │   ├── BaseCamera.lua
│               │   │   │   ├── BaseOcclusion.lua
│               │   │   │   ├── CameraInput.lua
│               │   │   │   ├── CameraToggleStateController.lua
│               │   │   │   ├── CameraUI.lua
│               │   │   │   ├── CameraUtils.lua
│               │   │   │   ├── ClassicCamera.lua
│               │   │   │   ├── Invisicam.lua
│               │   │   │   ├── LegacyCamera.lua
│               │   │   │   ├── MouseLockController.lua
│               │   │   │   ├── OrbitalCamera.lua
│               │   │   │   ├── Poppercam.lua
│               │   │   │   ├── TransparencyController.lua
│               │   │   │   ├── VRBaseCamera.lua
│               │   │   │   ├── VRCamera.lua
│               │   │   │   ├── VRVehicleCamera.lua
│               │   │   │   ├── VehicleCamera
│               │   │   │   │   ├── VehicleCameraConfig.lua
│               │   │   │   │   ├── VehicleCameraCore.lua
│               │   │   │   │   └── init.lua
│               │   │   │   ├── ZoomController
│               │   │   │   │   ├── Popper.lua
│               │   │   │   │   └── init.lua
│               │   │   │   └── init.lua
│               │   │   ├── CommonUtils
│               │   │   │   ├── CameraWrapper.lua
│               │   │   │   ├── CharacterUtil.lua
│               │   │   │   ├── ConnectionUtil.lua
│               │   │   │   └── FlagUtil.lua
│               │   │   ├── ControlModule
│               │   │   │   ├── BaseCharacterController.lua
│               │   │   │   ├── ClickToMoveController.lua
│               │   │   │   ├── ClickToMoveDisplay.lua
│               │   │   │   ├── DynamicThumbstick.lua
│               │   │   │   ├── Gamepad.lua
│               │   │   │   ├── Keyboard.lua
│               │   │   │   ├── PathDisplay.lua
│               │   │   │   ├── TouchJump.lua
│               │   │   │   ├── TouchThumbstick.lua
│               │   │   │   ├── VRNavigation.lua
│               │   │   │   ├── VehicleController.lua
│               │   │   │   └── init.lua
│               │   │   └── init.lua
│               │   ├── VersionInfo.json
│               │   └── init.lua
│               └── wally.toml
├── cspell.json
├── default.project.json
├── demo
│   └── playground.rbxl
├── lune
│   └── wally-install.luau
├── rokit.toml
├── selene.toml
├── src
│   ├── client
│   │   ├── Wallstick
│   │   │   ├── CharacterHelper.luau
│   │   │   ├── DoubleJump.luau
│   │   │   ├── GravityCamera.luau
│   │   │   ├── Replication.luau
│   │   │   ├── RotationSpring.luau
│   │   │   ├── RotationUtils.luau
│   │   │   └── init.luau
│   │   └── clientEntry.client.luau
│   ├── server
│   │   ├── GravityManager.luau
│   │   ├── PlayerScripts
│   │   │   ├── Animate
│   │   │   │   ├── Controller.luau
│   │   │   │   ├── PlayEmote.model.json
│   │   │   │   └── init.client.luau
│   │   │   ├── CharacterSounds
│   │   │   │   ├── Controller.luau
│   │   │   │   └── init.client.luau
│   │   │   ├── GravityCameraModifier.luau
│   │   │   └── init.luau
│   │   └── init.server.luau
│   └── shared
│       ├── GravityController.luau
│       └── WallstickConfig.luau
├── stylua.toml
├── stylua.zip
├── wally.lock
└── wally.toml

