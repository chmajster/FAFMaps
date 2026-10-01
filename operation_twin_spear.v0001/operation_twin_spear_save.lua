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

Scenario = {
    next_area_id = '10',
    Props = {},

    Areas = {
        -- South is high Z, north is low Z.
        AREA_PHASE_1 = {
            rectangle = RECTANGLE(96, 548, 928, 1024),
        },
        AREA_PHASE_2 = {
            rectangle = RECTANGLE(64, 352, 960, 1024),
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
    next_group_id = '20',
    next_unit_id = '100',
    Armies = {
        Player1 = Player1,
        CybranMain = CybranMain,
        CybranOutpost = CybranOutpost,
        Neutral = Neutral,
        Player2 = Player2,
    },
}
