# Operation Twin Spear — MAP_EDITOR_PLAN

Stage 4 map-authoring specification for the complete Phase 3 of a 20 km × 20 km FAF co-op campaign map. It retains all Phase 1–2 terrain and adds the northern strategic defense belt: Long-Range Artillery, Heavy Defense Network, Reinforcement Gateway, forward-operating space and the still-locked finale boundary.

The Lua/save contract uses a 1024 × 1024 map coordinate space:

- X = 0 west, X = 1024 east
- Z = 0 north, Z = 1024 south
- NORTH contains the future Cybran main base
- SOUTH contains the UEF insertion zone

The binary `operation_twin_spear.scmap` must be created in FAF Map Editor. Do not replace it with a text placeholder.

## 1. Global layout

```text
                         NORTH (Z ~= 0)

                    [ CYBRAN MAIN BASE ]
                         (512,118)
                              |
                     [ DEFENSE LINE ]
                         (512,230)
                         /          \
                        /            \
          [WEST SECTOR]              [EAST SECTOR]
           (300,300)                  (724,300)
               |                          |
       [WEST OUTPOST]              [EAST OUTPOST]
          (310,430)                   (714,430)
                 \                    /
                  \                  /
                   [ CENTRAL PASS ]
                     (512,470-540)
                           |
                 [ FORWARD OUTPOST ]
                      (512,606)
                           |
                ======= RIVER =======
                    Z ~= 700-740
                 /        |         \
        CROSSING_WEST   CENTER    CROSSING_EAST
          (410,720)   (512,732)     (614,720)
              |                         |
        [P1 EXPANSION]             [P2 EXPANSION]
          (382,798)                  (642,798)
              |                         |
         [ PLAYER 1 ]               [ PLAYER 2 ]
          (320,882)                  (704,882)

                         SOUTH (Z ~= 1024)
```

Stage 2 implemented the southern start zone, river, first central expansion and Forward Outpost. Stage 3 now activates the mid-west, mid-east and central valley for Phase 2. Only the far-north defense line and main Cybran base remain reserved for later stages.

## 2. Terrain concept

This is a campaign battlefield, not a symmetric skirmish arena.

### South-west player basin

Approximate bounds:

- X 225–430
- Z 805–980
- recommended plateau height: 20–25
- base core around `PLAYER_1_START (320,882)`

Use low ridgelines on the west/north-west edges. Leave at least 110–130 map units of practical building space around the ACU start. The natural exit should bend north-east toward `P1_EXPANSION_01` and `CROSSING_WEST`.

### South-east player basin

Approximate bounds:

- X 594–799
- Z 805–980
- recommended plateau height: 20–25
- base core around `PLAYER_2_START (704,882)`

Mirror the strategic function, not the exact geometry. Use different cliff shapes so the two bases do not look like mirrored PvP spawns.

### Divider between the players

Between X 455–570, Z 820–980 create:

- a low rocky ridge / broken elevation,
- 8–20 map-unit wide local gaps for engineers and units,
- no invisible walls,
- enough cross-access that one player can reinforce the other.

The divider should discourage one giant shared base while preserving co-op support.

### River valley

Primary river band:

- Z 690–742
- west bank bends around X 360–460
- east bank bends around X 564–664
- recommended water surface / valley floor: 7–12
- surrounding banks: 18–26

Do not make the river a uniform straight line. Use a shallow S-curve and wider central water pocket around X 480–550.

Required crossings:

- `CROSSING_WEST (410,720)`: primary P1 land crossing, 55–70 units wide
- `CROSSING_EAST (614,720)`: primary P2 land crossing, 55–70 units wide
- `CROSSING_CENTER_OPTIONAL (512,732)`: narrower secondary ford/causeway, 35–45 units wide

The rest of the river should support amphibious movement. Keep enough water depth/width for later limited naval or amphibious scripting, but Stage 2 contains no naval army.

### Central expansion shelf

Approximate bounds:

- X 450–574
- Z 642–708
- height: 18–23
- center: `CENTRAL_EXPANSION (512,674)`

This is the economic reward zone contested by the Forward Outpost. Give it enough flat ground for a small forward base, not a second full-size main base.

### Forward Outpost plateau

Approximate bounds:

- X 440–584
- Z 548–670
- height: 26–32
- center: `FORWARD_OUTPOST_CENTER (512,606)`

Approach geometry:

- south-west ramp/choke: X 450–485, Z 650–680
- south-east ramp/choke: X 539–574, Z 650–680
- optional narrower central approach from X 500–524

Use cliffs or steep slopes around parts of the east/west sides so players naturally attack from the crossings and southern approaches. Each main approach must remain wide enough for 20–30 unit land formations.

### Phase 2 central valley

Between Z 352–548 create a broad, traversable valley linking both flanks. The central route is not a full enemy base. It is a movement corridor, battle space and optional economic expansion around `PHASE2_CENTRAL_EXPANSION (512,470)`.

Recommended terrain:

- valley floor: height 18–24,
- shallow ridges west/east: 28–36,
- at least 140–180 map units of usable combat width,
- no one-way labyrinth,
- two lateral connectors so armies can transfer West ↔ Center ↔ East,
- clear lane from `CENTRAL_RESPONSE_SPAWN` to `CENTRAL_RESPONSE_TARGET`.

### Western Logistics Base terrain

Base footprint:

- X 225–375
- Z 370–495
- center: `WEST_BASE_CENTER (300,420)`
- recommended base plateau: height 28–34

Keep the western terrain relatively open. Provide two broad southern approaches and one narrower central connector. The supply route from `WEST_SUPPLY_ENTRY (250,354)` to `WEST_SUPPLY_EXIT (300,410)` must be land-passable for engineers and escorted formations. Avoid steep ramps on `CHAIN_WEST_SUPPLY`.

### Eastern Air Control Base terrain

Base footprint:

- X 650–800
- Z 360–500
- center: `EAST_BASE_CENTER (724,420)`
- recommended base plateau: height 32–40

Use more broken terrain than West: ridges and elevated shelves around the airfield, but keep factory exits and AA arcs unobstructed. At least two land approaches must exist so the sector cannot become a single choke. Air patrol markers require unobstructed aerial paths.

### Far-north terrain reservations

Do not build the final main base yet. Shape only broad terrain volumes around:

- `WEST_SECTOR_FUTURE (300,300)`
- `EAST_SECTOR_FUTURE (724,300)`
- `DEFENSE_LINE_CENTER (512,230)`
- `CYBRAN_MAIN_BASE (512,118)`

Recommended heights can rise gradually into 35–50, with valleys preserved for Phase 3 attack routes.

## 3. Playable areas

| Area | Rectangle X0,Z0,X1,Z1 | Phase | Purpose |
|---|---|---|---|
| `AREA_PHASE_1` | 96,548,928,1024 | Phase 1 | South ~46% plus Forward Outpost |
| `AREA_PHASE_2` | 64,352,960,1024 | Phase 2 | Unified playable rectangle for West + East + Center |
| `AREA_PHASE_2_WEST` | 64,352,480,548 | Phase 2 | Western Logistics sector authoring/reference area |
| `AREA_PHASE_2_EAST` | 544,352,960,548 | Phase 2 | Eastern Air Control sector authoring/reference area |
| `AREA_PHASE_2_CENTER` | 420,352,604,548 | Phase 2 | Central valley authoring/reference area |
| `AREA_PHASE_3` | 32,176,992,1024 | Phase 3 placeholder | Unlock far-northern approach after both Phase 2 objectives |
| `AREA_FINALE` | 0,0,1024,1024 | Future | Full map |
| `AREA_FORWARD_DISCOVERY` | 376,540,648,710 | Phase 1 | Objective discovery trigger |
| `AREA_FORWARD_OUTPOST` | 440,548,584,670 | Phase 1 | Forward Outpost footprint |
| `AREA_P1_START` | 240,808,410,970 | Phase 1 | P1 base basin |
| `AREA_P2_START` | 614,808,784,970 | Phase 1 | P2 base basin |

The script calls `ScenarioFramework.SetPlayableArea('AREA_PHASE_1', false)` on start, expands to the unified `AREA_PHASE_2` after Phase 1, and only expands to `AREA_PHASE_3` after both Phase 2 primary objectives are complete. The West/East/Center sub-areas are authoring/reference partitions inside the unified Phase 2 rectangle.

## 4. Marker table

| Name | Type | X | Z | Phase | Purpose |
|---|---|---:|---:|---|---|
| `PLAYER_1_START` | Blank/Army anchor | 320 | 882 | 1 | P1 ACU start |
| `PLAYER_2_START` | Blank/Army anchor | 704 | 882 | 1 | P2 ACU start |
| `P1_ATTACK_TARGET` | Blank | 338 | 846 | 1 | AI target near P1 base |
| `P2_ATTACK_TARGET` | Blank | 686 | 846 | 1 | AI target near P2 base |
| `P1_EXPANSION_01` | Blank | 382 | 798 | 1 | P1 first expansion |
| `P2_EXPANSION_01` | Blank | 642 | 798 | 1 | P2 first expansion |
| `CENTRAL_EXPANSION` | Blank | 512 | 674 | 1 | Reward expansion |
| `CROSSING_WEST` | Blank | 410 | 720 | 1 | Main western river crossing |
| `CROSSING_EAST` | Blank | 614 | 720 | 1 | Main eastern river crossing |
| `CROSSING_CENTER_OPTIONAL` | Blank | 512 | 732 | 1 | Optional central crossing |
| `FORWARD_OUTPOST_CENTER` | Blank | 512 | 606 | 1 | Forward base center |
| `FORWARD_COMMAND_POST` | Blank | 512 | 568 | 1 | Primary objective anchor |
| `FORWARD_RADAR` | Blank | 558 | 580 | 1 | Secondary objective anchor |
| `CYBRAN_FORWARD_SPAWN_WEST` | Blank | 452 | 578 | 1 | West attack spawn |
| `CYBRAN_FORWARD_SPAWN_EAST` | Blank | 572 | 578 | 1 | East attack spawn |
| `ATTACK_WEST_01` | Blank | 444 | 634 | 1 | West route node |
| `ATTACK_WEST_02` | Blank | 414 | 682 | 1 | West route node |
| `ATTACK_WEST_03` | Blank | 382 | 770 | 1 | West route node |
| `ATTACK_EAST_01` | Blank | 580 | 634 | 1 | East route node |
| `ATTACK_EAST_02` | Blank | 610 | 682 | 1 | East route node |
| `ATTACK_EAST_03` | Blank | 642 | 770 | 1 | East route node |
| `REINFORCEMENT_01` | Blank | 512 | 470 | 1/2 | North reinforcement entry |
| `REINFORCEMENT_02` | Blank | 512 | 522 | 1/2 | Reinforcement route |
| `WEST_OUTPOST_FUTURE` | Blank | 310 | 430 | future | West outpost reservation |
| `EAST_OUTPOST_FUTURE` | Blank | 714 | 430 | future | East outpost reservation |
| `WEST_SECTOR_FUTURE` | Blank | 300 | 300 | future | West sector |
| `EAST_SECTOR_FUTURE` | Blank | 724 | 300 | future | East sector |
| `DEFENSE_LINE_CENTER` | Blank | 512 | 230 | future | Main defense line |
| `CYBRAN_MAIN_BASE` | Blank | 512 | 118 | future | Main base reservation |

Stage 1 alias markers remain in `save.lua` for compatibility. Do not delete them until later migrations deliberately remove them.

### Phase 2 marker additions

| Name | Type | X | Z | Phase | Purpose |
|---|---|---:|---:|---|---|
| `WEST_BASE_CENTER` | Blank | 300 | 420 | 2 | Western Logistics Base center |
| `WEST_LOGISTICS_COMMAND` | Blank | 300 | 392 | 2 | West primary objective anchor |
| `WEST_FACTORY_01` | Blank | 272 | 426 | 2 | West factory footprint |
| `WEST_FACTORY_02` | Blank | 328 | 426 | 2 | West factory footprint |
| `WEST_SUPPLY_ENTRY` | Blank | 250 | 354 | 2 | Convoy entry from north |
| `WEST_SUPPLY_01` | Blank | 258 | 372 | 2 | Convoy route node |
| `WEST_SUPPLY_02` | Blank | 278 | 394 | 2 | Convoy route node |
| `WEST_SUPPLY_EXIT` | Blank | 300 | 410 | 2 | Convoy arrival / bonus trigger |
| `WEST_ATTACK_01` | Blank | 320 | 448 | 2 | West attack route node |
| `WEST_ATTACK_02` | Blank | 350 | 492 | 2 | West attack route node |
| `WEST_ATTACK_03` | Blank | 390 | 540 | 2 | West attack route node |
| `WEST_PATROL_01` | Blank | 252 | 414 | 2 | West base patrol / engineer node |
| `WEST_PATROL_02` | Blank | 300 | 370 | 2 | West base patrol / engineer node |
| `WEST_PATROL_03` | Blank | 348 | 414 | 2 | West base patrol / engineer node |
| `WEST_PATROL_04` | Blank | 300 | 486 | 2 | West base patrol / engineer node |
| `EAST_BASE_CENTER` | Blank | 724 | 420 | 2 | Eastern Air Control Base center |
| `EAST_AIR_CONTROL_COMMAND` | Blank | 724 | 392 | 2 | East primary objective anchor |
| `EAST_AIR_FACTORY_01` | Blank | 690 | 430 | 2 | East air-factory footprint |
| `EAST_AIR_FACTORY_02` | Blank | 758 | 430 | 2 | East air-factory footprint |
| `EAST_AIR_ATTACK_SPAWN` | Blank | 724 | 442 | 2 | Air raid / patrol spawn |
| `EAST_RADAR_01` | Blank | 664 | 388 | 2 | Radar network objective |
| `EAST_RADAR_02` | Blank | 724 | 368 | 2 | Radar network objective |
| `EAST_RADAR_03` | Blank | 784 | 388 | 2 | Radar network objective |
| `EAST_PATROL_01A` | Blank | 620 | 380 | 2 | East air patrol route 01 |
| `EAST_PATROL_01B` | Blank | 690 | 352 | 2 | East air patrol route 01 |
| `EAST_PATROL_01C` | Blank | 790 | 374 | 2 | East air patrol route 01 |
| `EAST_PATROL_01D` | Blank | 760 | 470 | 2 | East air patrol route 01 |
| `EAST_PATROL_02A` | Blank | 640 | 458 | 2 | East air patrol route 02 |
| `EAST_PATROL_02B` | Blank | 710 | 500 | 2 | East air patrol route 02 |
| `EAST_PATROL_02C` | Blank | 824 | 456 | 2 | East air patrol route 02 |
| `EAST_PATROL_02D` | Blank | 806 | 390 | 2 | East air patrol route 02 |
| `EAST_BASE_PATROL_01` | Blank | 670 | 420 | 2 | East base patrol / engineer node |
| `EAST_BASE_PATROL_02` | Blank | 724 | 360 | 2 | East base patrol / engineer node |
| `EAST_BASE_PATROL_03` | Blank | 778 | 420 | 2 | East base patrol / engineer node |
| `EAST_BASE_PATROL_04` | Blank | 724 | 492 | 2 | East base patrol / engineer node |
| `PHASE2_CENTRAL_EXPANSION` | Blank | 512 | 470 | 2 | Optional Phase 2 forward-base location |
| `CENTRAL_RESPONSE_SPAWN` | Blank | 512 | 354 | 2 | Central Response spawn |
| `CENTRAL_RESPONSE_TARGET` | Blank | 512 | 520 | 2 | Central Response staging/engagement point |
| `CENTRAL_FLANK_01` | Blank | 570 | 388 | 2 | Hard/co-op Central Response flank |
| `CENTRAL_FLANK_02` | Blank | 590 | 460 | 2 | Hard/co-op Central Response flank |
| `CENTRAL_AIR_PATROL_01` | Blank | 450 | 410 | 2 | Central air patrol loop |
| `CENTRAL_AIR_PATROL_02` | Blank | 512 | 370 | 2 | Central air patrol loop |
| `CENTRAL_AIR_PATROL_03` | Blank | 574 | 410 | 2 | Central air patrol loop |
| `CENTRAL_AIR_PATROL_04` | Blank | 512 | 510 | 2 | Central air patrol loop |
| `PHASE2_CENTER_MASS_01` | Mass | 474 | 474 | 2 | Central expansion economy |
| `PHASE2_CENTER_MASS_02` | Mass | 498 | 454 | 2 | Central expansion economy |
| `PHASE2_CENTER_MASS_03` | Mass | 526 | 454 | 2 | Central expansion economy |
| `PHASE2_CENTER_MASS_04` | Mass | 550 | 474 | 2 | Central expansion economy |
| `PHASE2_CENTER_HYDRO_01` | Hydrocarbon | 512 | 494 | 2 | Central expansion economy |
| `WEST_MASS_01` | Mass | 252 | 430 | 2 | Western base occupied extractor point |
| `WEST_MASS_02` | Mass | 348 | 430 | 2 | Western base occupied extractor point |
| `WEST_MASS_03` | Mass | 300 | 478 | 2 | Western base occupied extractor point |
| `EAST_MASS_01` | Mass | 676 | 438 | 2 | Eastern base occupied extractor point |
| `EAST_MASS_02` | Mass | 772 | 438 | 2 | Eastern base occupied extractor point |
| `EAST_MASS_03` | Mass | 724 | 484 | 2 | Eastern base occupied extractor point |

All Phase 2 markers above are part of the handoff contract. Coordinates may be adjusted in FAF Map Editor only if the corresponding route/base remains semantically equivalent and `save.lua`, Lua references and this table are updated together.


## 5. Resource markers

### Player 1 start

| Name | Type | X | Z |
|---|---|---:|---:|
| `P1_MASS_01` | Mass | 294 | 862 |
| `P1_MASS_02` | Mass | 320 | 842 |
| `P1_MASS_03` | Mass | 346 | 862 |
| `P1_MASS_04` | Mass | 320 | 908 |
| `P1_HYDRO_01` | Hydrocarbon | 274 | 914 |

### Player 2 start

| Name | Type | X | Z |
|---|---|---:|---:|
| `P2_MASS_01` | Mass | 678 | 862 |
| `P2_MASS_02` | Mass | 704 | 842 |
| `P2_MASS_03` | Mass | 730 | 862 |
| `P2_MASS_04` | Mass | 704 | 908 |
| `P2_HYDRO_01` | Hydrocarbon | 750 | 914 |

### First expansions

P1:

- `P1_EXP_MASS_01 (360,790)`
- `P1_EXP_MASS_02 (382,774)`
- `P1_EXP_MASS_03 (404,790)`

P2:

- `P2_EXP_MASS_01 (620,790)`
- `P2_EXP_MASS_02 (642,774)`
- `P2_EXP_MASS_03 (664,790)`

### Central reward expansion

- `CENTRAL_MASS_01 (476,680)`
- `CENTRAL_MASS_02 (500,662)`
- `CENTRAL_MASS_03 (524,662)`
- `CENTRAL_MASS_04 (548,680)`
- `CENTRAL_HYDRO_01 (512,700)`

### Forward Outpost occupied economy

- `OUTPOST_MASS_01 (464,618)`
- `OUTPOST_MASS_02 (560,618)`
- `OUTPOST_MASS_03 (512,646)`

These deposits are initially occupied by Cybran extractors. Clearing the outpost converts the area into usable forward economy.

### Phase 2 central expansion

- `PHASE2_CENTER_MASS_01 (474,474)`
- `PHASE2_CENTER_MASS_02 (498,454)`
- `PHASE2_CENTER_MASS_03 (526,454)`
- `PHASE2_CENTER_MASS_04 (550,474)`
- `PHASE2_CENTER_HYDRO_01 (512,494)`

### Phase 2 support-base economy

West:

- `WEST_MASS_01 (252,430)`
- `WEST_MASS_02 (348,430)`
- `WEST_MASS_03 (300,478)`

East:

- `EAST_MASS_01 (676,438)`
- `EAST_MASS_02 (772,438)`
- `EAST_MASS_03 (724,484)`

These base economy points begin occupied by Cybran extractors and become normal map resources after the structures are destroyed.


## 6. Chains

### CHAIN_FORWARD_TO_P1

```text
CYBRAN_FORWARD_SPAWN_WEST
 -> ATTACK_WEST_01
 -> ATTACK_WEST_02
 -> CROSSING_WEST
 -> ATTACK_WEST_03
 -> P1_ATTACK_TARGET
```

### CHAIN_FORWARD_TO_P2

```text
CYBRAN_FORWARD_SPAWN_EAST
 -> ATTACK_EAST_01
 -> ATTACK_EAST_02
 -> CROSSING_EAST
 -> ATTACK_EAST_03
 -> P2_ATTACK_TARGET
```

### CHAIN_FORWARD_REINFORCEMENT

```text
REINFORCEMENT_01
 -> REINFORCEMENT_02
 -> FORWARD_OUTPOST_CENTER
```

### CHAIN_FORWARD_GARRISON

```text
CYBRAN_FORWARD_SPAWN_WEST
 -> FORWARD_COMMAND_POST
 -> CYBRAN_FORWARD_SPAWN_EAST
 -> FORWARD_OUTPOST_CENTER
```

Check every chain with FAF Map Editor path visualization. Land routes must not cross cliffs, deep water or impassable prop clusters.

### CHAIN_WEST_SUPPLY

```text
WEST_SUPPLY_ENTRY
 -> WEST_SUPPLY_01
 -> WEST_SUPPLY_02
 -> WEST_SUPPLY_EXIT
```

Must support escorted engineer convoys without single-file pathing.

### CHAIN_WEST_ATTACK

```text
WEST_ATTACK_01
 -> WEST_ATTACK_02
 -> WEST_ATTACK_03
 -> CROSSING_WEST
 -> P1_ATTACK_TARGET
```

### CHAIN_WEST_ATTACK_TO_P2

Cross-player route used when pressure balancing selects Player2 instead of assuming that West must always attack Player1:

```text
WEST_ATTACK_01
 -> WEST_ATTACK_02
 -> WEST_ATTACK_03
 -> CENTRAL_RESPONSE_TARGET
 -> CROSSING_EAST
 -> P2_ATTACK_TARGET
```

This route must stay broad and traversable by medium/large land formations. It is deliberately a transfer through the central valley rather than a hard P1=West assignment.

### CHAIN_EAST_AIR_PATROL_01 / 02

Two independent loops around the East sector. The radar-secondary reward reduces the active route set to route 01 only. Destroying `EAST_AIR_CONTROL_COMMAND` stops new patrol generation completely.

### CHAIN_CENTER_AIR_PATROL

Wide loop over the central valley. Keep it clear of tall terrain spikes that would cause visually poor low-altitude routing.

### CHAIN_CENTRAL_RESPONSE

```text
CENTRAL_RESPONSE_SPAWN
 -> CENTRAL_RESPONSE_TARGET
 -> CROSSING_CENTER_OPTIONAL
 -> P1_ATTACK_TARGET
```

### CHAIN_CENTRAL_RESPONSE_P2

Alternate main-response route when Player2 is the lower-pressure valid target:

```text
CENTRAL_RESPONSE_SPAWN
 -> CENTRAL_RESPONSE_TARGET
 -> CROSSING_EAST
 -> P2_ATTACK_TARGET
```

### CHAIN_CENTRAL_FLANK

Hard/co-op flank route:

```text
CENTRAL_RESPONSE_SPAWN
 -> CENTRAL_FLANK_01
 -> CENTRAL_FLANK_02
 -> CROSSING_EAST
 -> P2_ATTACK_TARGET
```


## 7. Forward Outpost unit layout

All units are represented as editable groups in `operation_twin_spear_save.lua`.

### FORWARD_PRODUCTION

- 1 × Cybran T1 Land Factory — `urb0101`
- 1 × Cybran T1 Air Factory — `urb0102`

### FORWARD_PRODUCTION_EXTRA_D2

Normal and Hard only:

- 1 × additional Cybran T1 Land Factory — `urb0101`

### FORWARD_ECONOMY

- 4 × T1 Power Generator — `urb1101`
- 3 × T1 Mass Extractor — `urb1103`

### FORWARD_DEFENSE

Core / Easy:

- 1 × T1 Point Defense — `urb2101`
- 1 × T1 Anti-Air Turret — `urb2104`

Normal adds:

- 1 × T1 Point Defense

Hard adds:

- 2 × additional T1 Anti-Air Turrets

### FORWARD_COMMAND

- 1 × Cybran T2 Land Factory HQ model — `urb0201`
- custom mission name: **Cybran Forward Command Post**
- primary objective target
- not capturable or reclaimable

The T2 HQ model is intentionally reused as a command/communications facility until a custom or more appropriate mission asset is introduced. It keeps the outpost visually at an early-T2 ceiling without introducing T3 structures.

### FORWARD_RADAR

- 1 × T1 Radar — `urb3101`
- secondary objective target
- destroying it cancels/suppresses the scripted Air Harassment wave if it has not launched

### FORWARD_GARRISON

- 4 × Mantis / Assault Bot — `url0107`
- 2 × T1 Mobile AA — `url0104`
- 1 × T1 Land Scout — `url0101`


## 8. Phase 2 base footprints

### Western Logistics Base

Core:

- 2 × T1 Land Factory
- T2 Land HQ/factory present on Normal/Hard through `WEST_PRODUCTION_NORMAL`
- power, mass extractors, mass storage and energy storage
- point defense and AA
- TMD on Normal/Hard
- 2 controlled engineers
- land garrison

Objective structure:

- `West_Logistics_Command`
- blueprint `urb0201`
- custom name: **Western Logistics Command**
- not capturable/reclaimable
- never rebuilt by engineer support

Hard adds an extra factory and additional static defenses. The western footprint must keep wide factory exits toward south/east.

### Eastern Air Control Base

Core:

- 2 × T1 Air Factory
- T2 Air Factory on Normal/Hard
- `urb5202` Air Staging Facility
- power and mass economy
- heavy static AA emphasis
- TMD on Normal/Hard
- 2 controlled engineers
- light land garrison

Objective structure:

- `East_Air_Control_Command`
- blueprint `urb5202`
- custom name: **Eastern Air Control Command**
- not capturable/reclaimable

Radar network:

- 3 × `urb3101`
- separated enough that one small land push cannot accidentally kill all three at once
- all three must remain reachable by land units

## 9. Phase 2 elevation, chokepoints and ramps

West should favor land maneuver:

- plateau 28–34,
- two southern ramps at least 55–70 units wide,
- one central connector toward X≈430–500,
- no hard choke narrower than ~40 units on the main assault route.

East should favor air pressure but remain land-assaultable:

- base shelf 32–40,
- western approach around X≈640–680,
- southern approach around X≈700–770,
- ridges may narrow sight lines but must not create a one-route fortress.

Central valley:

- floor 18–24,
- broad X≈420–604 engagement space,
- optional forward base around `PHASE2_CENTRAL_EXPANSION`,
- lateral connectors to both sector plateaus.

## 10. Phase 2 patrol and combat-route validation

Validate:

1. `CHAIN_WEST_SUPPLY` with 6–8 mixed land units including an engineer.
2. `CHAIN_WEST_ATTACK` with 20–30 units toward Player1.
3. `CHAIN_WEST_ATTACK_TO_P2` with 20–30 units through Center toward Player2.
4. Both East air patrol loops and the central air loop.
5. `CHAIN_CENTRAL_RESPONSE` and `CHAIN_CENTRAL_RESPONSE_P2` with a large mixed formation.
6. `CHAIN_CENTRAL_FLANK` from spawn to P2 route.
7. West ↔ Center ↔ East lateral transfer without returning to the southern river crossings.
8. Factory exit clearance for all West land and East air factories.
9. No Phase 2 resource point is blocked by cliffs or decorative props.
10. `AREA_PHASE_3` expansion does not expose the main base plateau at Z≈118 yet.

## 11. Prop zones

Props live in the binary `.scmap`, not in the hand-maintained save contract.

### P1 south-west ruins

Approximate zone X 245–300, Z 820–880:

- 6–10 rocks
- 8–15 trees
- 1–2 small UEF wrecks
- no wreck directly adjacent to starting mass points

### P2 south-east ruins

Approximate zone X 724–780, Z 820–890:

- similar density, different shape
- 1–2 small Cybran wrecks

### River banks

Use sparse rock/tree clusters, primarily outside the three crossings. Keep all crossings visually obvious.

### Central battle scars

X 450–574, Z 650–700:

- a few craters/scorch marks
- 2–4 modest wrecks
- no large mass windfall

### Forward Outpost perimeter

Use walls, lights, small wrecks and a few rocks to make the base feel military. Keep factory exits and both southern attack approaches clear.

Do not use dense forests inside player build basins or on route chains.

## 12. Pathing validation

Before runtime testing:

1. Send a 20–30 unit T1 land formation from P1 to the Forward Outpost through `CROSSING_WEST`.
2. Repeat from P2 through `CROSSING_EAST`.
3. Test the optional central crossing with amphibious units.
4. Test air movement from both forward spawn markers to both player bases.
5. Verify large formations do not single-file through the main crossings.
6. Verify factory exits are clear.
7. Verify no decorative prop blocks resource construction.
8. Verify `CHAIN_FORWARD_REINFORCEMENT` is land-passable from Z≈470 to the outpost.
9. Send a 20–30 unit land formation through `CHAIN_WEST_ATTACK_TO_P2`; it must not jam in the central valley or at `CROSSING_EAST`.
10. Repeat the Central Response against both `CHAIN_CENTRAL_RESPONSE` and `CHAIN_CENTRAL_RESPONSE_P2`.

## 13. Manual Stage 3 / Phase 2 acceptance

The binary map is ready for Stage 3 / complete Phase 2 when:

- both players have a viable base basin,
- each start has exactly four nearby Mass markers and one Hydrocarbon,
- each player has a three-Mass first expansion,
- the river has two reliable land crossings plus an optional center route,
- the Forward Outpost plateau supports all save.lua structures without overlap,
- the central expansion is contestable but becomes practical after the outpost is broken,
- `AREA_PHASE_1` contains all Stage 2 gameplay,
- `AREA_PHASE_2` contains both active support sectors and the central valley,
- `AREA_PHASE_2_WEST`, `AREA_PHASE_2_EAST` and `AREA_PHASE_2_CENTER` match the intended terrain partitions,
- Western Logistics Base supports wide land engagements and convoy routing,
- Eastern Air Control Base supports clean air-factory exits and all three patrol loops,
- the central valley supports the Central Response and player force transfer,
- `AREA_PHASE_3` opens only the far-northern approach after both primary objectives,
- all required chains pass pathing tests,
- props/wrecks do not compromise building or performance.

# Stage 4 — Complete Phase 3 Map Editor Handoff

The Lua/save contract already contains every Phase 3 marker, chain, area, resource marker and Cybran unit group. Remaining Map Editor work is terrain sculpting, props, passability validation and binary `.scmap` export.

`save.lua` marker Y is intentionally zero. Runtime aligns scripted units to terrain. Elevations below are Map Editor terrain targets.

## 14. Phase 3 areas

| Area | Bounds | Function |
|---|---|---|
| `AREA_PHASE_3_WEST` | X 32–400, Z 176–352 | Artillery sector |
| `AREA_PHASE_3_CENTER` | X 376–648, Z 176–352 | Heavy Defense / central FOB |
| `AREA_PHASE_3_EAST` | X 624–992, Z 176–352 | Gateway sector |
| `AREA_PHASE_3` | X 32–992, Z 176–1024 | Combined Phase 1–3 play space |
| `AREA_FINALE` | X 0–1024, Z 0–1024 | Locked until Phase 3 completion |

Final defense line: approximately Z=176. Keep the Main Cybran Base around `CYBRAN_MAIN_BASE (512,118)` unreachable before `AREA_FINALE` is unlocked.

## 15. Phase 3 marker coordinates and elevation

| Marker | X | Z | Target elevation | Purpose |
|---|---:|---:|---:|---|
| `PHASE3_ARTILLERY_CENTER` | 260 | 246 | 36–40 | artillery base center |
| `PHASE3_ARTILLERY_CORE` | 260 | 222 | 38–42 | T3 artillery core |
| `PHASE3_DEFENSE_CENTER` | 512 | 246 | 30–34 | central fortification center |
| `PHASE3_DEFENSE_CONTROL_NODE` | 512 | 218 | 32–36 | primary control node |
| `PHASE3_GATEWAY_CENTER` | 764 | 246 | 28–32 | gateway staging center |
| `PHASE3_REINFORCEMENT_GATEWAY` | 764 | 218 | 30–34 | primary gateway core |
| `PHASE3_RADAR_01` | 430 | 208 | 34–38 | strategic radar west |
| `PHASE3_RADAR_02` | 650 | 208 | 32–36 | strategic radar east |
| `PHASE3_DATA_CORE` | 560 | 230 | 31–35 | optional intel target |
| `PHASE3_EXPANSION_WEST` | 340 | 315 | 24–28 | player expansion |
| `PHASE3_EXPANSION_CENTER` | 512 | 300 | 24–28 | forward operating base |
| `PHASE3_EXPANSION_EAST` | 684 | 315 | 24–28 | player expansion |
| `PHASE3_TRANSPORT_ENTRY` | 940 | 205 | air | transport entry |
| `PHASE3_TRANSPORT_EXIT` | 980 | 330 | air | transport exit |
| `PHASE3_DROP_WEST` | 410 | 505 | 20–26 | west/rear drop |
| `PHASE3_DROP_EAST` | 614 | 505 | 20–26 | east/rear drop |
| `PHASE3_DEFENSE_REBUILD_01` | 470 | 250 | 30–34 | bounded rebuild cell |
| `PHASE3_DEFENSE_REBUILD_02` | 554 | 250 | 30–34 | bounded rebuild cell |
| `PHASE3_DEFENSE_REBUILD_03` | 512 | 278 | 28–32 | bounded rebuild cell |

## 16. ARTILLERY SECTOR

Recommended footprint: X 190–330, Z 188–316. Core plateau target height 38–42; southern approach floor 24–28.

Terrain requirements:

- raised artillery plateau with broad line of fire,
- at least three practical approaches: south-west, south-center and south-east/lateral,
- no single absurd choke point,
- minimum practical land corridor width about 36 map units; 48+ preferred,
- clear rotation/footprint around `PHASE3_ARTILLERY_CORE`,
- no props in factory exits, shield footprint or artillery rotation footprint.

Groups already defined: `PHASE3_ARTILLERY_BASE`, `ARTILLERY_CORE`, `ARTILLERY_DEFENSE`, `ARTILLERY_DEFENSE_NORMAL`, `ARTILLERY_DEFENSE_HARD`, `ARTILLERY_SUPPORT`.

## 17. HEAVY DEFENSE SECTOR

Recommended footprint: X 400–624, Z 176–324. Defensive shelf target height 30–34; front engagement floor 24–28.

Create a broad fortified front with at least three approaches:

1. west shoulder X≈420–465,
2. center X≈485–540,
3. east shoulder X≈560–610.

Keep `PHASE3_DEFENSE_CONTROL_NODE` protected but reachable after the front is breached. Existing turrets stay alive when the node dies; only scripted repair/rebuild and defense-sector generation stop.

Reserve buildable, prop-free cells at all `PHASE3_DEFENSE_REBUILD_*` markers. Groups: `PHASE3_DEFENSE_BASE`, `DEFENSE_NODE`, `DEFENSE_STATIC*`, `DEFENSE_FACTORIES*`, `DEFENSE_ENGINEERS*`, `DEFENSE_GARRISON`.

## 18. REINFORCEMENT GATEWAY

Recommended footprint: X 680–846, Z 188–326. Staging floor 28–32. Provide a southern apron of at least about 100×70 map units.

Keep clear space around `PHASE3_REINFORCEMENT_GATEWAY (764,218)`, all factory exits, `PHASE3_GATEWAY_CENTER`, and the east/north-east transport approach. Visual language should be a staging base: hardstand, sparse walls, landing lights, broad open apron.

Groups: `PHASE3_GATEWAY_BASE`, `GATEWAY_CORE`, `GATEWAY_PRODUCTION*`, `GATEWAY_AA*`, `GATEWAY_SUPPORT`.

## 19. Phase 3 land attack paths

Required chains:

- `CHAIN_PHASE3_ATTACK_WEST`
- `CHAIN_PHASE3_ATTACK_CENTER`
- `CHAIN_PHASE3_ATTACK_EAST`
- `CHAIN_PHASE3_FLANK_WEST`
- `CHAIN_PHASE3_FLANK_EAST`

West/east flank routes must remain genuinely separate from the central lane. Validate each with 20 T2 units, 6–10 T3 units including `url0303`, and one `url0304`. No route may stall on ramps, cliff lips or props.

## 20. Transport routes

Required chains:

- `CHAIN_REINFORCEMENT_AIR_ENTRY`
- `CHAIN_REINFORCEMENT_DROP_WEST`
- `CHAIN_REINFORCEMENT_DROP_EAST`
- `CHAIN_REINFORCEMENT_EXIT`

Route:

```text
PHASE3_TRANSPORT_ENTRY (940,205)
        ↓
REINFORCEMENT_AIR_01 (850,220)
        ↓
REINFORCEMENT_AIR_02 (760,280)
       / \
      /   \
DROP WEST   DROP EAST
(410,505)   (614,505)
      \     /
       PHASE3_TRANSPORT_EXIT (980,330)
```

Keep the descent/unload ground broad and pathable. Do not put cliffs, tall terrain spikes, dense props or water under either final drop point. Neither drop zone is an ACU spawn.

## 21. Resource markers

West expansion:

- `PHASE3_WEST_MASS_01`
- `PHASE3_WEST_MASS_02`
- `PHASE3_WEST_MASS_03`

Center / intended forward operating base:

- `PHASE3_CENTER_MASS_01..04`
- `PHASE3_CENTER_HYDRO_01`

East expansion:

- `PHASE3_EAST_MASS_01..03`

Central expansion is intentionally the richest. Preserve roughly 120×90 usable build space around `PHASE3_EXPANSION_CENTER` for factories, shields and artillery. Do not add additional Phase 3 mass unless runtime economy testing proves it necessary.

## 22. Main Base preview and finale boundary

Recommended Main Base plateau height: 38–44 around Z≈118. `FINALE_PREVIEW_FOUNDATIONS` only reserves future Stage 5 positions and is not spawned by Phase 3 code.

Before Phase 3 completion the north must remain inaccessible. After `CompletePhase3()`, `AREA_FINALE` opens and the final-assault placeholder objective becomes active. Do not pre-activate Experimental, boss, strategic-nuclear or final-survival systems.

## 23. Phase 3 prop guidance

Artillery sector: sparse rocks/wall fragments on plateau edges, never across a full approach.

Defense center: fortification props may define lanes but must not narrow them below T3 formation width; rebuild cells and factory exits stay completely clear.

Gateway: large unobstructed apron, sparse walls/lights, no trees in transport unload lanes.

FOB/resources: no props directly on resource markers and no excessive reclaim windfall.

## 24. Phase 3 Pathing validation

Before binary export:

1. Move a T3 mixed formation from Phase 2 center to all three strategic sectors.
2. Traverse all five Phase 3 land chains with a 20+ unit formation.
3. Verify `url0304` can use center and both flank routes.
4. Verify `ura0104` can enter, descend, unload and exit on both transport chains.
5. Verify all factory exits are clear.
6. Verify every `PHASE3_DEFENSE_REBUILD_*` location is buildable.
7. Verify no Phase 3 resource marker is on a steep slope.
8. Verify the central FOB supports several factories and shields.
9. Verify normal land movement stops at the final defense line while only `AREA_PHASE_3` is active.
10. Verify `AREA_FINALE` exposes the complete north after scripted completion.

## 25. Manual Stage 4 / Phase 3 acceptance

The `.scmap` is ready for runtime Phase 3 tests when:

- Artillery Sector has a raised multi-access plateau.
- Heavy Defense Sector offers at least three wide approaches.
- Gateway has a large open staging/transport apron.
- all Phase 3 attack and flank chains are T3-pathable,
- both transport drops have valid unload ground,
- central FOB construction space is adequate,
- all Phase 3 resources are buildable,
- Main Base is inaccessible before `AREA_FINALE`,
- objective structure footprints match `save.lua`,
- props do not block factory exits, rebuild cells, paths or resource points.
