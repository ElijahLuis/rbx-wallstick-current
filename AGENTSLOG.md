# AGENTSLOG.md  
_Logbook and quick-reference for previously known issues_
This file tracks specific errors, workarounds, and gotchas observed during development.  
If you're an agent (like Codex), check this log **after reading `README.md` and `AGENTS.md`** for runtime-specific issues or patterns.

## Common Pitfalls

### "TransparencyController is missing"  
Expected. Default `CameraModule` was replaced by custom `GravityCamera.luau`, injected via `GravityCameraModifier.luau`.
~---~
### "CameraModule.redirect is not a function"  
You're likely referencing default modules. Use the **patched** `CameraModule` under `ServerPackages`.
~---~
### "Character falls forever"  
`GravityController:step()` isn’t detecting ground.  
- Confirm downward raycast works  
- Check `REBOUND_SOFT_TIME`, `MAX_DISTANCE`  
- Ensure clone is aligned properly
~---~
### "Clone not matching pose"  
Likely due to invalid constraints or raycast normals.  
- Debug in `CharacterHelper.luau`  
- Ensure clone rig matches source and normals are non-zero
~---~
### "Duplicate PlayerModule?"  
Use only:  
`ServerPackages/upliftgames_playermodule@*/src/PlayerModulePatched`  
Ignore `Unpatched` unless testing.
~---~
### "Replication feels off"  
Normal. Only offset + orientation are synced (not full movement).  
See `Replication.luau` and `GravityManager.luau`.
~---~
### 🔁 "Requested module was required recursively"
Happens when a module (usually `GravityCameraModifier`) indirectly requires itself or is required too early.

**Cause:**  
`PlayerModule` is not fully initialized when the modifier runs.

**Fix:**  
Only apply modifiers *after* confirming `PlayerModule` is a valid table. Defer until `PlayerScriptsLoader` has finished setup.
~---~
### 🔧 "TransparencyController:192 - arithmetic on nil"
Thrown by Roblox's **default** `TransparencyController`, which is still being loaded.

**Cause:**  
When Wallstick’s patched camera system fails to fully override the default `CameraModule`, Roblox loads its fallback, which expects values you've removed or never defined.

**Fix / Workaround:**  
- Ensure the **patched** `PlayerModule` loads without errors  
- Prevent recursive requires in `GravityCameraModifier`  
- You cannot patch `TransparencyController` directly—safest solution is ensuring it never loads  
- As a last resort, conditionally disable fallback behavior via input-type checks (advanced)

## DO NOT ASSUME:
- `Humanoid:GetState()` is unused  
- Camera is not default  
- The player is a constraint-moved clone  
- Modules are intentionally separated. Do not merge.

## 🧠 Quick Reminders
- Tune everything via `WallstickConfig.luau`  
- Don’t yield between raycast and apply  
- Check Rojo sync before debugging logic  
- `init.luau` can loop—watch for circular requires

## 🛠️ Dev Notes
- Always use `demo/playground.rbxl`  
- Run `wally install` + `rojo serve` before Studio  
- Ensure `StreamingEnabled` is OFF  
- Use `src/shared` for config sync
~---~
_TODO: Continue logging bugs + patterns here._
