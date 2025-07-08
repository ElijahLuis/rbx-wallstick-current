# rbx-wallstick
A system for sticking characters to surfaces within Roblox.

### Videos

https://github.com/user-attachments/assets/bd4efde2-9323-4db1-896c-6407263e458e

https://github.com/user-attachments/assets/2a0478de-6e1f-4676-b778-9709b9e3f18f

https://github.com/user-attachments/assets/c6d9a53d-f6c2-4924-9286-728e21b92ee8

## Installation

1. Install [Wally](https://github.com/UpliftGames/wally), [Rojo](https://github.com/rojo-rbx/rojo), and [Lune](https://github.com/lune-org/lune/releases) and make sure they are available on your `PATH`. Lune can also be installed using [Rokit](https://github.com/rojo-rbx/rokit).
2. From the repository root run `wally install` to fetch Lua dependencies.
3. Build the place with `rojo build default.project.json -o Wallstick.rbxlx` or start a live session with `rojo serve`.

## Testing

1. Install development dependencies with `wally install`.
2. Run the test runner using `lune/run-tests.luau`:

```bash
lune run lune/run-tests.luau
```


## Demo

A ready made place can be found at `demo/playground.rbxl`. You can open this file directly in Roblox Studio after running `wally install`. Alternatively build your own place with Rojo using the command above.

## New Features

* **R6 avatar support** – both R6 and R15 characters are handled correctly.
* **Simple replication** – player orientation is replicated between clients via `Wallstick.Replication`.
* **Runtime streaming check** – the client warns when `StreamingEnabled` is on.

## Limitations

* StreamingEnabled must be turned off. The system is not designed for streaming-enabled places.
* Replication only synchronizes wall stick offsets; complex movement or physics may still look different per client.

## Troubleshooting

* Ensure `workspace.Terrain` exists and contains solid terrain or ground parts. The character defaults to sticking to terrain when no other part is found.
* If the character does not attach, verify that Wally packages are installed and that Rojo successfully built the place.

