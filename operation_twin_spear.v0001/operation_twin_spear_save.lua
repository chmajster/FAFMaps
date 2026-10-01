-- Operation Twin Spear - Stage 4 scenario data / complete Phase 3.
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


-- Phase 3 strategic defense belt. These groups are created at mission populate
-- and held passive until StartPhase3 so long-range/air cheese cannot soft-lock
-- objectives that have not yet been formally assigned.

CybranMain.Units.Units.PHASE3_ARTILLERY_BASE = GROUP {
    orders = '',
    platoon = '',
    Units = {
        Phase3_Artillery_Factory = UnitSpec('urb0201', 226, 250, 3.14159),
        Phase3_Artillery_PGen_01 = UnitSpec('urb1101', 220, 226, 0),
        Phase3_Artillery_PGen_02 = UnitSpec('urb1101', 232, 226, 0),
        Phase3_Artillery_PGen_03 = UnitSpec('urb1101', 288, 226, 0),
        Phase3_Artillery_PGen_04 = UnitSpec('urb1101', 300, 226, 0),
    },
}

CybranMain.Units.Units.ARTILLERY_CORE = GROUP {
    orders = '',
    platoon = '',
    Units = {
        Phase3_Artillery_Core = UnitSpec('urb2302', 260, 222, 3.14159),
    },
}

CybranMain.Units.Units.ARTILLERY_DEFENSE = GROUP {
    orders = '',
    platoon = '',
    Units = {
        Phase3_Artillery_PD_01 = UnitSpec('urb2301', 214, 278, 3.14159),
        Phase3_Artillery_PD_02 = UnitSpec('urb2301', 306, 278, 3.14159),
        Phase3_Artillery_AA_01 = UnitSpec('urb2304', 230, 268, 3.14159),
        Phase3_Artillery_AA_02 = UnitSpec('urb2304', 290, 268, 3.14159),
        Phase3_Artillery_TMD = UnitSpec('urb4201', 260, 270, 3.14159),
        Phase3_Artillery_Shield = UnitSpec('urb4202', 260, 246, 0),
    },
}

CybranMain.Units.Units.ARTILLERY_DEFENSE_NORMAL = GROUP {
    orders = '',
    platoon = '',
    Units = {
        Phase3_Artillery_Shield_Normal = UnitSpec('urb4204', 260, 258, 0),
        Phase3_Artillery_AA_Normal = UnitSpec('urb2304', 260, 286, 3.14159),
    },
}

CybranMain.Units.Units.ARTILLERY_DEFENSE_HARD = GROUP {
    orders = '',
    platoon = '',
    Units = {
        Phase3_Artillery_PD_Hard_01 = UnitSpec('urb2301', 198, 260, 3.14159),
        Phase3_Artillery_PD_Hard_02 = UnitSpec('urb2301', 322, 260, 3.14159),
        Phase3_Artillery_AA_Hard_01 = UnitSpec('urb2304', 206, 238, 3.14159),
        Phase3_Artillery_AA_Hard_02 = UnitSpec('urb2304', 314, 238, 3.14159),
    },
}

CybranMain.Units.Units.ARTILLERY_SUPPORT = GROUP {
    orders = '',
    platoon = '',
    Units = {
        Phase3_Artillery_Rhino_01 = UnitSpec('url0202', 236, 292, 3.14159),
        Phase3_Artillery_Rhino_02 = UnitSpec('url0202', 284, 292, 3.14159),
        Phase3_Artillery_AA_Mobile = UnitSpec('url0205', 260, 298, 3.14159),
        Phase3_Artillery_Stealth = UnitSpec('url0306', 260, 306, 3.14159),
    },
}

CybranMain.Units.Units.PHASE3_DEFENSE_BASE = GROUP {
    orders = '',
    platoon = '',
    Units = {
        Phase3_Defense_PGen_01 = UnitSpec('urb1101', 486, 214, 0),
        Phase3_Defense_PGen_02 = UnitSpec('urb1101', 498, 214, 0),
        Phase3_Defense_PGen_03 = UnitSpec('urb1101', 526, 214, 0),
        Phase3_Defense_PGen_04 = UnitSpec('urb1101', 538, 214, 0),
    },
}

CybranMain.Units.Units.DEFENSE_NODE = GROUP {
    orders = '',
    platoon = '',
    Units = {
        Heavy_Defense_Control_Node = UnitSpec('urb3104', 512, 218, 3.14159),
    },
}

CybranMain.Units.Units.DEFENSE_STATIC = GROUP {
    orders = '',
    platoon = '',
    Units = {
        Phase3_Defense_PD_01 = UnitSpec('urb2301', 432, 278, 3.14159),
        Phase3_Defense_PD_02 = UnitSpec('urb2301', 472, 286, 3.14159),
        Phase3_Defense_PD_03 = UnitSpec('urb2301', 552, 286, 3.14159),
        Phase3_Defense_PD_04 = UnitSpec('urb2301', 592, 278, 3.14159),
        Phase3_Defense_AA_01 = UnitSpec('urb2304', 448, 258, 3.14159),
        Phase3_Defense_AA_02 = UnitSpec('urb2304', 576, 258, 3.14159),
        Phase3_Defense_TMD_01 = UnitSpec('urb4201', 482, 266, 3.14159),
        Phase3_Defense_TMD_02 = UnitSpec('urb4201', 542, 266, 3.14159),
        Phase3_Defense_Shield_01 = UnitSpec('urb4202', 470, 242, 0),
        Phase3_Defense_Shield_02 = UnitSpec('urb4202', 554, 242, 0),
    },
}

CybranMain.Units.Units.DEFENSE_STATIC_NORMAL = GROUP {
    orders = '',
    platoon = '',
    Units = {
        Phase3_Defense_Shield_Normal = UnitSpec('urb4204', 512, 248, 0),
        Phase3_Defense_AA_Normal_01 = UnitSpec('urb2304', 492, 292, 3.14159),
        Phase3_Defense_AA_Normal_02 = UnitSpec('urb2304', 532, 292, 3.14159),
    },
}

CybranMain.Units.Units.DEFENSE_STATIC_HARD = GROUP {
    orders = '',
    platoon = '',
    Units = {
        Phase3_Defense_PD_Hard_01 = UnitSpec('urb2301', 414, 260, 3.14159),
        Phase3_Defense_PD_Hard_02 = UnitSpec('urb2301', 610, 260, 3.14159),
        Phase3_Defense_AA_Hard_01 = UnitSpec('urb2304', 462, 224, 3.14159),
        Phase3_Defense_AA_Hard_02 = UnitSpec('urb2304', 562, 224, 3.14159),
        Phase3_Defense_Shield_Hard = UnitSpec('urb4204', 512, 234, 0),
    },
}

CybranMain.Units.Units.DEFENSE_FACTORIES = GROUP {
    orders = '',
    platoon = '',
    Units = {
        Phase3_Defense_Land_Factory_01 = UnitSpec('urb0201', 462, 202, 3.14159),
        Phase3_Defense_Land_Factory_02 = UnitSpec('urb0201', 562, 202, 3.14159),
    },
}

CybranMain.Units.Units.DEFENSE_FACTORIES_NORMAL = GROUP {
    orders = '',
    platoon = '',
    Units = {
        Phase3_Defense_Land_Factory_T3 = UnitSpec('urb0301', 512, 194, 3.14159),
    },
}

CybranMain.Units.Units.DEFENSE_FACTORIES_HARD = GROUP {
    orders = '',
    platoon = '',
    Units = {
        Phase3_Defense_Land_Factory_T3_Hard = UnitSpec('urb0301', 512, 182, 3.14159),
    },
}

CybranMain.Units.Units.DEFENSE_ENGINEERS = GROUP {
    orders = '',
    platoon = '',
    Units = {
        Phase3_Defense_Engineer_01 = UnitSpec('url0208', 486, 258, 3.14159),
        Phase3_Defense_Engineer_02 = UnitSpec('url0208', 538, 258, 3.14159),
    },
}

CybranMain.Units.Units.DEFENSE_ENGINEERS_HARD = GROUP {
    orders = '',
    platoon = '',
    Units = {
        Phase3_Defense_Engineer_Hard = UnitSpec('url0208', 512, 270, 3.14159),
    },
}

CybranMain.Units.Units.DEFENSE_GARRISON = GROUP {
    orders = '',
    platoon = '',
    Units = {
        Phase3_Defense_Rhino_01 = UnitSpec('url0202', 446, 302, 3.14159),
        Phase3_Defense_Rhino_02 = UnitSpec('url0202', 478, 306, 3.14159),
        Phase3_Defense_Rhino_03 = UnitSpec('url0202', 546, 306, 3.14159),
        Phase3_Defense_Rhino_04 = UnitSpec('url0202', 578, 302, 3.14159),
        Phase3_Defense_MobileAA_01 = UnitSpec('url0205', 494, 312, 3.14159),
        Phase3_Defense_MobileAA_02 = UnitSpec('url0205', 530, 312, 3.14159),
        Phase3_Defense_MobileArtillery_01 = UnitSpec('url0103', 506, 318, 3.14159),
        Phase3_Defense_MobileArtillery_02 = UnitSpec('url0103', 518, 318, 3.14159),
    },
}

CybranMain.Units.Units.PHASE3_GATEWAY_BASE = GROUP {
    orders = '',
    platoon = '',
    Units = {
        Phase3_Gateway_PGen_01 = UnitSpec('urb1101', 720, 218, 0),
        Phase3_Gateway_PGen_02 = UnitSpec('urb1101', 732, 218, 0),
        Phase3_Gateway_PGen_03 = UnitSpec('urb1101', 796, 218, 0),
        Phase3_Gateway_PGen_04 = UnitSpec('urb1101', 808, 218, 0),
    },
}

CybranMain.Units.Units.GATEWAY_CORE = GROUP {
    orders = '',
    platoon = '',
    Units = {
        Phase3_Reinforcement_Gateway = UnitSpec('urb0304', 764, 218, 3.14159),
    },
}

CybranMain.Units.Units.GATEWAY_PRODUCTION = GROUP {
    orders = '',
    platoon = '',
    Units = {
        Phase3_Gateway_Land_Factory = UnitSpec('urb0201', 730, 252, 3.14159),
        Phase3_Gateway_Air_Factory = UnitSpec('urb0202', 798, 252, 3.14159),
    },
}

CybranMain.Units.Units.GATEWAY_PRODUCTION_NORMAL = GROUP {
    orders = '',
    platoon = '',
    Units = {
        Phase3_Gateway_Land_Factory_T3 = UnitSpec('urb0301', 742, 270, 3.14159),
    },
}

CybranMain.Units.Units.GATEWAY_PRODUCTION_HARD = GROUP {
    orders = '',
    platoon = '',
    Units = {
        Phase3_Gateway_Air_Factory_T3 = UnitSpec('urb0302', 786, 270, 3.14159),
    },
}

CybranMain.Units.Units.GATEWAY_AA = GROUP {
    orders = '',
    platoon = '',
    Units = {
        Phase3_Gateway_AA_01 = UnitSpec('urb2304', 704, 276, 3.14159),
        Phase3_Gateway_AA_02 = UnitSpec('urb2304', 824, 276, 3.14159),
        Phase3_Gateway_AA_03 = UnitSpec('urb2304', 734, 294, 3.14159),
        Phase3_Gateway_AA_04 = UnitSpec('urb2304', 794, 294, 3.14159),
        Phase3_Gateway_TMD = UnitSpec('urb4201', 764, 286, 3.14159),
        Phase3_Gateway_Shield = UnitSpec('urb4202', 764, 252, 0),
    },
}

CybranMain.Units.Units.GATEWAY_AA_HARD = GROUP {
    orders = '',
    platoon = '',
    Units = {
        Phase3_Gateway_AA_Hard_01 = UnitSpec('urb2304', 692, 250, 3.14159),
        Phase3_Gateway_AA_Hard_02 = UnitSpec('urb2304', 836, 250, 3.14159),
        Phase3_Gateway_Shield_Hard = UnitSpec('urb4204', 764, 264, 0),
    },
}

CybranMain.Units.Units.GATEWAY_SUPPORT = GROUP {
    orders = '',
    platoon = '',
    Units = {
        Phase3_Gateway_Rhino_01 = UnitSpec('url0202', 718, 306, 3.14159),
        Phase3_Gateway_Rhino_02 = UnitSpec('url0202', 742, 312, 3.14159),
        Phase3_Gateway_Rhino_03 = UnitSpec('url0202', 786, 312, 3.14159),
        Phase3_Gateway_Rhino_04 = UnitSpec('url0202', 810, 306, 3.14159),
        Phase3_Gateway_MobileAA_01 = UnitSpec('url0205', 754, 320, 3.14159),
        Phase3_Gateway_MobileAA_02 = UnitSpec('url0205', 774, 320, 3.14159),
    },
}

CybranMain.Units.Units.PHASE3_STRATEGIC_RADAR = GROUP {
    orders = '',
    platoon = '',
    Units = {
        Phase3_Strategic_Radar_01 = UnitSpec('urb3201', 430, 208, 0),
        Phase3_Strategic_Radar_02 = UnitSpec('urb3201', 650, 208, 0),
    },
}

CybranMain.Units.Units.PHASE3_DATA_CORE = GROUP {
    orders = '',
    platoon = '',
    Units = {
        Phase3_Data_Core = UnitSpec('urb1105', 560, 230, 0),
    },
}

-- Map Editor / finale handoff only. This group is intentionally not spawned by
-- Phase 3 code; it reserves recognizable foundation positions for Stage 5.
CybranMain.Units.Units.FINALE_PREVIEW_FOUNDATIONS = GROUP {
    orders = '',
    platoon = '',
    Units = {
        Finale_Preview_Land_Factory = UnitSpec('urb0301', 458, 128, 3.14159),
        Finale_Preview_Air_Factory = UnitSpec('urb0302', 566, 128, 3.14159),
        Finale_Preview_AA_West = UnitSpec('urb2304', 420, 158, 3.14159),
        Finale_Preview_AA_East = UnitSpec('urb2304', 604, 158, 3.14159),
    },
}

Scenario = {
    next_area_id = '16',
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
        AREA_PHASE_3_WEST = {
            rectangle = RECTANGLE(32, 176, 400, 352),
        },
        AREA_PHASE_3_CENTER = {
            rectangle = RECTANGLE(376, 176, 648, 352),
        },
        AREA_PHASE_3_EAST = {
            rectangle = RECTANGLE(624, 176, 992, 352),
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

                -- Phase 3 strategic defense belt
                PHASE3_ARTILLERY_CENTER = BlankMarker(260, 246),
                PHASE3_ARTILLERY_CORE = BlankMarker(260, 222),
                PHASE3_DEFENSE_CENTER = BlankMarker(512, 246),
                PHASE3_DEFENSE_CONTROL_NODE = BlankMarker(512, 218),
                PHASE3_GATEWAY_CENTER = BlankMarker(764, 246),
                PHASE3_REINFORCEMENT_GATEWAY = BlankMarker(764, 218),
                PHASE3_RADAR_01 = BlankMarker(430, 208),
                PHASE3_RADAR_02 = BlankMarker(650, 208),
                PHASE3_DATA_CORE = BlankMarker(560, 230),

                PHASE3_EXPANSION_WEST = BlankMarker(340, 315),
                PHASE3_EXPANSION_CENTER = BlankMarker(512, 300),
                PHASE3_EXPANSION_EAST = BlankMarker(684, 315),

                PHASE3_DEFENSE_REBUILD_01 = BlankMarker(470, 250),
                PHASE3_DEFENSE_REBUILD_02 = BlankMarker(554, 250),
                PHASE3_DEFENSE_REBUILD_03 = BlankMarker(512, 278),

                PHASE3_TRANSPORT_ENTRY = BlankMarker(940, 205),
                PHASE3_TRANSPORT_EXIT = BlankMarker(980, 330),
                PHASE3_DROP_WEST_APPROACH = BlankMarker(486, 390),
                PHASE3_DROP_WEST = BlankMarker(410, 505),
                PHASE3_DROP_EAST_APPROACH = BlankMarker(538, 390),
                PHASE3_DROP_EAST = BlankMarker(614, 505),

                PHASE3_ATTACK_WEST_01 = BlankMarker(300, 326),
                PHASE3_ATTACK_WEST_02 = BlankMarker(338, 390),
                PHASE3_ATTACK_WEST_03 = BlankMarker(372, 476),
                PHASE3_ATTACK_CENTER_01 = BlankMarker(512, 330),
                PHASE3_ATTACK_CENTER_02 = BlankMarker(512, 410),
                PHASE3_ATTACK_CENTER_03 = BlankMarker(512, 500),
                PHASE3_ATTACK_EAST_01 = BlankMarker(724, 326),
                PHASE3_ATTACK_EAST_02 = BlankMarker(686, 390),
                PHASE3_ATTACK_EAST_03 = BlankMarker(652, 476),
                PHASE3_FLANK_WEST_01 = BlankMarker(204, 340),
                PHASE3_FLANK_WEST_02 = BlankMarker(248, 448),
                PHASE3_FLANK_EAST_01 = BlankMarker(820, 340),
                PHASE3_FLANK_EAST_02 = BlankMarker(776, 448),

                REINFORCEMENT_AIR_01 = BlankMarker(850, 220),
                REINFORCEMENT_AIR_02 = BlankMarker(760, 280),

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

                -- Phase 3 player economy progression
                PHASE3_WEST_MASS_01 = MassMarker(320, 324),
                PHASE3_WEST_MASS_02 = MassMarker(340, 304),
                PHASE3_WEST_MASS_03 = MassMarker(360, 324),

                PHASE3_CENTER_MASS_01 = MassMarker(482, 308),
                PHASE3_CENTER_MASS_02 = MassMarker(502, 288),
                PHASE3_CENTER_MASS_03 = MassMarker(522, 288),
                PHASE3_CENTER_MASS_04 = MassMarker(542, 308),
                PHASE3_CENTER_HYDRO_01 = HydroMarker(512, 326),

                PHASE3_EAST_MASS_01 = MassMarker(664, 324),
                PHASE3_EAST_MASS_02 = MassMarker(684, 304),
                PHASE3_EAST_MASS_03 = MassMarker(704, 324),

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


        CHAIN_PHASE3_ATTACK_WEST = {
            Markers = {
                'PHASE3_ARTILLERY_CENTER',
                'PHASE3_ATTACK_WEST_01',
                'PHASE3_ATTACK_WEST_02',
                'PHASE3_ATTACK_WEST_03',
                'WEST_ATTACK_03',
                'CROSSING_WEST',
                'P1_ATTACK_TARGET',
            },
        },
        CHAIN_PHASE3_ATTACK_CENTER = {
            Markers = {
                'PHASE3_DEFENSE_CENTER',
                'PHASE3_ATTACK_CENTER_01',
                'PHASE3_ATTACK_CENTER_02',
                'PHASE3_ATTACK_CENTER_03',
                'CENTRAL_RESPONSE_TARGET',
                'CROSSING_CENTER_OPTIONAL',
                'P1_ATTACK_TARGET',
            },
        },
        CHAIN_PHASE3_ATTACK_EAST = {
            Markers = {
                'PHASE3_GATEWAY_CENTER',
                'PHASE3_ATTACK_EAST_01',
                'PHASE3_ATTACK_EAST_02',
                'PHASE3_ATTACK_EAST_03',
                'EAST_BASE_CENTER',
                'CROSSING_EAST',
            },
        },
        CHAIN_PHASE3_FLANK_WEST = {
            Markers = {
                'PHASE3_DEFENSE_CENTER',
                'PHASE3_FLANK_WEST_01',
                'PHASE3_FLANK_WEST_02',
                'WEST_ATTACK_03',
            },
        },
        CHAIN_PHASE3_FLANK_EAST = {
            Markers = {
                'PHASE3_GATEWAY_CENTER',
                'PHASE3_FLANK_EAST_01',
                'PHASE3_FLANK_EAST_02',
                'EAST_BASE_CENTER',
            },
        },
        CHAIN_REINFORCEMENT_AIR_ENTRY = {
            Markers = {
                'PHASE3_TRANSPORT_ENTRY',
                'REINFORCEMENT_AIR_01',
                'REINFORCEMENT_AIR_02',
            },
        },
        CHAIN_REINFORCEMENT_DROP_WEST = {
            Markers = {
                'REINFORCEMENT_AIR_02',
                'PHASE3_DROP_WEST_APPROACH',
                'PHASE3_DROP_WEST',
            },
        },
        CHAIN_REINFORCEMENT_DROP_EAST = {
            Markers = {
                'REINFORCEMENT_AIR_02',
                'PHASE3_DROP_EAST_APPROACH',
                'PHASE3_DROP_EAST',
            },
        },
        CHAIN_REINFORCEMENT_EXIT = {
            Markers = {
                'PHASE3_TRANSPORT_EXIT',
                'PHASE3_TRANSPORT_ENTRY',
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
    next_group_id = '90',
    next_unit_id = '450',
    Armies = {
        Player1 = Player1,
        CybranMain = CybranMain,
        CybranOutpost = CybranOutpost,
        Neutral = Neutral,
        Player2 = Player2,
    },
}
