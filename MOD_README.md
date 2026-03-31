# FieldField Mod

A custom mod for Starfield created with the Creation Kit.

## Description

FieldField mod - [describe what your mod does here].

## Installation

1. Place the `.esp` file in your `Starfield/Data/` folder
2. Enable the mod in your mod manager or Starfield's launcher
3. Load your save game

## Requirements

- Starfield
- Creation Kit (for editing)

## Features

- Hatch/ship interior systems (FieldField core)
- **Dungeon Crawl Camera System**: rooms/floors index, pathfinding over nodes, step-by-step movement with camera at centroids, quest integration, optional UI character-card slots. See [DUNGEON_CRAWL.md](DUNGEON_CRAWL.md) for setup and usage.
- **Clickable ladders**: Ladder refs with highlight-to-use (optional EffectShader) and configurable destination. See [LADDERS.md](LADDERS.md) for setup.
- **Group Tactics (Snowfield)**: Ability-based party mode: number key = character, Space = activate ability; packed formation at each node; eight abilities (Attack, Heal, Call to Arms, Force power, Robot power attack, Apologize, Guard, Call for Help). See [GROUP_TACTICS.md](GROUP_TACTICS.md).
- **Porrima II Ring Builder**: Circumnavigating procedural planetary land builder; 12 rings, zone linked list, placement/roam volumes, map manager, strip export, total conversion startup. See [RING_BUILDER.md](RING_BUILDER.md).

## How to Use

- **Dungeon Crawl**: Configure the Index, Pathfinding, and Controller quests in the Creation Kit (see DUNGEON_CRAWL.md). Place room/floor markers in interiors; start the Controller quest and call `StartMovementToNode(nodeID)` to run procedural movement to a target node.
- **Ladders**: Attach FieldFieldLadderRef to ladder refs; set DestinationRef and optional HighlightShader. Set activation text in the CK for the “Use Ladder” prompt. See [LADDERS.md](LADDERS.md).

## Development

### Scripts

Papyrus source scripts are located in `Data/Scripts/Source/`
Compiled scripts should be placed in `Data/Scripts/`

**Before compiling**: Extract the game’s base script sources from `Starfield/Tools/ContentResources.zip` into your project or the compiler’s search path. The compiler needs these to resolve vanilla types (`Game`, `ObjectReference`, `Quest`, etc.). Extract the `Scripts` folder from the archive into `Data/Scripts/Source/Base` (or set the compiler import path to that folder).

#### External compilers (command-line)

Two wrapper scripts in `Data/Scripts/Source/` let you compile without opening the Creation Kit:

| Wrapper | Compiler | When to use |
|---------|----------|-------------|
| **compile_ck.cmd** | Creation Kit `PapyrusCompiler.exe` | **Recommended for release.** Same compiler as the CK; supports all Starfield features (e.g. GUARD). Requires Creation Kit installed (`Tools/Papyrus Compiler/`). |
| **compile_caprica.cmd** | [Caprica](https://github.com/Orvid/Caprica) | Quick CLI/CI; no CK required. Does not support GUARD; use CK compiler if your scripts use GUARD or you want byte-for-byte CK behavior. Put `caprica.exe` in `Data/Scripts/Source/` or set `CAPRICA_PATH`. |

**Usage**: Run the CMD from `Data/Scripts/Source/`. You can pass a script name (e.g. `compile_ck.cmd FieldFieldRingBuilderQuest.psc`) or run with no args and enter:
- **script name** – compile that script
- **FIELD** – compile only `FieldField*.psc` (mod scripts; avoids base-game path/flag issues)
- **ALL** – compile the whole Source tree (CK: namespaced Base scripts may warn; Caprica: some base scripts use flags like `protected`/`selfonly` that Caprica doesn’t support, so use FIELD for a clean mod-only build)

Edit the path block at the top of each CMD to set `GAMEROOT` to your Starfield install (e.g. `d:\SteamLibrary\steamapps\common\Starfield`).

### Creating the Plugin

1. Open Creation Kit
2. Create a new plugin or load an existing one
3. Make your changes
4. Save as `.esp` file in the `Data/` folder

## Version History

- v1.0.0 - Initial release

## Credits

Created by [Your Name]

