-- Minimal editor-compatible scenario data for the Stage 1 mission framework.
-- The real binary operation_twin_spear.scmap must be created with FAF Map Editor.
-- Re-saving the map in the editor may regenerate this file; preserve the names below.

local function BlankMarker(x, z)
    return {
        type = 'Blank Marker',
        position = VECTOR3(x, 0, z),
        orientation = VECTOR3(0, 0, 0),
        prop = '/env/common/props/markers/M_Blank_prop.bp',
        color = 'ff800080',
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

Scenario = {
    next_area_id = '2',
    Props = {},
    Areas = {
        MISSION_AREA = {
            rectangle = RECTANGLE(0, 0, 1024, 1024),
        },
    },

    MasterChain = {
        ['_MASTERCHAIN_'] = {
            Markers = {
                PLAYER_1_START = BlankMarker(380, 820),
                PLAYER_2_START = BlankMarker(644, 820),

                ENEMY_OUTPOST_BASE = BlankMarker(384, 500),
                ENEMY_MAIN_BASE = BlankMarker(512, 188),

                OBJECTIVE_OUTPOST = BlankMarker(384, 500),
                OBJECTIVE_FINAL_TEST = BlankMarker(512, 250),
                EXPANSION_1_CENTER = BlankMarker(512, 650),

                ATTACK_PATH_WEST_01 = BlankMarker(384, 470),
                ATTACK_PATH_WEST_02 = BlankMarker(420, 600),
                ATTACK_PATH_WEST_03 = BlankMarker(450, 730),

                ATTACK_PATH_EAST_01 = BlankMarker(640, 470),
                ATTACK_PATH_EAST_02 = BlankMarker(604, 600),
                ATTACK_PATH_EAST_03 = BlankMarker(574, 730),
            },
        },
    },

    Chains = {
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
    next_group_id = '1',
    next_unit_id = '1',
    Armies = {
        Player1 = EmptyArmy(0, 1000, 4000),
        CybranMain = EmptyArmy(2, 10000, 100000),
        CybranOutpost = EmptyArmy(2, 5000, 50000),
        Neutral = EmptyArmy(0, 0, 0),
        Player2 = EmptyArmy(0, 1000, 4000),
    },
}
