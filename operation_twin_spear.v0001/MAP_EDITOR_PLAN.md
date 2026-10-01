# Operation Twin Spear — MAP_EDITOR_PLAN

Stage 3 map-authoring specification for the complete Phase 2 of a 20 km × 20 km FAF co-op campaign map. It retains all Stage 2 / Phase 1 terrain and adds the Western Logistics Base, Eastern Air Control Base and central valley.

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
| `WEST_SUPPLY_EXIT` | Blank | 300 | 410 | 2 | Convoy arrival / bonus trigger |
| `WEST_ATTACK_01` | Blank | 320 | 448 | 2 | West attack route node |
| `WEST_ATTACK_02` | Blank | 350 | 492 | 2 | West attack route node |
| `WEST_ATTACK_03` | Blank | 390 | 540 | 2 | West attack route node |
| `EAST_BASE_CENTER` | Blank | 724 | 420 | 2 | Eastern Air Control Base center |
| `EAST_AIR_CONTROL_COMMAND` | Blank | 724 | 392 | 2 | East primary objective anchor |
| `EAST_AIR_FACTORY_01` | Blank | 690 | 430 | 2 | East air-factory footprint |
| `EAST_AIR_FACTORY_02` | Blank | 758 | 430 | 2 | East air-factory footprint |
| `EAST_RADAR_01` | Blank | 664 | 388 | 2 | Radar network objective |
| `EAST_RADAR_02` | Blank | 724 | 368 | 2 | Radar network objective |
| `EAST_RADAR_03` | Blank | 784 | 388 | 2 | Radar network objective |
| `CENTRAL_RESPONSE_SPAWN` | Blank | 512 | 354 | 2 | Central Response spawn |
| `CENTRAL_RESPONSE_TARGET` | Blank | 512 | 520 | 2 | Central Response staging/engagement point |
| `PHASE2_CENTRAL_EXPANSION` | Blank | 512 | 470 | 2 | Optional Phase 2 forward-base location |

The additional patrol and intermediate route markers in `save.lua` are authoritative. Their coordinates may be adjusted in FAF Map Editor only if the corresponding route remains semantically equivalent and the Lua/save contract is updated with the same names.


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
