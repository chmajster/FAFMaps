# Operation Twin Spear

Stage 3 of a scripted Forged Alliance Forever co-op operation for exactly 1–2 UEF players.

Stage 1 established the mission framework. Stage 2 implemented the southern opening chapter. Stage 3 implements the complete Phase 2: independent Western Logistics and Eastern Air Control fronts, convoy interception, radar disruption, adaptive reinforcement, Central Response, controlled engineer support, performance caps and the transition into a non-victory Phase 3 placeholder.

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

## Stage 3 / Phase 2 gameplay flow

```text
Phase 1 complete
  ↓
AREA_PHASE_2 unlocked
  ↓
PHASE 2 starts
  ↓
PRIMARY A: Destroy Western Logistics Base
PRIMARY B: Destroy Eastern Air Control Base
  ↓                         ↓
West land pressure           East air pressure
Convoys                      Air patrols / raids
SECONDARY: intercept         SECONDARY: destroy
supply convoys               radar network
  \                         /
   \                       /
    first primary objective completed
                ↓
       CYBRAN CENTRAL RESPONSE
                ↓
 moderate reinforcement to surviving sector
                ↓
       second primary objective completed
                ↓
        PHASE 2 complete
                ↓
        AREA_PHASE_3 unlocked
                ↓
  Phase 3 placeholder objective
```

West and East are independent. Solo may clear them sequentially; two players may split fronts or attack together. The mission does not require a fixed P1/P2 assignment. Phase 2 attack targeting balances accumulated player pressure, and West land groups have routes to either active player rather than treating P1 as the mandatory western target.
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

Two-player strength is therefore approximately 1.5× solo, not 2×. Solo additionally staggers Phase 2 pressure: East air raids/patrols start later and West/East recurring intervals are lengthened so the player is not forced to defend two fronts at the same instant.

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
[OTS][PHASE2] Starting
[OTS][WEST] Logistics Base active
[OTS][EAST] Air Control Base active
[OTS][CONVOY] West convoy spawned
[OTS][AIR] BOMBER_STRIKE launched
[OTS][OBJECTIVE] West completed
[OTS][RESPONSE] Central response triggered
[OTS][OBJECTIVE] East completed
[OTS][PHASE2] Both sectors neutralized
[OTS][MAP] Expanding to AREA_PHASE_3
[OTS][PHASE3] Placeholder started
```

No recurring system logs every tick.

## Phase 2 performance guards

West attacks, East air groups, supply convoys and the Central Response use difficulty/player-count active-unit limits. Before spawning, the script calculates the scaled size of the requested composition and suppresses the spawn if the projected active pool would exceed its cap; it does not merely check the count before the wave. Convoy survivors that reach the Western Logistics Base are transferred into the West active-force pool so they remain covered by the same cap.

Destroying the Western command resolves outstanding convoy bookkeeping and stops new convoy/land reinforcement loops. Destroying the Eastern command stops new air-raid and patrol generation. Existing units remain on the map.

## Map editing

Use [MAP_EDITOR_PLAN.md](MAP_EDITOR_PLAN.md) as the authoritative handoff for:

- 20 km terrain composition,
- exact approximate X/Z coordinates,
- river geometry,
- crossings,
- terrain-height recommendations,
- resource markers,
- Forward Outpost placement,
- Western Logistics Base and Eastern Air Control Base footprints,
- Phase 2 central valley, ramps and chokepoints,
- convoy, land-attack, air-patrol and Central Response chains,
- Phase 2 resource expansion,
- playable areas,
- future main-base reservations,
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
- Western/Eastern Phase 2 groups,
- required Stage 3 / Phase 2 lifecycle functions,
- reusable Phase 1 and Phase 2 wave definitions,
- current FAF API calls,
- known/verified unit blueprint allow-list,
- explicit rejection of the legacy forbidden `url0106` reference,
- guarded Player2 access,
- central `MissionState.Phase2` fields,
- two-sector completion and non-victory Phase 3 transition,
- presence of the Map Editor handoff.

## Runtime acceptance checklist

These tests require the real binary map and FAF runtime.

- [ ] TEST 1 — Solo West first: West completes; East remains active.
- [ ] TEST 2 — Solo East first: East completes; West remains active.
- [ ] TEST 3 — Co-op simultaneous: both callbacks resolve without race conditions.
- [ ] TEST 4 — Central Response: triggers exactly once after the first primary objective.
- [ ] TEST 5 — West convoy arrival: arrival is detected and the base receives a bounded defensive bonus.
- [ ] TEST 6 — Convoy destroyed: no arrival bonus; destruction counter increments once.
- [ ] TEST 7 — East radar secondary: all radars destroyed reduces raid cadence and patrol coverage.
- [ ] TEST 8 — West early destruction: destroying the command before Phase 2 objective assignment does not soft-lock.
- [ ] TEST 9 — East early destruction: same early-destruction guarantee.
- [ ] TEST 10 — Phase completion: requires both `WestCompleted` and `EastCompleted`.
- [ ] TEST 11 — Threads: West production/convoys and East air/patrol generators stop after their sector/phase ends.
- [ ] TEST 12 — Solo balance: no simultaneous two-front defense requirement.
- [ ] TEST 13 — Co-op scaling: two players increase pressure sub-linearly, not 2×.
- [ ] TEST 14 — Performance: active West/East/convoy/Central Response unit caps hold.
- [ ] Engineer support: repairs/patrol behavior never rebuilds objective structures.
- [ ] Phase 3 transition: `AREA_PHASE_3` opens and no victory is fired.

## Not implemented yet

Stage 3 does not implement:

- the final Cybran main-base assault,
- full Phase 3 mission logic,
- experimental units,
- strategic nukes,
- final boss,
- full naval war,
- final assault/outro,
- full voiced campaign dialogue.

The Phase 3 entry exists only as terrain expansion, transition dialogue and a placeholder primary objective.
