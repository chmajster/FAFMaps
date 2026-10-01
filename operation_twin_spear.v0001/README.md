# Operation Twin Spear

Stage 1 foundation for a scripted 1–2 player Forged Alliance Forever co-op operation.

The Lua framework is implemented. The binary `operation_twin_spear.scmap` is intentionally **not** committed yet: a valid SCMap must be created/saved by FAF Map Editor (or another real SCMap-capable tool). A text placeholder with a `.scmap` extension is not acceptable.

## Requirements

- Supreme Commander: Forged Alliance with Forged Alliance Forever.
- A current FAF game version compatible with the APIs used by `FAForever/fa`.
- FAF Map Editor for creating/editing the binary `.scmap`.
- Python 3 only for the repository static checker.

The Stage 1 script uses current FAF mission APIs and conventions:

- `ScenarioUtils.InitializeScenarioArmies()`
- `ScenarioFramework`
- `Objectives.Kill(...)`
- objective `AddResultCallback(...)`
- `ScenarioFramework.CreateUnitDeathTrigger(...)`
- `ScenarioFramework.EndOperation(...)`
- `ScenarioInfo.Options.Difficulty` values 1/2/3

## Installation

The final installed map directory must be named:

```text
operation_twin_spear.v0001
```

On a standard Windows FAF setup, copy it to:

```text
C:\Users\<USER>\Documents\My Games\Gas Powered Games\Supreme Commander Forged Alliance\maps\operation_twin_spear.v0001\
```

If FAF is configured to use its fallback vault location, use:

```text
C:\ProgramData\FAForever\user\My Games\Gas Powered Games\Supreme Commander Forged Alliance\maps\operation_twin_spear.v0001\
```

The FAF client-configured maps directory is authoritative if it differs from either default path.

The folder must contain a real:

```text
operation_twin_spear.scmap
```

before FAF can load the operation.

## Running the mission

1. Create the real `.scmap` as described in **Map editing**.
2. Verify the folder name is exactly `operation_twin_spear.v0001`.
3. Copy the folder to FAF's user `maps` directory.
4. Start FAF and host a co-op/custom operation using `Operation Twin Spear`.
5. Use one or two human player slots only.
6. Choose Easy, Normal, or Hard in the FAF co-op difficulty selector.
7. Start the game and verify the log contains `[OTS][INIT] Mission initialized`.

Expected Stage 1 flow:

```text
spawn UEF ACU(s)
  -> Phase 1
  -> destroy Cybran Forward Command Post
  -> Phase 2 test
  -> destroy Cybran Fire-Control Artillery
  -> scripted victory
```

## Development

Primary mission code is in `operation_twin_spear_script.lua`.

The script deliberately keeps mission state centralized in `MissionState`. Add future phases by extending the phase functions and state tables rather than scattering global flags.

Core lifecycle functions:

- `OnPopulate()`
- `OnStart()`
- `InitializeMissionState()`
- `InitializePlayers()`
- `InitializeEnemyArmies()`
- `StartMission()`
- `StartPhase1()`
- `CompletePhase1()`
- `StartPhase2()`
- `MissionVictory()`
- `MissionFailure()`

Central scaling helpers:

- `GetActivePlayerCount()`
- `GetScaledUnitCount(baseCount)`
- `GetScaledDelay(baseDelay)`
- `GetScaledResourceMultiplier()`

Current player scaling:

| Players | Enemy multiplier | Delay multiplier | Resource multiplier |
|---:|---:|---:|---:|
| 1 | 1.00 | 1.00 | 1.00 |
| 2 | 1.50 | 0.90 | 1.25 |

Current difficulty scaling:

| FAF difficulty | Name | Units | Delay | Resources |
|---:|---|---:|---:|---:|
| 1 | Easy | 0.85 | 1.15 | 0.90 |
| 2 | Normal | 1.00 | 1.00 | 1.00 |
| 3 | Hard | 1.20 | 0.85 | 1.20 |

## Map editing

Target playable size is 20 km × 20 km, represented by a 1024 × 1024 FAF map.

Create the binary map with FAF Map Editor:

1. Create a new 1024 × 1024 map or use a legally reusable blank 1024 × 1024 FAF template.
2. Save/export it as `operation_twin_spear.scmap` inside this directory.
3. Keep the scenario/save/script filenames from this repository.
4. Create or verify every marker from the table below. Marker spelling is part of the script API.
5. Preserve the army names `Player1`, `Player2`, `CybranMain`, `CybranOutpost`, and `Neutral`.
6. If the editor regenerates `operation_twin_spear_save.lua`, restore the exact army, marker and chain names used here before committing it.
7. Ensure the terrain height at all initial Stage 1 spawn markers is valid for land structures/ACUs. The checked-in starter marker data uses Y=0 because the final terrain does not exist yet; runtime spawning recalculates land-unit Y with `GetTerrainHeight(x, z)`.

Recommended high-level layout:

```text
                  NORTH

              MAIN CYBRAN BASE
                     |
                DEFENSE SECTOR
                 /         \
        WEST OUTPOST     EAST OUTPOST
                 \         /
                  CENTRAL

            PLAYER 1   PLAYER 2

                  SOUTH
```

## Required markers

| Marker | Type | Purpose |
|---|---|---|
| `PLAYER_1_START` | Blank Marker | Player 1 UEF ACU spawn |
| `PLAYER_2_START` | Blank Marker | Player 2 UEF ACU spawn |
| `ENEMY_OUTPOST_BASE` | Blank Marker | Outpost defender center |
| `ENEMY_MAIN_BASE` | Blank Marker | Future main Cybran base anchor |
| `OBJECTIVE_OUTPOST` | Blank Marker | Phase 1 command-post target |
| `OBJECTIVE_FINAL_TEST` | Blank Marker | Phase 2 test target |
| `EXPANSION_1_CENTER` | Blank Marker | Future central expansion anchor |
| `ATTACK_PATH_WEST_01` | Blank Marker | West route node 1 |
| `ATTACK_PATH_WEST_02` | Blank Marker | West route node 2 |
| `ATTACK_PATH_WEST_03` | Blank Marker | West route node 3 |
| `ATTACK_PATH_EAST_01` | Blank Marker | East route node 1 |
| `ATTACK_PATH_EAST_02` | Blank Marker | East route node 2 |
| `ATTACK_PATH_EAST_03` | Blank Marker | East route node 3 |

Required chains:

| Chain | Markers |
|---|---|
| `ATTACK_PATH_WEST` | `ATTACK_PATH_WEST_01` -> `02` -> `03` |
| `ATTACK_PATH_EAST` | `ATTACK_PATH_EAST_01` -> `02` -> `03` |

## Armies

The external names use current FAF co-op conventions (`Player1`, `Player2`) instead of literal `ARMY_1`/`ARMY_2`, because current FAF co-op logic recognizes `Player*` armies as human-player armies. Internally they correspond to the two requested player armies.

| Army | Faction | Purpose |
|---|---|---|
| `Player1` | UEF | Player 1 / requested ARMY_1 |
| `Player2` | UEF | Player 2 / requested ARMY_2; optional in solo |
| `CybranMain` | Cybran | Main Cybran force |
| `CybranOutpost` | Cybran | Forward Cybran outpost |
| `Neutral` | Neutral role | Future story/civilian assets |

`Player2` is never looked up through a literal unconditional `GetArmyBrain('Player2')`. All player-2 setup is gated by active-army detection.

## Debug mode

In `operation_twin_spear_script.lua`:

```lua
local DEBUG = false
```

Set it to `true` only during development. Debug mode:

- reduces scripted delays to 10% (minimum 0.25 s),
- enables `[OTS][DEBUG/...]` messages,
- does not alter production behavior when `DEBUG = false`.

## Logging

Mission logs use one prefix:

```text
[OTS][INIT] Mission initialized
[OTS][PLAYER] Active players: 2
[OTS][PHASE] Starting Phase 1
[OTS][OBJECTIVE] Forward Command objective created
[OTS][OBJECTIVE] Forward Command destroyed
[OTS][PHASE] Phase 1 complete
[OTS][VICTORY] Mission completed
```

There is no per-tick log spam. The player-presence watchdog wakes every five seconds and logs only a state change.

## Project structure

```text
operation_twin_spear.v0001/
├── operation_twin_spear_scenario.lua   # FAF co-op scenario registration
├── operation_twin_spear_save.lua       # armies, markers, areas and chains
├── operation_twin_spear_script.lua     # mission runtime and objectives
├── operation_twin_spear_operation.lua  # operation/debrief metadata
├── operation_twin_spear.scmap          # NOT YET COMMITTED; real binary map required
├── README.md
└── tools/
    └── static_check.py                  # deterministic Stage 1 static checks
```

There is intentionally no `_options.lua`: current FAF co-op missions use FAF's operation difficulty in `ScenarioInfo.Options.Difficulty`, so Stage 1 does not add an unnecessary parallel options system.

## Testing

Run:

```bash
python3 tools/static_check.py
```

The checker verifies the Lua files, scenario contract, army names, required markers, lifecycle/scaling functions, current FAF API references, absence of an unconditional literal Player2 brain lookup, and rejects a suspicious tiny fake `.scmap`. If `luac` exists locally, it additionally executes `luac -p` for every Lua file.

Manual FAF runtime checklist after the real `.scmap` exists:

- [ ] TEST 1 — Solo: Player1 spawns, Player2 is absent, mission starts.
- [ ] TEST 2 — Co-op: both UEF ACUs spawn with separate armies/economies.
- [ ] TEST 3 — Objective: Phase 1 objective appears and completes when its target dies.
- [ ] TEST 4 — Progression: Phase 1 transitions exactly once to Phase 2.
- [ ] TEST 5 — Victory: Phase 2 objective calls scripted operation victory.
- [ ] TEST 6 — Defeat solo: the only ACU dying causes defeat.
- [ ] TEST 7 — Defeat co-op: one ACU dying does not cause defeat; both dying does.
- [ ] TEST 8 — Callbacks: duplicate/late callbacks do not double-complete phases or the mission.
- [ ] Missing-marker test: remove/rename one required marker and verify a clear `[OTS][FAIL]` path instead of an uncontrolled Lua exception.
- [ ] Early-destruction test: destroy the Phase 1 target before formal objective activation and verify the script advances safely.
- [ ] Player-departure test: disconnect one co-op participant and confirm the surviving commander can continue if FAF removes that army from `ListArmies()`.

The repository static checker cannot validate game-engine behavior. Tests 1–8 require an actual FAF runtime and a valid binary `.scmap`.
