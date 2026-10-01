# Operation Twin Spear

Stage 2 of a scripted Forged Alliance Forever co-op operation for exactly 1–2 UEF players.

Stage 1 established the mission framework. Stage 2 turns the southern sector into the first playable campaign chapter: starting economies, river crossings, Forward Outpost, four scripted opening waves, objective discovery, an optional radar objective, a Cybran counterattack and the controlled transition into a Phase 2 placeholder.

The binary `operation_twin_spear.scmap` is still intentionally absent. It must be authored/exported with FAF Map Editor from the exact specification in [MAP_EDITOR_PLAN.md](MAP_EDITOR_PLAN.md). Do not create a text file pretending to be an SCMap.

## Requirements

- Supreme Commander: Forged Alliance with Forged Alliance Forever.
- A current FAF game build compatible with `FAForever/fa`.
- FAF Map Editor for terrain, props, passability and binary `.scmap` export.
- Python 3 for repository contract checks.

The implementation was aligned with current FAF APIs, including:

- `ScenarioUtils.InitializeScenarioArmies()`
- resource markers consumed by `ScenarioUtils.CreateResources()` during sim initialization
- `ScenarioFramework.SetPlayableArea(...)`
- `ScenarioFramework.CreateAreaTrigger(...)`
- `ScenarioFramework.CreateGroupDeathTrigger(...)`
- `ScenarioFramework.PlatoonPatrolChain(...)`
- `ScenarioUtils.ChainToPositions(...)`
- `Objectives.Kill(...)`
- `Objectives.Unknown(...)`
- `ScenarioInfo.Options.Difficulty`

## Installation

The installed directory must be:

```text
operation_twin_spear.v0001
```

Typical Windows path:

```text
C:\Users\<USER>\Documents\My Games\Gas Powered Games\Supreme Commander Forged Alliance\maps\operation_twin_spear.v0001\
```

FAF fallback vault path:

```text
C:\ProgramData\FAForever\user\My Games\Gas Powered Games\Supreme Commander Forged Alliance\maps\operation_twin_spear.v0001\
```

Use the maps directory configured by the FAF client if it differs.

## Stage 2 gameplay flow

```text
UEF insertion
  ↓
8 s intro delay
  ↓
HQ: establish foothold
  ↓
second HQ message
  ↓
Phase 1 begins
  ↓
Scout Patrol
  ↓
Light Land Attack
  ↓
Mixed Land Attack
  ↓
Forward Outpost discovered by area trigger OR max timer
  ↓
PRIMARY: Destroy the Forward Command Post
SECONDARY: Destroy Cybran Radar
  ↓
Air Harassment unless radar disruption cancels it
  ↓
Command Post destroyed
  ↓
~20 s reaction delay
  ↓
Cybran counterattack
  ↓
counterattack reduced to <=30% or destroyed
  ↓
Phase 1 complete
  ↓
AREA_PHASE_2 unlocked
  ↓
Phase 2 placeholder objective
```

Stage 2 deliberately does **not** call victory after Phase 1.

## Player starts and economy

Player 1 starts in the south-west at approximately `(320, 882)`.

Player 2 starts in the south-east at approximately `(704, 882)`.

Each player has:

- four nearby Mass deposits,
- one Hydrocarbon deposit,
- a separate base basin,
- a three-Mass first expansion,
- a natural route toward their corresponding river crossing.

The central expansion has four Mass deposits and one Hydrocarbon. It sits under pressure from the Forward Outpost and becomes the economic reward for clearing the sector.

## Playable-area progression

Phase 1:

```text
AREA_PHASE_1 = RECTANGLE(96, 548, 928, 1024)
```

After Phase 1:

```text
AREA_PHASE_2 = RECTANGLE(64, 352, 960, 1024)
```

Future contracts already exist for:

- `AREA_PHASE_3`
- `AREA_FINALE`

No Fog-of-War hack is used. The mission uses the FAF operation playable-area mechanism.

## Forward Outpost

The Forward Outpost is no longer assembled by scattered `CreateUnit()` calls. It is defined as editable groups in `operation_twin_spear_save.lua`.

### FORWARD_PRODUCTION

- T1 Cybran Land Factory
- T1 Cybran Air Factory
- Normal/Hard: second T1 Land Factory via `FORWARD_PRODUCTION_EXTRA_D2`

### FORWARD_ECONOMY

- 4 × T1 Power Generator
- 3 × T1 Mass Extractor

### FORWARD_DEFENSE

Easy/core:

- 1 × T1 Point Defense
- 1 × T1 Anti-Air Turret

Normal adds:

- 1 × T1 Point Defense

Hard adds:

- 2 × additional T1 Anti-Air Turrets

### FORWARD_COMMAND

The objective target is a Cybran T2 Land Factory HQ model (`urb0201`) renamed to:

```text
Cybran Forward Command Post
```

It acts as the temporary command/communications asset for this mission chapter.

### FORWARD_RADAR

- 1 × T1 Cybran Radar
- optional secondary objective target

### FORWARD_GARRISON

- 4 × Mantis / Assault Bot
- 2 × T1 Mobile AA
- 1 × T1 Land Scout

## Primary objective

Title:

```text
Destroy the Forward Command Post
```

Description:

```text
Destroy the Cybran forward command facility and secure the southern sector.
```

The objective is activated when either:

1. an active player enters `AREA_FORWARD_DISCOVERY`, or
2. the maximum discovery timer expires, or
3. the Command Post is destroyed early.

Early destruction is explicitly handled. If a rush kills the building before assignment, the objective is created as already completed and the mission advances into the counterattack sequence instead of soft-locking.

## Secondary objective

Title:

```text
Destroy Cybran Radar
```

Destroying the radar:

- completes the optional objective,
- sets the radar disruption mission state,
- cancels `Phase1_Wave_04` if it has not launched,
- suppresses later Stage 2 air coordination tied to that wave,
- displays the UEF message that enemy air coordination has been disrupted.

It is not required for Phase 1 completion.

## Wave system

All opening attacks use the reusable `SpawnAttackWave(config)` path.

The wave system:

- uses centralized configs,
- spawns one controlled platoon/composition per wave,
- scales through `GetScaledUnitCount()`,
- routes land forces through FAF marker chains,
- chooses only living/active player targets,
- supports P1/P2 bias without assuming Player1 is always the target,
- can split the air harassment between both players,
- suppresses normal waves after the Forward Command Post dies,
- prevents duplicate non-repeat waves.

### Phase1_Wave_01 — Scout Patrol

Spawn:

- west Forward Outpost spawn

Base composition before scaling:

- 2 × Mantis
- 1 × T1 Mobile AA
- 1 × Land Scout

Target bias:

- P1

Approximate normal timing:

- 2 minutes after Phase 1 begins

### Phase1_Wave_02 — Light Land Attack

Base composition:

- 5 × Mantis
- 1 × T1 Mobile AA

Target bias:

- P1

Approximate normal timing:

- 2.5 minutes after Wave 1

### Phase1_Wave_03 — Mixed Land Attack

Base composition:

- 5 × Mantis
- 2 × T1 Mobile Artillery
- 2 × T1 Mobile AA

Target bias:

- P2 when active, otherwise an available player

Approximate normal timing:

- 2 minutes 40 seconds after Wave 2

### Phase1_Wave_04 — Air Harassment

Base composition:

- 2 × Interceptor
- 1 × T1 Bomber

Behavior:

- split between P1/P2 when both commanders remain active,
- otherwise attack the surviving player,
- cancelled if the radar objective is completed before launch.

### Controlled Forward reinforcements

The outpost receives limited reinforcement groups after the opening minutes.

Rules:

- start after ~5 normal minutes,
- interval ~130 seconds before difficulty/player scaling,
- maximum tracked active force ≈10 solo / 15 co-op,
- no infinite spawn loop,
- stops if Forward production is destroyed,
- stops if the Forward Command Post is destroyed,
- recurring thread exits when Phase 1 ends.

## Counterattack

The Command Post does not instantly complete Phase 1.

After destruction:

1. the primary objective is complete,
2. HQ warns the players,
3. the mission waits roughly 20 seconds before scaling,
4. two reaction groups enter from the north,
5. the phase completes only when the counterattack is destroyed or reduced to 30% of its initial force.

Normal counterattack uses T1 Mantis, artillery and mobile AA.

Hard additionally introduces the first T2 elements:

- Rhino / Heavy Tank (`url0202`)
- T2 mobile flak where configured (`url0205`)

No artificial HP multiplier is used.

## Scaling

### Player count

| Active players | Enemy unit multiplier | Delay multiplier | Resource multiplier |
|---:|---:|---:|---:|
| 1 | 1.00 | 1.00 | 1.00 |
| 2 | 1.50 | 0.90 | 1.25 |

Two-player strength is therefore approximately 1.5× solo, not 2×.

### Difficulty

| Difficulty | Unit multiplier | Delay multiplier | Static-base effect |
|---|---:|---:|---|
| Easy | 0.85 | 1.15 | core defense only, no T2 counter units |
| Normal | 1.00 | 1.00 | second factory + extra PD |
| Hard | 1.20 | 0.85 | extra AA + T2 counterattack additions |

`GetScaledUnitCount()` uses rounded scaling rather than the old unconditional ceiling, so Easy can actually reduce larger groups.

## Attack routing

Primary chains:

- `CHAIN_FORWARD_TO_P1`
- `CHAIN_FORWARD_TO_P2`
- `CHAIN_FORWARD_REINFORCEMENT`
- `CHAIN_FORWARD_GARRISON`

Land waves receive aggressive-move orders through chain positions. Coordinates are not duplicated throughout mission Lua.

## Debug mode

Normal configuration:

```lua
local DEBUG = false
```

Development options:

```lua
local DEBUG_OPTIONS = {
    StartPhase1Immediately = false,
    SkipIntro = false,
}
```

When `DEBUG = true`, the script exposes `OTS_Debug`:

```text
OTS_Debug.SpawnWave(name)
OTS_Debug.CompleteForwardObjective()
OTS_Debug.StartCounterattack()
OTS_Debug.CompletePhase1()
```

These controls are not created in normal gameplay.

Debug timing also uses the existing accelerated delay behavior.

## Logging

Representative output:

```text
[OTS][PHASE1] Starting
[OTS][WAVE] Spawn Phase1_Wave_01
[OTS][WAVE] Target Player1
[OTS][OBJECTIVE] Forward Outpost discovered via area trigger: Player1
[OTS][OBJECTIVE] Forward Command Post destroyed
[OTS][COUNTER] Starting Cybran counterattack
[OTS][COUNTER] Counterattack broken: 4/16 units remain
[OTS][PHASE1] Completed
[OTS][MAP] Expanding playable area: AREA_PHASE_2
[OTS][PHASE2] Placeholder started
```

No recurring system logs every tick.

## Map editing

Use [MAP_EDITOR_PLAN.md](MAP_EDITOR_PLAN.md) as the authoritative handoff for:

- 20 km terrain composition,
- exact approximate X/Z coordinates,
- river geometry,
- crossings,
- terrain-height recommendations,
- resource markers,
- Forward Outpost placement,
- chains,
- playable areas,
- future-sector reservations,
- props and wreck zones,
- pathing acceptance tests.

The checked-in `save.lua` is the scripting contract. If FAF Map Editor regenerates it, preserve all required names and group semantics.

## Project structure

```text
operation_twin_spear.v0001/
├── MAP_EDITOR_PLAN.md
├── README.md
├── operation_twin_spear_operation.lua
├── operation_twin_spear_save.lua
├── operation_twin_spear_scenario.lua
├── operation_twin_spear_script.lua
├── operation_twin_spear.scmap        # manual FAF Map Editor export; not yet present
└── tools/
    └── static_check.py
```

## Static testing

Run:

```bash
python3 tools/static_check.py
```

CI additionally installs Lua and executes `luac -p` for each Lua file.

Static checks cover:

- campaign/co-op scenario shape,
- concrete marker declarations rather than arbitrary name occurrences,
- start resource contract,
- named areas,
- chains,
- Forward Outpost groups,
- required Stage 2 functions,
- wave definitions,
- current FAF API calls,
- known/verified unit blueprint allow-list,
- explicit rejection of the obsolete `url0106` reference,
- guarded Player2 access,
- Phase 2 not calling victory,
- presence of the Map Editor handoff.

## Runtime acceptance checklist

These tests require the real binary map and FAF runtime.

- [ ] TEST 1 — Solo: build space, resources and all opening waves work.
- [ ] TEST 2 — Two players: pressure is distributed and P2-targeted waves do not assume P1.
- [ ] TEST 3 — Discovery: Forward objective appears on entering the discovery area.
- [ ] TEST 4 — Rush: destroying Command Post before discovery does not soft-lock.
- [ ] TEST 5 — Radar: secondary completes and pending air harassment is cancelled.
- [ ] TEST 6 — Counterattack: starts exactly once after the reaction delay.
- [ ] TEST 7 — Phase completion: requires Command Post destruction plus counterattack resolution.
- [ ] TEST 8 — Playable area: completion expands from `AREA_PHASE_1` to `AREA_PHASE_2`.
- [ ] TEST 9 — Solo balance: all P2-preferred attacks fall back to the active player.
- [ ] TEST 10 — Hard: additional units/T2 reaction force remain pathable and performant.
- [ ] Reinforcement cap: tracked Forward reinforcement units do not grow without bound.
- [ ] Factory destruction: destroying Forward production stops recurring reinforcement spawns.
- [ ] Player departure: remaining active commander can continue.

## Not implemented yet

Stage 2 does not implement:

- the Cybran main base,
- full west/east sectors,
- full Phase 2,
- Phase 3,
- finale,
- experimental units,
- final boss,
- naval army,
- strategic missiles,
- full voiced campaign dialogue.
