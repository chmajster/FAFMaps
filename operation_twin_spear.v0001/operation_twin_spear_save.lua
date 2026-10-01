-- Operation Twin Spear - Stage 2 scenario data.
-- The binary .scmap is still created in FAF Map Editor. This file defines the
-- exact mission contract: areas, markers, resources, chains and editable unit groups.

local function BlankMarker(x, z)
    return {
        type = 'Blank Marker',
        position = VECTOR3(x, 0, z),
        orientation = VECTOR3(0, 0, 0),
        prop = '/env/common/props/markers/M_Blank_prop.bp',
        color = 'ff800080',
    }
end

local function MassMarker(x, z)
    return {
        type = 'Mass',
        resource = true,
        amount = 100,
        size = 1,
        editorIcon = '/textures/editor/marker_mass.bmp',
        position = VECTOR3(x, 0, z),
        orientation = VECTOR3(0, 0, 0),
        prop = '/env/common/props/markers/M_Mass_prop.bp',
        color = 'ff808080',
    }
end

local function HydroMarker(x, z)
    return {
        type = 'Hydrocarbon',
        resource = true,
        amount = 100,
        size = 3,
        position = VECTOR3(x, 0, z),
        orientation = VECTOR3(0, 0, 0),
        prop = '/env/common/props/markers/M_Hydrocarbon_prop.bp',
        color = 'ff008000',
    }
end

local function UnitSpec(blueprint, x, z, heading)
    return {
        type = blueprint,
        orders = '',
        platoon = '',
        Position = VECTOR3(x, 0, z),
        Orientation = VECTOR3(heading or 0, 0, 0),
    }
end

local function EmptyArmy(faction, mass, energy)
    return {
        personality = '',
        plans = '',
        color = 0,
        faction = faction,
        Economy = {
            mass = mass,
            energy = energy,
        },
        Alliances = {},
        Units = GROUP {
            orders = '',
            platoon = '',
            Units = {
                INITIAL = GROUP {
                    orders = '',
                    platoon = '',
                    Units = {},
                },
            },
        },
        PlatoonBuilders = {
            next_platoon_builder_id = '1',
            Builders = {},
        },
    }
end

local Player1 = EmptyArmy(0, 1000, 4000)
local Player2 = EmptyArmy(0, 1000, 4000)
local CybranMain = EmptyArmy(2, 10000, 100000)
local CybranOutpost = EmptyArmy(2, 5000, 50000)
local Neutral = EmptyArmy(0, 0, 0)

-- Forward Outpost is intentionally editor-readable and split into logical groups.
CybranOutpost.Units.Units.FORWARD_PRODUCTION = GROUP {
    orders = '',
    platoon = '',
    Units = {
        Forward_Land_Factory = UnitSpec('urb0101', 482, 606, 3.14159),
        Forward_Air_Factory = UnitSpec('urb0102', 542, 606, 3.14159),
    },
}

CybranOutpost.Units.Units.FORWARD_PRODUCTION_EXTRA_D2 = GROUP {
    orders = '',
    platoon = '',
    Units = {
        Forward_Second_Land_Factory = UnitSpec('urb0101', 512, 624, 3.14159),
    },
}

CybranOutpost.Units.Units.FORWARD_ECONOMY = GROUP {
    orders = '',
    platoon = '',
    Units = {
        Forward_PGen_01 = UnitSpec('urb1101', 486, 582, 0),
        Forward_PGen_02 = UnitSpec('urb1101', 497, 582, 0),
        Forward_PGen_03 = UnitSpec('urb1101', 527, 582, 0),
        Forward_PGen_04 = UnitSpec('urb1101', 538, 582, 0),
        Forward_Mex_01 = UnitSpec('urb1103', 464, 618, 0),
        Forward_Mex_02 = UnitSpec('urb1103', 560, 618, 0),
        Forward_Mex_03 = UnitSpec('urb1103', 512, 646, 0),
    },
}

CybranOutpost.Units.Units.FORWARD_DEFENSE = GROUP {
    orders = '',
    platoon = '',
    Units = {
        Forward_PD_West = UnitSpec('urb2101', 470, 652, 3.14159),
        Forward_AA_Center = UnitSpec('urb2104', 512, 650, 3.14159),
    },
}

CybranOutpost.Units.Units.FORWARD_DEFENSE_NORMAL = GROUP {
    orders = '',
    platoon = '',
    Units = {
        Forward_PD_East = UnitSpec('urb2101', 554, 652, 3.14159),
    },
}

CybranOutpost.Units.Units.FORWARD_DEFENSE_HARD = GROUP {
    orders = '',
    platoon = '',
    Units = {
        Forward_AA_West = UnitSpec('urb2104', 490, 640, 3.14159),
        Forward_AA_East = UnitSpec('urb2104', 534, 640, 3.14159),
    },
}

CybranOutpost.Units.Units.FORWARD_COMMAND = GROUP {
    orders = '',
    platoon = '',
    Units = {
        Forward_Command_Post = UnitSpec('urb0201', 512, 568, 3.14159),
    },
}

CybranOutpost.Units.Units.FORWARD_RADAR = GROUP {
    orders = '',
    platoon = '',
    Units = {
        Forward_Radar = UnitSpec('urb3101', 558, 580, 0),
    },
}

CybranOutpost.Units.Units.FORWARD_GARRISON = GROUP {
    orders = '',
    platoon = '',
    Units = {
        Garrison_Mantis_01 = UnitSpec('url0107', 486, 634, 3.14159),
        Garrison_Mantis_02 = UnitSpec('url0107', 497, 638, 3.14159),
        Garrison_Mantis_03 = UnitSpec('url0107', 527, 638, 3.14159),
        Garrison_Mantis_04 = UnitSpec('url0107', 538, 634, 3.14159),
        Garrison_AA_01 = UnitSpec('url0104', 502, 630, 3.14159),
        Garrison_AA_02 = UnitSpec('url0104', 522, 630, 3.14159),
        Garrison_Scout = UnitSpec('url0101', 512, 658, 3.14159),
    },
}


-- Phase 2 northern support network. These groups are spawned at mission populate
-- time so early destruction cannot soft-lock the later objectives.
CybranMain.Units.Units.WEST_PRODUCTION_BASE = GROUP {
    orders = '',
    platoon = '',
    Units = {
        West_Land_Factory_01 = UnitSpec('urb0101', 272, 426, 3.14159),
        West_Land_Factory_02 = UnitSpec('urb0101', 328, 426, 3.14159),
    },
}

CybranMain.Units.Units.WEST_PRODUCTION_NORMAL = GROUP {
    orders = '',
    platoon = '',
    Units = {
        West_Land_Factory_T2 = UnitSpec('urb0201', 300, 442, 3.14159),
    },
}

CybranMain.Units.Units.WEST_PRODUCTION_HARD = GROUP {
    orders = '',
    platoon = '',
    Units = {
        West_Land_Factory_03 = UnitSpec('urb0101', 300, 458, 3.14159),
    },
}

CybranMain.Units.Units.WEST_ECONOMY = GROUP {
    orders = '',
    platoon = '',
    Units = {
        West_PGen_01 = UnitSpec('urb1101', 270, 402, 0),
        West_PGen_02 = UnitSpec('urb1101', 282, 402, 0),
        West_PGen_03 = UnitSpec('urb1101', 318, 402, 0),
        West_PGen_04 = UnitSpec('urb1101', 330, 402, 0),
        West_Mass_Storage_01 = UnitSpec('urb1106', 284, 414, 0),
        West_Mass_Storage_02 = UnitSpec('urb1106', 316, 414, 0),
        West_Energy_Storage = UnitSpec('urb1105', 300, 410, 0),
        West_Mex_01 = UnitSpec('urb1103', 252, 430, 0),
        West_Mex_02 = UnitSpec('urb1103', 348, 430, 0),
        West_Mex_03 = UnitSpec('urb1103', 300, 478, 0),
    },
}

CybranMain.Units.Units.WEST_DEFENSE_BASE = GROUP {
    orders = '',
    platoon = '',
    Units = {
        West_PD_01 = UnitSpec('urb2101', 250, 462, 3.14159),
        West_PD_02 = UnitSpec('urb2101', 350, 462, 3.14159),
        West_AA_01 = UnitSpec('urb2104', 270, 468, 3.14159),
        West_AA_02 = UnitSpec('urb2104', 330, 468, 3.14159),
    },
}

CybranMain.Units.Units.WEST_DEFENSE_NORMAL = GROUP {
    orders = '',
    platoon = '',
    Units = {
        West_TMD = UnitSpec('urb4201', 300, 470, 3.14159),
        West_AA_03 = UnitSpec('urb2104', 300, 482, 3.14159),
    },
}

CybranMain.Units.Units.WEST_DEFENSE_HARD = GROUP {
    orders = '',
    platoon = '',
    Units = {
        West_PD_03 = UnitSpec('urb2101', 238, 446, 3.14159),
        West_PD_04 = UnitSpec('urb2101', 362, 446, 3.14159),
        West_AA_04 = UnitSpec('urb2104', 300, 372, 0),
    },
}

CybranMain.Units.Units.WEST_COMMAND = GROUP {
    orders = '',
    platoon = '',
    Units = {
        West_Logistics_Command = UnitSpec('urb0201', 300, 392, 3.14159),
    },
}

CybranMain.Units.Units.WEST_ENGINEERS = GROUP {
    orders = '',
    platoon = '',
    Units = {
        West_Engineer_01 = UnitSpec('url0105', 286, 446, 3.14159),
        West_Engineer_02 = UnitSpec('url0105', 314, 446, 3.14159),
    },
}

CybranMain.Units.Units.WEST_GARRISON = GROUP {
    orders = '',
    platoon = '',
    Units = {
        West_Garrison_Mantis_01 = UnitSpec('url0107', 260, 452, 3.14159),
        West_Garrison_Mantis_02 = UnitSpec('url0107', 280, 456, 3.14159),
        West_Garrison_Mantis_03 = UnitSpec('url0107', 320, 456, 3.14159),
        West_Garrison_Mantis_04 = UnitSpec('url0107', 340, 452, 3.14159),
        West_Garrison_Artillery = UnitSpec('url0103', 300, 464, 3.14159),
        West_Garrison_AA = UnitSpec('url0104', 300, 452, 3.14159),
    },
}

CybranMain.Units.Units.EAST_PRODUCTION_BASE = GROUP {
    orders = '',
    platoon = '',
    Units = {
        East_Air_Factory_01 = UnitSpec('urb0102', 690, 430, 3.14159),
        East_Air_Factory_02 = UnitSpec('urb0102', 758, 430, 3.14159),
    },
}

CybranMain.Units.Units.EAST_PRODUCTION_NORMAL = GROUP {
    orders = '',
    platoon = '',
    Units = {
        East_Air_Factory_T2 = UnitSpec('urb0202', 724, 446, 3.14159),
    },
}

CybranMain.Units.Units.EAST_PRODUCTION_HARD = GROUP {
    orders = '',
    platoon = '',
    Units = {
        East_Air_Factory_03 = UnitSpec('urb0102', 724, 462, 3.14159),
    },
}

CybranMain.Units.Units.EAST_ECONOMY = GROUP {
    orders = '',
    platoon = '',
    Units = {
        East_PGen_01 = UnitSpec('urb1101', 690, 402, 0),
        East_PGen_02 = UnitSpec('urb1101', 702, 402, 0),
        East_PGen_03 = UnitSpec('urb1101', 746, 402, 0),
        East_PGen_04 = UnitSpec('urb1101', 758, 402, 0),
        East_Air_Staging = UnitSpec('urb5202', 752, 414, 0),
        East_Energy_Storage = UnitSpec('urb1105', 724, 410, 0),
        East_Mex_01 = UnitSpec('urb1103', 676, 438, 0),
        East_Mex_02 = UnitSpec('urb1103', 772, 438, 0),
        East_Mex_03 = UnitSpec('urb1103', 724, 484, 0),
    },
}

CybranMain.Units.Units.EAST_DEFENSE_BASE = GROUP {
    orders = '',
    platoon = '',
    Units = {
        East_AA_01 = UnitSpec('urb2104', 674, 464, 3.14159),
        East_AA_02 = UnitSpec('urb2104', 700, 476, 3.14159),
        East_AA_03 = UnitSpec('urb2104', 748, 476, 3.14159),
        East_AA_04 = UnitSpec('urb2104', 774, 464, 3.14159),
        East_PD_01 = UnitSpec('urb2101', 724, 478, 3.14159),
    },
}

CybranMain.Units.Units.EAST_DEFENSE_NORMAL = GROUP {
    orders = '',
    platoon = '',
    Units = {
        East_TMD = UnitSpec('urb4201', 724, 466, 3.14159),
        East_AA_05 = UnitSpec('urb2104', 724, 490, 3.14159),
    },
}

CybranMain.Units.Units.EAST_DEFENSE_HARD = GROUP {
    orders = '',
    platoon = '',
    Units = {
        East_AA_06 = UnitSpec('urb2104', 660, 448, 3.14159),
        East_AA_07 = UnitSpec('urb2104', 788, 448, 3.14159),
        East_PD_02 = UnitSpec('urb2101', 690, 486, 3.14159),
        East_PD_03 = UnitSpec('urb2101', 758, 486, 3.14159),
    },
}

CybranMain.Units.Units.EAST_COMMAND = GROUP {
    orders = '',
    platoon = '',
    Units = {
        East_Air_Control_Command = UnitSpec('urb5202', 724, 392, 3.14159),
    },
}

CybranMain.Units.Units.EAST_RADAR_NETWORK = GROUP {
    orders = '',
    platoon = '',
    Units = {
        East_Radar_01 = UnitSpec('urb3101', 664, 388, 0),
        East_Radar_02 = UnitSpec('urb3101', 724, 368, 0),
        East_Radar_03 = UnitSpec('urb3101', 784, 388, 0),
    },
}

CybranMain.Units.Units.EAST_ENGINEERS = GROUP {
    orders = '',
    platoon = '',
    Units = {
        East_Engineer_01 = UnitSpec('url0105', 708, 452, 3.14159),
        East_Engineer_02 = UnitSpec('url0105', 740, 452, 3.14159),
    },
}

CybranMain.Units.Units.EAST_GARRISON = GROUP {
    orders = '',
    platoon = '',
    Units = {
        East_Garrison_Mantis_01 = UnitSpec('url0107', 690, 458, 3.14159),
        East_Garrison_Mantis_02 = UnitSpec('url0107', 724, 456, 3.14159),
        East_Garrison_Mantis_03 = UnitSpec('url0107', 758, 458, 3.14159),
        East_Garrison_AA = UnitSpec('url0104', 724, 470, 3.14159),
    },
}

Scenario = {
    next_area_id = '13',
    Props = {},

    Areas = {
        -- South is high Z, north is low Z.
        AREA_PHASE_1 = {
            rectangle = RECTANGLE(96, 548, 928, 1024),
        },
        AREA_PHASE_2 = {
            rectangle = RECTANGLE(64, 352, 960, 1024),
        },
        AREA_PHASE_2_WEST = {
            rectangle = RECTANGLE(64, 352, 480, 548),
        },
        AREA_PHASE_2_EAST = {
            rectangle = RECTANGLE(544, 352, 960, 548),
        },
        AREA_PHASE_2_CENTER = {
            rectangle = RECTANGLE(420, 352, 604, 548),
        },
        AREA_PHASE_3 = {
            rectangle = RECTANGLE(32, 176, 992, 1024),
        },
        AREA_FINALE = {
            rectangle = RECTANGLE(0, 0, 1024, 1024),
        },
        AREA_FORWARD_DISCOVERY = {
            rectangle = RECTANGLE(376, 540, 648, 710),
        },
        AREA_FORWARD_OUTPOST = {
            rectangle = RECTANGLE(440, 548, 584, 670),
        },
        AREA_P1_START = {
            rectangle = RECTANGLE(240, 808, 410, 970),
        },
        AREA_P2_START = {
            rectangle = RECTANGLE(614, 808, 784, 970),
        },
        MISSION_AREA = {
            rectangle = RECTANGLE(0, 0, 1024, 1024),
        },
    },

    MasterChain = {
        ['_MASTERCHAIN_'] = {
            Markers = {
                -- Player starts and local base targets
                PLAYER_1_START = BlankMarker(320, 882),
                PLAYER_2_START = BlankMarker(704, 882),
                P1_ATTACK_TARGET = BlankMarker(338, 846),
                P2_ATTACK_TARGET = BlankMarker(686, 846),

                -- Starting expansions
                P1_EXPANSION_01 = BlankMarker(382, 798),
                P2_EXPANSION_01 = BlankMarker(642, 798),
                CENTRAL_EXPANSION = BlankMarker(512, 674),

                -- River / crossings
                CROSSING_WEST = BlankMarker(410, 720),
                CROSSING_EAST = BlankMarker(614, 720),
                CROSSING_CENTER_OPTIONAL = BlankMarker(512, 732),

                -- Forward outpost
                FORWARD_OUTPOST_CENTER = BlankMarker(512, 606),
                FORWARD_COMMAND_POST = BlankMarker(512, 568),
                FORWARD_RADAR = BlankMarker(558, 580),
                CYBRAN_FORWARD_SPAWN_WEST = BlankMarker(452, 578),
                CYBRAN_FORWARD_SPAWN_EAST = BlankMarker(572, 578),

                -- Phase 1 attack paths
                ATTACK_WEST_01 = BlankMarker(444, 634),
                ATTACK_WEST_02 = BlankMarker(414, 682),
                ATTACK_WEST_03 = BlankMarker(382, 770),
                ATTACK_EAST_01 = BlankMarker(580, 634),
                ATTACK_EAST_02 = BlankMarker(610, 682),
                ATTACK_EAST_03 = BlankMarker(642, 770),

                -- Reinforcement route from future northern sectors
                REINFORCEMENT_01 = BlankMarker(512, 470),
                REINFORCEMENT_02 = BlankMarker(512, 522),

                -- Phase 2 Western Logistics Base
                WEST_BASE_CENTER = BlankMarker(300, 420),
                WEST_LOGISTICS_COMMAND = BlankMarker(300, 392),
                WEST_FACTORY_01 = BlankMarker(272, 426),
                WEST_FACTORY_02 = BlankMarker(328, 426),
                WEST_SUPPLY_ENTRY = BlankMarker(250, 354),
                WEST_SUPPLY_01 = BlankMarker(258, 372),
                WEST_SUPPLY_02 = BlankMarker(278, 394),
                WEST_SUPPLY_EXIT = BlankMarker(300, 410),
                WEST_ATTACK_01 = BlankMarker(320, 448),
                WEST_ATTACK_02 = BlankMarker(350, 492),
                WEST_ATTACK_03 = BlankMarker(390, 540),
                WEST_PATROL_01 = BlankMarker(252, 414),
                WEST_PATROL_02 = BlankMarker(300, 370),
                WEST_PATROL_03 = BlankMarker(348, 414),
                WEST_PATROL_04 = BlankMarker(300, 486),

                -- Phase 2 Eastern Air Control Base
                EAST_BASE_CENTER = BlankMarker(724, 420),
                EAST_AIR_CONTROL_COMMAND = BlankMarker(724, 392),
                EAST_AIR_FACTORY_01 = BlankMarker(690, 430),
                EAST_AIR_FACTORY_02 = BlankMarker(758, 430),
                EAST_AIR_ATTACK_SPAWN = BlankMarker(724, 442),
                EAST_RADAR_01 = BlankMarker(664, 388),
                EAST_RADAR_02 = BlankMarker(724, 368),
                EAST_RADAR_03 = BlankMarker(784, 388),
                EAST_PATROL_01A = BlankMarker(620, 380),
                EAST_PATROL_01B = BlankMarker(690, 352),
                EAST_PATROL_01C = BlankMarker(790, 374),
                EAST_PATROL_01D = BlankMarker(760, 470),
                EAST_PATROL_02A = BlankMarker(640, 458),
                EAST_PATROL_02B = BlankMarker(710, 500),
                EAST_PATROL_02C = BlankMarker(824, 456),
                EAST_PATROL_02D = BlankMarker(806, 390),
                EAST_BASE_PATROL_01 = BlankMarker(670, 420),
                EAST_BASE_PATROL_02 = BlankMarker(724, 360),
                EAST_BASE_PATROL_03 = BlankMarker(778, 420),
                EAST_BASE_PATROL_04 = BlankMarker(724, 492),

                -- Phase 2 central valley
                PHASE2_CENTRAL_EXPANSION = BlankMarker(512, 470),
                CENTRAL_RESPONSE_SPAWN = BlankMarker(512, 354),
                CENTRAL_RESPONSE_TARGET = BlankMarker(512, 520),
                CENTRAL_FLANK_01 = BlankMarker(570, 388),
                CENTRAL_FLANK_02 = BlankMarker(590, 460),
                CENTRAL_AIR_PATROL_01 = BlankMarker(450, 410),
                CENTRAL_AIR_PATROL_02 = BlankMarker(512, 370),
                CENTRAL_AIR_PATROL_03 = BlankMarker(574, 410),
                CENTRAL_AIR_PATROL_04 = BlankMarker(512, 510),

                -- Future-stage anchors
                WEST_OUTPOST_FUTURE = BlankMarker(310, 430),
                EAST_OUTPOST_FUTURE = BlankMarker(714, 430),
                WEST_SECTOR_FUTURE = BlankMarker(300, 300),
                EAST_SECTOR_FUTURE = BlankMarker(724, 300),
                DEFENSE_LINE_CENTER = BlankMarker(512, 230),
                CYBRAN_MAIN_BASE = BlankMarker(512, 118),

                -- Stage 1 compatibility aliases
                ENEMY_OUTPOST_BASE = BlankMarker(512, 606),
                ENEMY_MAIN_BASE = BlankMarker(512, 118),
                OBJECTIVE_OUTPOST = BlankMarker(512, 568),
                OBJECTIVE_FINAL_TEST = BlankMarker(512, 420),
                EXPANSION_1_CENTER = BlankMarker(512, 674),

                ATTACK_PATH_WEST_01 = BlankMarker(444, 634),
                ATTACK_PATH_WEST_02 = BlankMarker(414, 682),
                ATTACK_PATH_WEST_03 = BlankMarker(382, 770),
                ATTACK_PATH_EAST_01 = BlankMarker(580, 634),
                ATTACK_PATH_EAST_02 = BlankMarker(610, 682),
                ATTACK_PATH_EAST_03 = BlankMarker(642, 770),

                -- Player 1 starting economy: 4 mass + 1 hydro
                P1_MASS_01 = MassMarker(294, 862),
                P1_MASS_02 = MassMarker(320, 842),
                P1_MASS_03 = MassMarker(346, 862),
                P1_MASS_04 = MassMarker(320, 908),
                P1_HYDRO_01 = HydroMarker(274, 914),

                -- Player 2 starting economy: 4 mass + 1 hydro
                P2_MASS_01 = MassMarker(678, 862),
                P2_MASS_02 = MassMarker(704, 842),
                P2_MASS_03 = MassMarker(730, 862),
                P2_MASS_04 = MassMarker(704, 908),
                P2_HYDRO_01 = HydroMarker(750, 914),

                -- First player expansions
                P1_EXP_MASS_01 = MassMarker(360, 790),
                P1_EXP_MASS_02 = MassMarker(382, 774),
                P1_EXP_MASS_03 = MassMarker(404, 790),
                P2_EXP_MASS_01 = MassMarker(620, 790),
                P2_EXP_MASS_02 = MassMarker(642, 774),
                P2_EXP_MASS_03 = MassMarker(664, 790),

                -- Central reward economy controlled by the Forward Outpost
                CENTRAL_MASS_01 = MassMarker(476, 680),
                CENTRAL_MASS_02 = MassMarker(500, 662),
                CENTRAL_MASS_03 = MassMarker(524, 662),
                CENTRAL_MASS_04 = MassMarker(548, 680),
                CENTRAL_HYDRO_01 = HydroMarker(512, 700),

                -- Forward Outpost occupied extractors; reclaimable as captured territory
                OUTPOST_MASS_01 = MassMarker(464, 618),
                OUTPOST_MASS_02 = MassMarker(560, 618),
                OUTPOST_MASS_03 = MassMarker(512, 646),

                -- Phase 2 central valley expansion
                PHASE2_CENTER_MASS_01 = MassMarker(474, 474),
                PHASE2_CENTER_MASS_02 = MassMarker(498, 454),
                PHASE2_CENTER_MASS_03 = MassMarker(526, 454),
                PHASE2_CENTER_MASS_04 = MassMarker(550, 474),
                PHASE2_CENTER_HYDRO_01 = HydroMarker(512, 494),

                -- Phase 2 base economy marker references
                WEST_MASS_01 = MassMarker(252, 430),
                WEST_MASS_02 = MassMarker(348, 430),
                WEST_MASS_03 = MassMarker(300, 478),
                EAST_MASS_01 = MassMarker(676, 438),
                EAST_MASS_02 = MassMarker(772, 438),
                EAST_MASS_03 = MassMarker(724, 484),
            },
        },
    },

    Chains = {
        CHAIN_FORWARD_TO_P1 = {
            Markers = {
                'CYBRAN_FORWARD_SPAWN_WEST',
                'ATTACK_WEST_01',
                'ATTACK_WEST_02',
                'CROSSING_WEST',
                'ATTACK_WEST_03',
                'P1_ATTACK_TARGET',
            },
        },
        CHAIN_FORWARD_TO_P2 = {
            Markers = {
                'CYBRAN_FORWARD_SPAWN_EAST',
                'ATTACK_EAST_01',
                'ATTACK_EAST_02',
                'CROSSING_EAST',
                'ATTACK_EAST_03',
                'P2_ATTACK_TARGET',
            },
        },
        CHAIN_FORWARD_REINFORCEMENT = {
            Markers = {
                'REINFORCEMENT_01',
                'REINFORCEMENT_02',
                'FORWARD_OUTPOST_CENTER',
            },
        },
        CHAIN_FORWARD_GARRISON = {
            Markers = {
                'CYBRAN_FORWARD_SPAWN_WEST',
                'FORWARD_COMMAND_POST',
                'CYBRAN_FORWARD_SPAWN_EAST',
                'FORWARD_OUTPOST_CENTER',
            },
        },

        CHAIN_WEST_SUPPLY = {
            Markers = {
                'WEST_SUPPLY_ENTRY',
                'WEST_SUPPLY_01',
                'WEST_SUPPLY_02',
                'WEST_SUPPLY_EXIT',
            },
        },
        CHAIN_WEST_ATTACK = {
            Markers = {
                'WEST_ATTACK_01',
                'WEST_ATTACK_02',
                'WEST_ATTACK_03',
                'CROSSING_WEST',
                'P1_ATTACK_TARGET',
            },
        },
        CHAIN_WEST_ATTACK_TO_P2 = {
            Markers = {
                'WEST_ATTACK_01',
                'WEST_ATTACK_02',
                'WEST_ATTACK_03',
                'CENTRAL_RESPONSE_TARGET',
                'CROSSING_EAST',
                'P2_ATTACK_TARGET',
            },
        },
        CHAIN_WEST_BASE_PATROL = {
            Markers = {
                'WEST_PATROL_01',
                'WEST_PATROL_02',
                'WEST_PATROL_03',
                'WEST_PATROL_04',
                'WEST_BASE_CENTER',
            },
        },
        CHAIN_EAST_BASE_PATROL = {
            Markers = {
                'EAST_BASE_PATROL_01',
                'EAST_BASE_PATROL_02',
                'EAST_BASE_PATROL_03',
                'EAST_BASE_PATROL_04',
                'EAST_BASE_CENTER',
            },
        },
        CHAIN_EAST_AIR_PATROL_01 = {
            Markers = {
                'EAST_PATROL_01A',
                'EAST_PATROL_01B',
                'EAST_PATROL_01C',
                'EAST_PATROL_01D',
            },
        },
        CHAIN_EAST_AIR_PATROL_02 = {
            Markers = {
                'EAST_PATROL_02A',
                'EAST_PATROL_02B',
                'EAST_PATROL_02C',
                'EAST_PATROL_02D',
            },
        },
        CHAIN_CENTER_AIR_PATROL = {
            Markers = {
                'CENTRAL_AIR_PATROL_01',
                'CENTRAL_AIR_PATROL_02',
                'CENTRAL_AIR_PATROL_03',
                'CENTRAL_AIR_PATROL_04',
            },
        },
        CHAIN_CENTRAL_RESPONSE = {
            Markers = {
                'CENTRAL_RESPONSE_SPAWN',
                'CENTRAL_RESPONSE_TARGET',
                'CROSSING_CENTER_OPTIONAL',
                'P1_ATTACK_TARGET',
            },
        },
        CHAIN_CENTRAL_RESPONSE_P2 = {
            Markers = {
                'CENTRAL_RESPONSE_SPAWN',
                'CENTRAL_RESPONSE_TARGET',
                'CROSSING_EAST',
                'P2_ATTACK_TARGET',
            },
        },
        CHAIN_CENTRAL_FLANK = {
            Markers = {
                'CENTRAL_RESPONSE_SPAWN',
                'CENTRAL_FLANK_01',
                'CENTRAL_FLANK_02',
                'CROSSING_EAST',
                'P2_ATTACK_TARGET',
            },
        },

        -- Stage 1 compatibility chains
        ATTACK_PATH_WEST = {
            Markers = {
                'ATTACK_PATH_WEST_01',
                'ATTACK_PATH_WEST_02',
                'ATTACK_PATH_WEST_03',
            },
        },
        ATTACK_PATH_EAST = {
            Markers = {
                'ATTACK_PATH_EAST_01',
                'ATTACK_PATH_EAST_02',
                'ATTACK_PATH_EAST_03',
            },
        },
    },

    next_queue_id = '1',
    Orders = {},
    next_platoon_id = '1',
    Platoons = {},

    next_army_id = '6',
    next_group_id = '50',
    next_unit_id = '250',
    Armies = {
        Player1 = Player1,
        CybranMain = CybranMain,
        CybranOutpost = CybranOutpost,
        Neutral = Neutral,
        Player2 = Player2,
    },
}
