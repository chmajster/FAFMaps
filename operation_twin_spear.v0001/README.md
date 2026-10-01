# Operation Twin Spear

Stage 4 of a scripted Forged Alliance Forever co-op operation for exactly 1–2 UEF players.

Phase 1 contains the UEF insertion, Forward Outpost and counterattack. Phase 2 contains the independent Western Logistics and Eastern Air Control sectors, convoys, air raids and Central Response. Stage 4 now implements the complete Phase 3: T3 escalation, Long-Range Artillery, Heavy Defense Network, Reinforcement Gateway, strategic secondaries, transport drops, Strategic Response, Emergency Response and transition into a finale placeholder.

The binary `operation_twin_spear.scmap` is intentionally absent. It must be authored/exported with FAF Map Editor from `MAP_EDITOR_PLAN.md`; the repository does not use a fake text SCMap.

## Phase 3 gameplay flow

```text
PHASE 1 — Forward Outpost
          ↓
PHASE 2 — West Logistics + East Air Control
          ↓
AREA_PHASE_3 unlocked
          ↓
PHASE 3
  WEST:   Long-Range Artillery
  CENTER: Heavy Defense Network
  EAST:   Reinforcement Gateway
          ↓
three primary objectives, any order
          ↓
first completed → Strategic Response
          ↓
second completed → Emergency Response
          ↓
all three completed
          ↓
Experimental power-signature tease
          ↓
AREA_FINALE unlocked
          ↓
Destroy the Cybran Command Complex — placeholder only
```

The three primary objectives are order-independent. Destroying an installation stops only the system owned by that installation. Existing Cybran combat units remain on the field and must be defeated normally.

## Phase 3 objectives

Primary:

- Destroy Long-Range Artillery — destroys the T3 Cybran artillery installation and stops scripted bombardment windows.
- Disable the Heavy Defense Network — destroys the control node and stops bounded repair/rebuild and defense-sector generation.
- Destroy the Reinforcement Gateway — destroys the strategic staging facility and stops gateway reinforcements plus new transport drops.

Secondary:

- Destroy Strategic Radar — increases transport-drop interval and reduces scripted air-response coordination.
- Destroy the Cybran Data Core — grants temporary vision over part of the future Main Cybran Base.

## Technology and AI

Phase 3 is the first phase where T3 is a normal combat component. T2 remains the bulk of most forces. The mission uses stock Cybran units and stock weapon damage/health.

Verified late-game blueprints include:

- `urb2302` — Cybran Heavy Artillery Installation.
- `url0303` — Loyalist T3 Siege Assault Bot.
- `url0304` — Cybran T3 Mobile Heavy Artillery.
- `urb2304` — T3 SAM.
- `urb0301` / `urb0302` — T3 land/air factories.
- `urb0304` — Cybran Quantum Gateway.
- `ura0303` / `ura0304` — T3 air-superiority fighter / strategic bomber.
- `ura0104` — T2 Cybran transport.

No Experimental unit is spawned in Stage 4.

## Artillery behavior

The artillery thread controls firing windows and difficulty-dependent cooldown only. Target acquisition remains the normal FAF artillery behavior. The script does not query the player army to snipe ACUs or structures and does not alter artillery damage.

Cooldown baseline:

- Easy: 105 s.
- Normal: 80 s.
- Hard: 60 s.

Each firing window lasts about 22 s. Destroying the artillery stops the thread immediately.

## Heavy Defense Network

The center is the heaviest direct land front so far. Static defense combines T2 point defense, T3 AA, tactical missile defense and shields. Normal/Hard add stronger shield/static layers and T3 production.

Defense engineers have a finite rebuild budget:

- Easy: 1 rebuild.
- Normal: 2 rebuilds.
- Hard: 3 rebuilds.

Destroying the Control Node stops repair/rebuild logic. Existing turrets and combat units are not deleted.

## Reinforcement Gateway

The Gateway system rotates mixed heavy-land, siege and late-T3 reinforcement packages. Hard receives denser T3 support but no Experimental.

At least one physical transport drop is scheduled during Phase 3. The drop sequence uses real Cybran transports: cargo is spawned, loaded, routed along map chains, unloaded on a flank/rear position and then given combat orders.

## Attack Director and scaling

The existing wave architecture is retained. Phase 3 adds a light director rather than a reactive counter-AI. It considers current phase, available strategic sectors, player count, difficulty and active mission-AI unit caps.

Active caps by difficulty before co-op scaling:

| Difficulty | Land | Air | Reinforcement |
|---|---:|---:|---:|
| Easy | 30 | 10 | 18 |
| Normal | 42 | 16 | 28 |
| Hard | 54 | 24 | 38 |

Co-op applies approximately 1.45–1.50× to Phase 3 caps. Solo gets longer attack/drop intervals. Target selection tracks the previously pressured player and distributes repeated attacks rather than permanently preferring Player1.

## Phase 2 hardening retained

Stage 4 keeps the Phase 2 hardening already present on `main`:

- Phase 2 target selection balances accumulated pressure between active players.
- West land waves can route to either player via `CHAIN_WEST_ATTACK` or `CHAIN_WEST_ATTACK_TO_P2`.
- Central Response can route to either player via `CHAIN_CENTRAL_RESPONSE` or `CHAIN_CENTRAL_RESPONSE_P2`.
- West, East, convoy and Central Response caps are checked against the projected scaled wave size before spawning.
- Surviving convoy units are transferred into the West active-force pool so they remain covered by the same cap.
- Solo Phase 2 uses staggered starts and longer recurring intervals to avoid simultaneous two-front pressure.
- Destroying a Phase 2 command structure closes its recurring subsystem and clears its thread bookkeeping.
- Hard Phase 2 includes Cybran mobile stealth support.

## Playable-area progression

- `AREA_PHASE_1 = RECTANGLE(96, 548, 928, 1024)`
- `AREA_PHASE_2 = RECTANGLE(64, 352, 960, 1024)`
- `AREA_PHASE_3 = RECTANGLE(32, 176, 992, 1024)`
- `AREA_PHASE_3_WEST = RECTANGLE(32, 176, 400, 352)`
- `AREA_PHASE_3_CENTER = RECTANGLE(376, 176, 648, 352)`
- `AREA_PHASE_3_EAST = RECTANGLE(624, 176, 992, 352)`
- `AREA_FINALE = RECTANGLE(0, 0, 1024, 1024)` — locked until `CompletePhase3()`.

## Phase 3 economy

Three new forward expansion zones exist:

- West: 3 Mass.
- Center: 4 Mass + 1 Hydro; intended forward operating base and strongest economic reward.
- East: 3 Mass.

This is sufficient to support T3 progression without turning the finale into unlimited mass spam.

## Debug controls

When `DEBUG = true`, `OTS_Debug` exposes:

- `StartPhase3()`
- `CompleteArtilleryObjective()`
- `CompleteDefenseObjective()`
- `CompleteGatewayObjective()`
- `TriggerStrategicResponse()`
- `TriggerEmergencyResponse()`
- `SpawnTransportDrop()`
- `SpawnPhase3Attack()`
- `CompletePhase3()`
- `UnlockFinaleArea()`

Earlier Phase 1/2 debug helpers remain available.

## Static verification

Run:

```bash
python3 operation_twin_spear.v0001/tools/static_check.py
```

The checker validates markers, areas, chains, logical groups, verified blueprints, Phase 3 state, objective-order independence, early-destruction reconciliation, once-only responses, transport contract, unit caps, cleanup and non-victory finale transition. If `luac` exists, all Lua files are syntax-checked as well.

## Runtime acceptance checklist

The following dynamic tests require the real binary map and FAF runtime:

- [ ] TEST 1 — Artillery starts firing; destroying it stops bombardment.
- [ ] TEST 2 — Defense repair/rebuild works; destroying the Control Node stops it.
- [ ] TEST 3 — Gateway reinforcements stop after Gateway destruction.
- [ ] TEST 4 — Transport spawns, loads, follows its route, unloads and cargo receives orders.
- [ ] TEST 5 — Objective order A→B→C completes Phase 3.
- [ ] TEST 6 — Objective order C→A→B completes Phase 3.
- [ ] TEST 7 — Near-simultaneous destruction does not duplicate response/completion.
- [ ] TEST 8 — Strategic Response triggers exactly once after the first primary.
- [ ] TEST 9 — Emergency Response triggers exactly once after the second primary.
- [ ] TEST 10 — Early target destruction reconciles correctly on Phase 3 start.
- [ ] TEST 11 — Solo cadence does not require three simultaneous defensive fronts.
- [ ] TEST 12 — Co-op pressure is distributed across active players.
- [ ] TEST 13 — Hard T3 pressure remains inside active-unit caps.
- [ ] TEST 14 — all three primaries unlock `AREA_FINALE`.
- [ ] TEST 15 — all Phase 3 scheduler/repair/reinforcement threads are stopped on completion.

## Not implemented yet

Stage 4 intentionally does not implement the final Main Cybran Base assault, Experimental boss, strategic nuclear war, final enemy ACU, final survival/escape sequence, outro or ending cinematics. The Main Base preview contract and final primary placeholder only prepare the next stage.
