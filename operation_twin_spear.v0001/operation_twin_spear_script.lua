local Objectives = import('/lua/simobjectives.lua')
local ScenarioFramework = import('/lua/scenarioframework.lua')
local ScenarioUtils = import('/lua/sim/scenarioutilities.lua')

local DEBUG = false
local DEBUG_OPTIONS = {
    StartPhase1Immediately = false,
    StartPhase2Immediately = false,
    StartPhase3Immediately = false,
    SkipIntro = false,
}

-- Numeric army positions follow the order from operation_twin_spear_scenario.lua.
ScenarioInfo.Player1 = 1
ScenarioInfo.CybranMain = 2
ScenarioInfo.CybranOutpost = 3
ScenarioInfo.Neutral = 4
ScenarioInfo.Player2 = 5

local Army = {
    Player1 = 'Player1',
    Player2 = 'Player2',
    EnemyMain = 'CybranMain',
    EnemyOutpost = 'CybranOutpost',
    Neutral = 'Neutral',
}

local UnitBlueprints = {
    UEF = {
        Commander = 'uel0001',
    },
    Cybran = {
        LandScout = 'url0101',
        MobileArtillery = 'url0103',
        MobileAA = 'url0104',
        AssaultBot = 'url0107',
        HeavyTankT2 = 'url0202',
        MobileAAT2 = 'url0205',
        Engineer = 'url0105',
        AirScout = 'ura0101',
        Interceptor = 'ura0102',
        Bomber = 'ura0103',
        Gunship = 'ura0203',
        TransportT1 = 'ura0107',
        TransportT2 = 'ura0104',
        EngineerT2 = 'url0208',
        StealthT2 = 'url0306',
        SiegeAssaultT3 = 'url0303',
        HeavyArtilleryT3 = 'url0304',
        AirSuperiorityT3 = 'ura0303',
        StrategicBomberT3 = 'ura0304',
    },
}

local DifficultyScaling = {
    [1] = {
        Name = 'Easy',
        UnitMultiplier = 0.85,
        DelayMultiplier = 1.15,
        ResourceMultiplier = 0.90,
    },
    [2] = {
        Name = 'Normal',
        UnitMultiplier = 1.00,
        DelayMultiplier = 1.00,
        ResourceMultiplier = 1.00,
    },
    [3] = {
        Name = 'Hard',
        UnitMultiplier = 1.20,
        DelayMultiplier = 0.85,
        ResourceMultiplier = 1.20,
    },
}

local PlayerScaling = {
    [1] = {
        EnemyMultiplier = 1.00,
        DelayMultiplier = 1.00,
        ResourceMultiplier = 1.00,
    },
    [2] = {
        EnemyMultiplier = 1.50,
        DelayMultiplier = 0.90,
        ResourceMultiplier = 1.25,
    },
}

local Dialogues = {
    Intro1 = {
        {
            text = '[UEF Command]: Commanders, establish a foothold and secure the southern sector. Cybran forces are operating north of your position.',
            faction = 'UEF',
            duration = 6,
        },
    },
    Intro2 = {
        {
            text = '[UEF Command]: We have detected a Cybran forward command facility across the river. Confirm its position and destroy it before reinforcements arrive.',
            faction = 'UEF',
            duration = 6,
        },
    },
    ForwardDiscovered = {
        {
            text = '[UEF Command]: Forward command facility confirmed. Break the outpost and secure access to the central expansion.',
            faction = 'UEF',
            duration = 5,
        },
    },
    RadarDestroyed = {
        {
            text = '[UEF Command]: Cybran radar is offline. Enemy air coordination has been disrupted.',
            faction = 'UEF',
            duration = 5,
        },
    },
    CommandDestroyed = {
        {
            text = '[UEF Command]: Forward Command Post destroyed. Hold the sector; Cybran reaction forces are moving south.',
            faction = 'UEF',
            duration = 5,
        },
    },
    Counterattack = {
        {
            text = '[UEF Command]: Counterattack inbound from the north. Consolidate your defenses and break their assault.',
            faction = 'UEF',
            duration = 5,
        },
    },
    Phase1Complete = {
        {
            text = '[UEF Command]: Southern sector secured. We are receiving new intelligence. Cybran activity extends much further north than expected.',
            faction = 'UEF',
            duration = 6,
        },
    },
    Phase2 = {
        {
            text = '[UEF Command]: We\'ve identified two support installations. Take them both out before advancing north.',
            faction = 'UEF',
            duration = 6,
        },
    },
    Phase2WestDestroyed = {
        {
            text = '[UEF Command]: Logistics hub destroyed. Cybran ground reinforcement capacity is dropping.',
            faction = 'UEF',
            duration = 5,
        },
    },
    Phase2EastDestroyed = {
        {
            text = '[UEF Command]: Air-control facility neutralized. Enemy air operations are collapsing.',
            faction = 'UEF',
            duration = 5,
        },
    },
    Phase2CentralResponse = {
        {
            text = '[UEF Command]: Cybran forces are redeploying through the central sector. Prepare for a counterattack.',
            faction = 'UEF',
            duration = 5,
        },
    },
    Phase2ConvoysBroken = {
        {
            text = '[UEF Command]: Cybran logistics are collapsing. Enemy reinforcement capacity has been reduced.',
            faction = 'UEF',
            duration = 5,
        },
    },
    Phase2RadarDestroyed = {
        {
            text = '[UEF Command]: Radar network destroyed. Enemy air coordination and patrol coverage are reduced.',
            faction = 'UEF',
            duration = 5,
        },
    },
    Phase2Complete = {
        {
            text = '[UEF Command]: Both support installations are down. The route north is open.',
            faction = 'UEF',
            duration = 6,
        },
    },
    Phase3 = {
        {
            text = '[UEF Command]: The main complex is ahead, but three strategic installations are blocking our advance.',
            faction = 'UEF',
            duration = 6,
        },
    },
    Phase3ArtilleryWarning = {
        {
            text = '[UEF Command]: Incoming long-range fire. Neutralize that artillery position.',
            faction = 'UEF',
            duration = 5,
        },
    },
    Phase3StrategicResponse = {
        {
            text = '[UEF Command]: One installation down. Cybran command is reacting.',
            faction = 'UEF',
            duration = 5,
        },
    },
    Phase3EmergencyResponse = {
        {
            text = '[UEF Command]: They\'re mobilizing everything they have left in this sector.',
            faction = 'UEF',
            duration = 5,
        },
    },
    Phase3Complete = {
        {
            text = '[UEF Command]: The defense network is collapsing. The main complex is exposed.',
            faction = 'UEF',
            duration = 6,
        },
    },
    Phase3ExperimentalTease = {
        {
            text = '[UEF Command]: We\'re detecting a massive power signature inside the complex.',
            faction = 'UEF',
            duration = 5,
        },
    },
    Phase3RadarDestroyed = {
        {
            text = '[UEF Command]: Strategic radar is offline. Cybran drop and air coordination is degraded.',
            faction = 'UEF',
            duration = 5,
        },
    },
    Phase3DataCore = {
        {
            text = '[UEF Command]: Data core secured. Uploading a partial layout of the main complex.',
            faction = 'UEF',
            duration = 5,
        },
    },
    FinaleReady = {
        {
            text = '[UEF Command]: Commanders, this is it. The main complex is exposed. Prepare for the final assault.',
            faction = 'UEF',
            duration = 6,
        },
    },
}

local WaveDefinitions = {
    Phase1_Wave_01 = {
        Name = 'Phase1_Wave_01',
        Army = Army.EnemyOutpost,
        SpawnMarker = 'CYBRAN_FORWARD_SPAWN_WEST',
        PreferredTarget = Army.Player1,
        Units = {
            {Blueprint = UnitBlueprints.Cybran.AssaultBot, Count = 2},
            {Blueprint = UnitBlueprints.Cybran.MobileAA, Count = 1},
            {Blueprint = UnitBlueprints.Cybran.LandScout, Count = 1},
        },
    },
    Phase1_Wave_02 = {
        Name = 'Phase1_Wave_02',
        Army = Army.EnemyOutpost,
        SpawnMarker = 'CYBRAN_FORWARD_SPAWN_WEST',
        PreferredTarget = Army.Player1,
        Units = {
            {Blueprint = UnitBlueprints.Cybran.AssaultBot, Count = 5},
            {Blueprint = UnitBlueprints.Cybran.MobileAA, Count = 1},
        },
    },
    Phase1_Wave_03 = {
        Name = 'Phase1_Wave_03',
        Army = Army.EnemyOutpost,
        SpawnMarker = 'CYBRAN_FORWARD_SPAWN_EAST',
        PreferredTarget = Army.Player2,
        Units = {
            {Blueprint = UnitBlueprints.Cybran.AssaultBot, Count = 5},
            {Blueprint = UnitBlueprints.Cybran.MobileArtillery, Count = 2},
            {Blueprint = UnitBlueprints.Cybran.MobileAA, Count = 2},
        },
    },
    Phase1_Wave_04 = {
        Name = 'Phase1_Wave_04',
        Army = Army.EnemyOutpost,
        SpawnMarker = 'CYBRAN_FORWARD_SPAWN_EAST',
        SplitTargets = true,
        Air = true,
        Units = {
            {Blueprint = UnitBlueprints.Cybran.Interceptor, Count = 2},
            {Blueprint = UnitBlueprints.Cybran.Bomber, Count = 1},
        },
    },
    Counterattack_West = {
        Name = 'Counterattack_West',
        Army = Army.EnemyMain,
        SpawnMarker = 'REINFORCEMENT_01',
        PreferredTarget = Army.Player1,
        AllowAfterCommand = true,
        Units = {
            {Blueprint = UnitBlueprints.Cybran.AssaultBot, Count = 6},
            {Blueprint = UnitBlueprints.Cybran.MobileArtillery, Count = 2},
            {Blueprint = UnitBlueprints.Cybran.MobileAA, Count = 2},
        },
        HardUnits = {
            {Blueprint = UnitBlueprints.Cybran.HeavyTankT2, Count = 1},
            {Blueprint = UnitBlueprints.Cybran.MobileAAT2, Count = 1},
        },
    },
    Counterattack_East = {
        Name = 'Counterattack_East',
        Army = Army.EnemyMain,
        SpawnMarker = 'REINFORCEMENT_01',
        PreferredTarget = Army.Player2,
        AllowAfterCommand = true,
        Units = {
            {Blueprint = UnitBlueprints.Cybran.AssaultBot, Count = 4},
            {Blueprint = UnitBlueprints.Cybran.MobileArtillery, Count = 2},
            {Blueprint = UnitBlueprints.Cybran.MobileAA, Count = 1},
        },
        HardUnits = {
            {Blueprint = UnitBlueprints.Cybran.HeavyTankT2, Count = 1},
        },
    },

    WEST_WAVE_LIGHT = {
        Name = 'WEST_WAVE_LIGHT',
        Phase = 2,
        Army = Army.EnemyMain,
        SpawnMarker = 'WEST_ATTACK_01',
        AttackChain = 'CHAIN_WEST_ATTACK',
        PreferredTarget = Army.Player1,
        TrackPool = 'WestAttackUnits',
        AllowRepeat = true,
        Units = {
            {Blueprint = UnitBlueprints.Cybran.AssaultBot, Count = 4},
            {Blueprint = UnitBlueprints.Cybran.MobileAA, Count = 1},
            {Blueprint = UnitBlueprints.Cybran.LandScout, Count = 1},
        },
    },
    WEST_WAVE_MECH = {
        Name = 'WEST_WAVE_MECH',
        Phase = 2,
        Army = Army.EnemyMain,
        SpawnMarker = 'WEST_ATTACK_01',
        AttackChain = 'CHAIN_WEST_ATTACK',
        PreferredTarget = Army.Player1,
        TrackPool = 'WestAttackUnits',
        AllowRepeat = true,
        Units = {
            {Blueprint = UnitBlueprints.Cybran.AssaultBot, Count = 4},
            {Blueprint = UnitBlueprints.Cybran.MobileAA, Count = 1},
            {Blueprint = UnitBlueprints.Cybran.MobileArtillery, Count = 1},
        },
        NormalUnits = {
            {Blueprint = UnitBlueprints.Cybran.HeavyTankT2, Count = 1},
            {Blueprint = UnitBlueprints.Cybran.MobileAAT2, Count = 1},
        },
        HardUnits = {
            {Blueprint = UnitBlueprints.Cybran.HeavyTankT2, Count = 2},
        },
    },
    WEST_WAVE_ARTILLERY = {
        Name = 'WEST_WAVE_ARTILLERY',
        Phase = 2,
        Army = Army.EnemyMain,
        SpawnMarker = 'WEST_ATTACK_02',
        AttackChain = 'CHAIN_WEST_ATTACK',
        PreferredTarget = Army.Player1,
        TrackPool = 'WestAttackUnits',
        AllowRepeat = true,
        Units = {
            {Blueprint = UnitBlueprints.Cybran.AssaultBot, Count = 3},
            {Blueprint = UnitBlueprints.Cybran.MobileArtillery, Count = 3},
            {Blueprint = UnitBlueprints.Cybran.MobileAA, Count = 1},
        },
        NormalUnits = {
            {Blueprint = UnitBlueprints.Cybran.HeavyTankT2, Count = 1},
        },
        HardUnits = {
            {Blueprint = UnitBlueprints.Cybran.MobileAAT2, Count = 1},
            {Blueprint = UnitBlueprints.Cybran.HeavyTankT2, Count = 1},
        },
    },
    AIR_SCOUT = {
        Name = 'AIR_SCOUT',
        Phase = 2,
        Army = Army.EnemyMain,
        SpawnMarker = 'EAST_AIR_ATTACK_SPAWN',
        PreferredTarget = Army.Player1,
        TrackPool = 'EastAirUnits',
        Air = true,
        AirTargeting = true,
        AllowRepeat = true,
        Units = {
            {Blueprint = UnitBlueprints.Cybran.AirScout, Count = 1},
            {Blueprint = UnitBlueprints.Cybran.Interceptor, Count = 1},
        },
    },
    INTERCEPTOR_PATROL = {
        Name = 'INTERCEPTOR_PATROL',
        Phase = 2,
        Army = Army.EnemyMain,
        SpawnMarker = 'EAST_AIR_ATTACK_SPAWN',
        TrackPool = 'EastAirUnits',
        Air = true,
        PatrolChain = 'CHAIN_EAST_AIR_PATROL_01',
        AllowRepeat = true,
        Units = {
            {Blueprint = UnitBlueprints.Cybran.Interceptor, Count = 3},
        },
        HardUnits = {
            {Blueprint = UnitBlueprints.Cybran.Interceptor, Count = 2},
        },
    },
    BOMBER_STRIKE = {
        Name = 'BOMBER_STRIKE',
        Phase = 2,
        Army = Army.EnemyMain,
        SpawnMarker = 'EAST_AIR_ATTACK_SPAWN',
        PreferredTarget = Army.Player1,
        TrackPool = 'EastAirUnits',
        Air = true,
        AirTargeting = true,
        AllowRepeat = true,
        Units = {
            {Blueprint = UnitBlueprints.Cybran.Bomber, Count = 2},
            {Blueprint = UnitBlueprints.Cybran.Interceptor, Count = 1},
        },
        HardUnits = {
            {Blueprint = UnitBlueprints.Cybran.Interceptor, Count = 1},
            {Blueprint = UnitBlueprints.Cybran.Bomber, Count = 1},
        },
    },
    GUNSHIP_RAID = {
        Name = 'GUNSHIP_RAID',
        Phase = 2,
        Army = Army.EnemyMain,
        SpawnMarker = 'EAST_AIR_ATTACK_SPAWN',
        PreferredTarget = Army.Player2,
        TrackPool = 'EastAirUnits',
        Air = true,
        AirTargeting = true,
        AllowRepeat = true,
        Units = {
            {Blueprint = UnitBlueprints.Cybran.Gunship, Count = 1},
            {Blueprint = UnitBlueprints.Cybran.Interceptor, Count = 1},
        },
        NormalUnits = {
            {Blueprint = UnitBlueprints.Cybran.Gunship, Count = 1},
        },
        HardUnits = {
            {Blueprint = UnitBlueprints.Cybran.Gunship, Count = 1},
            {Blueprint = UnitBlueprints.Cybran.Interceptor, Count = 1},
        },
    },
    MIXED_AIR_ATTACK = {
        Name = 'MIXED_AIR_ATTACK',
        Phase = 2,
        Army = Army.EnemyMain,
        SpawnMarker = 'EAST_AIR_ATTACK_SPAWN',
        PreferredTarget = Army.Player1,
        TrackPool = 'EastAirUnits',
        Air = true,
        AirTargeting = true,
        AllowRepeat = true,
        Units = {
            {Blueprint = UnitBlueprints.Cybran.Interceptor, Count = 2},
            {Blueprint = UnitBlueprints.Cybran.Bomber, Count = 2},
        },
        NormalUnits = {
            {Blueprint = UnitBlueprints.Cybran.Gunship, Count = 1},
        },
        HardUnits = {
            {Blueprint = UnitBlueprints.Cybran.Interceptor, Count = 2},
            {Blueprint = UnitBlueprints.Cybran.Gunship, Count = 1},
        },
    },
    CENTRAL_RESPONSE_MAIN = {
        Name = 'CENTRAL_RESPONSE_MAIN',
        Phase = 2,
        Army = Army.EnemyMain,
        SpawnMarker = 'CENTRAL_RESPONSE_SPAWN',
        AttackChain = 'CHAIN_CENTRAL_RESPONSE',
        PreferredTarget = Army.Player1,
        TrackPool = 'CentralResponseUnits',
        Units = {
            {Blueprint = UnitBlueprints.Cybran.AssaultBot, Count = 6},
            {Blueprint = UnitBlueprints.Cybran.MobileAA, Count = 2},
            {Blueprint = UnitBlueprints.Cybran.MobileArtillery, Count = 2},
            {Blueprint = UnitBlueprints.Cybran.Engineer, Count = 1},
        },
        NormalUnits = {
            {Blueprint = UnitBlueprints.Cybran.HeavyTankT2, Count = 2},
        },
        HardUnits = {
            {Blueprint = UnitBlueprints.Cybran.HeavyTankT2, Count = 2},
            {Blueprint = UnitBlueprints.Cybran.MobileAAT2, Count = 1},
        },
    },
    CENTRAL_RESPONSE_FLANK = {
        Name = 'CENTRAL_RESPONSE_FLANK',
        Phase = 2,
        Army = Army.EnemyMain,
        SpawnMarker = 'CENTRAL_RESPONSE_SPAWN',
        AttackChain = 'CHAIN_CENTRAL_FLANK',
        PreferredTarget = Army.Player2,
        TrackPool = 'CentralResponseUnits',
        Units = {
            {Blueprint = UnitBlueprints.Cybran.AssaultBot, Count = 4},
            {Blueprint = UnitBlueprints.Cybran.MobileArtillery, Count = 1},
            {Blueprint = UnitBlueprints.Cybran.MobileAA, Count = 1},
            {Blueprint = UnitBlueprints.Cybran.HeavyTankT2, Count = 1},
        },
    },
    WEST_ADAPTIVE_REINFORCEMENT = {
        Name = 'WEST_ADAPTIVE_REINFORCEMENT',
        Phase = 2,
        Army = Army.EnemyMain,
        SpawnMarker = 'WEST_ATTACK_03',
        AttackChain = 'CHAIN_WEST_ATTACK',
        PreferredTarget = Army.Player1,
        TrackPool = 'WestAttackUnits',
        Units = {
            {Blueprint = UnitBlueprints.Cybran.AssaultBot, Count = 4},
            {Blueprint = UnitBlueprints.Cybran.MobileAA, Count = 1},
            {Blueprint = UnitBlueprints.Cybran.MobileArtillery, Count = 1},
        },
        NormalUnits = {
            {Blueprint = UnitBlueprints.Cybran.HeavyTankT2, Count = 1},
        },
        HardUnits = {
            {Blueprint = UnitBlueprints.Cybran.HeavyTankT2, Count = 1},
            {Blueprint = UnitBlueprints.Cybran.MobileAAT2, Count = 1},
        },
    },
    EAST_ADAPTIVE_REINFORCEMENT = {
        Name = 'EAST_ADAPTIVE_REINFORCEMENT',
        Phase = 2,
        Army = Army.EnemyMain,
        SpawnMarker = 'EAST_AIR_ATTACK_SPAWN',
        PreferredTarget = Army.Player1,
        TrackPool = 'EastAirUnits',
        Air = true,
        AirTargeting = true,
        Units = {
            {Blueprint = UnitBlueprints.Cybran.Interceptor, Count = 2},
            {Blueprint = UnitBlueprints.Cybran.Bomber, Count = 1},
            {Blueprint = UnitBlueprints.Cybran.Gunship, Count = 1},
        },
        HardUnits = {
            {Blueprint = UnitBlueprints.Cybran.Interceptor, Count = 2},
        },
    },


    PHASE3_ATTACK_WEST = {
        Name = 'PHASE3_ATTACK_WEST',
        Phase = 3,
        Army = Army.EnemyMain,
        SpawnMarker = 'PHASE3_ARTILLERY_CENTER',
        AttackChain = 'CHAIN_PHASE3_ATTACK_WEST',
        AllowRepeat = true,
        TrackPool = 'LandAttackUnits',
        Units = {
            {Blueprint = UnitBlueprints.Cybran.HeavyTankT2, Count = 3},
            {Blueprint = UnitBlueprints.Cybran.MobileAAT2, Count = 1},
            {Blueprint = UnitBlueprints.Cybran.MobileArtillery, Count = 1},
        },
        NormalUnits = {
            {Blueprint = UnitBlueprints.Cybran.SiegeAssaultT3, Count = 1},
        },
        HardUnits = {
            {Blueprint = UnitBlueprints.Cybran.HeavyTankT2, Count = 2},
            {Blueprint = UnitBlueprints.Cybran.SiegeAssaultT3, Count = 1},
        },
    },
    PHASE3_ATTACK_CENTER = {
        Name = 'PHASE3_ATTACK_CENTER',
        Phase = 3,
        Army = Army.EnemyMain,
        SpawnMarker = 'PHASE3_DEFENSE_CENTER',
        AttackChain = 'CHAIN_PHASE3_ATTACK_CENTER',
        AllowRepeat = true,
        TrackPool = 'LandAttackUnits',
        Units = {
            {Blueprint = UnitBlueprints.Cybran.HeavyTankT2, Count = 4},
            {Blueprint = UnitBlueprints.Cybran.MobileAAT2, Count = 2},
            {Blueprint = UnitBlueprints.Cybran.MobileArtillery, Count = 1},
        },
        NormalUnits = {
            {Blueprint = UnitBlueprints.Cybran.SiegeAssaultT3, Count = 1},
        },
        HardUnits = {
            {Blueprint = UnitBlueprints.Cybran.SiegeAssaultT3, Count = 1},
            {Blueprint = UnitBlueprints.Cybran.HeavyArtilleryT3, Count = 1},
        },
    },
    PHASE3_ATTACK_EAST = {
        Name = 'PHASE3_ATTACK_EAST',
        Phase = 3,
        Army = Army.EnemyMain,
        SpawnMarker = 'PHASE3_GATEWAY_CENTER',
        AttackChain = 'CHAIN_PHASE3_ATTACK_EAST',
        AllowRepeat = true,
        TrackPool = 'LandAttackUnits',
        Units = {
            {Blueprint = UnitBlueprints.Cybran.HeavyTankT2, Count = 3},
            {Blueprint = UnitBlueprints.Cybran.MobileAAT2, Count = 1},
            {Blueprint = UnitBlueprints.Cybran.MobileArtillery, Count = 1},
        },
        NormalUnits = {
            {Blueprint = UnitBlueprints.Cybran.SiegeAssaultT3, Count = 1},
        },
        HardUnits = {
            {Blueprint = UnitBlueprints.Cybran.HeavyTankT2, Count = 2},
            {Blueprint = UnitBlueprints.Cybran.SiegeAssaultT3, Count = 1},
        },
    },
    PHASE3_AIR_SUPPORT = {
        Name = 'PHASE3_AIR_SUPPORT',
        Phase = 3,
        Army = Army.EnemyMain,
        SpawnMarker = 'PHASE3_GATEWAY_CENTER',
        AllowRepeat = true,
        TrackPool = 'AirAttackUnits',
        Air = true,
        AirTargeting = true,
        Units = {
            {Blueprint = UnitBlueprints.Cybran.Interceptor, Count = 2},
            {Blueprint = UnitBlueprints.Cybran.Gunship, Count = 1},
        },
        NormalUnits = {
            {Blueprint = UnitBlueprints.Cybran.AirSuperiorityT3, Count = 1},
        },
        HardUnits = {
            {Blueprint = UnitBlueprints.Cybran.Gunship, Count = 1},
            {Blueprint = UnitBlueprints.Cybran.AirSuperiorityT3, Count = 1},
        },
    },
    PHASE3_GATEWAY_HEAVY = {
        Name = 'PHASE3_GATEWAY_HEAVY',
        Phase = 3,
        Army = Army.EnemyMain,
        SpawnMarker = 'PHASE3_REINFORCEMENT_GATEWAY',
        AttackChain = 'CHAIN_PHASE3_ATTACK_EAST',
        AllowRepeat = true,
        TrackPool = 'GatewayUnits',
        Units = {
            {Blueprint = UnitBlueprints.Cybran.HeavyTankT2, Count = 4},
            {Blueprint = UnitBlueprints.Cybran.MobileAAT2, Count = 1},
        },
        NormalUnits = {
            {Blueprint = UnitBlueprints.Cybran.SiegeAssaultT3, Count = 1},
        },
        HardUnits = {
            {Blueprint = UnitBlueprints.Cybran.SiegeAssaultT3, Count = 1},
        },
    },
    PHASE3_GATEWAY_SIEGE = {
        Name = 'PHASE3_GATEWAY_SIEGE',
        Phase = 3,
        Army = Army.EnemyMain,
        SpawnMarker = 'PHASE3_REINFORCEMENT_GATEWAY',
        AttackChain = 'CHAIN_PHASE3_ATTACK_CENTER',
        AllowRepeat = true,
        TrackPool = 'GatewayUnits',
        Units = {
            {Blueprint = UnitBlueprints.Cybran.HeavyTankT2, Count = 2},
            {Blueprint = UnitBlueprints.Cybran.MobileArtillery, Count = 2},
            {Blueprint = UnitBlueprints.Cybran.MobileAAT2, Count = 1},
        },
        NormalUnits = {
            {Blueprint = UnitBlueprints.Cybran.SiegeAssaultT3, Count = 1},
        },
        HardUnits = {
            {Blueprint = UnitBlueprints.Cybran.HeavyArtilleryT3, Count = 1},
        },
    },
    PHASE3_GATEWAY_LATE_T3 = {
        Name = 'PHASE3_GATEWAY_LATE_T3',
        Phase = 3,
        Army = Army.EnemyMain,
        SpawnMarker = 'PHASE3_REINFORCEMENT_GATEWAY',
        AttackChain = 'CHAIN_PHASE3_ATTACK_CENTER',
        AllowRepeat = true,
        TrackPool = 'GatewayUnits',
        Units = {
            {Blueprint = UnitBlueprints.Cybran.HeavyTankT2, Count = 2},
            {Blueprint = UnitBlueprints.Cybran.MobileAAT2, Count = 1},
            {Blueprint = UnitBlueprints.Cybran.SiegeAssaultT3, Count = 1},
        },
        NormalUnits = {
            {Blueprint = UnitBlueprints.Cybran.SiegeAssaultT3, Count = 1},
        },
        HardUnits = {
            {Blueprint = UnitBlueprints.Cybran.HeavyArtilleryT3, Count = 1},
        },
    },
    PHASE3_STRATEGIC_LAND = {
        Name = 'PHASE3_STRATEGIC_LAND',
        Phase = 3,
        Army = Army.EnemyMain,
        SpawnMarker = 'PHASE3_DEFENSE_CENTER',
        AttackChain = 'CHAIN_PHASE3_ATTACK_CENTER',
        AllowRepeat = true,
        TrackPool = 'LandAttackUnits',
        Units = {
            {Blueprint = UnitBlueprints.Cybran.HeavyTankT2, Count = 5},
            {Blueprint = UnitBlueprints.Cybran.MobileAAT2, Count = 2},
            {Blueprint = UnitBlueprints.Cybran.MobileArtillery, Count = 2},
        },
        NormalUnits = {
            {Blueprint = UnitBlueprints.Cybran.SiegeAssaultT3, Count = 2},
        },
        HardUnits = {
            {Blueprint = UnitBlueprints.Cybran.SiegeAssaultT3, Count = 1},
        },
    },
    PHASE3_STRATEGIC_AIR = {
        Name = 'PHASE3_STRATEGIC_AIR',
        Phase = 3,
        Army = Army.EnemyMain,
        SpawnMarker = 'PHASE3_GATEWAY_CENTER',
        AllowRepeat = true,
        TrackPool = 'AirAttackUnits',
        Air = true,
        AirTargeting = true,
        Units = {
            {Blueprint = UnitBlueprints.Cybran.Interceptor, Count = 3},
            {Blueprint = UnitBlueprints.Cybran.Gunship, Count = 2},
        },
        NormalUnits = {
            {Blueprint = UnitBlueprints.Cybran.AirSuperiorityT3, Count = 1},
        },
        HardUnits = {
            {Blueprint = UnitBlueprints.Cybran.AirSuperiorityT3, Count = 1},
            {Blueprint = UnitBlueprints.Cybran.StrategicBomberT3, Count = 1},
        },
    },
    PHASE3_EMERGENCY_LAND = {
        Name = 'PHASE3_EMERGENCY_LAND',
        Phase = 3,
        Army = Army.EnemyMain,
        SpawnMarker = 'PHASE3_DEFENSE_CENTER',
        AttackChain = 'CHAIN_PHASE3_FLANK_WEST',
        AllowRepeat = true,
        TrackPool = 'LandAttackUnits',
        Units = {
            {Blueprint = UnitBlueprints.Cybran.HeavyTankT2, Count = 7},
            {Blueprint = UnitBlueprints.Cybran.MobileAAT2, Count = 3},
            {Blueprint = UnitBlueprints.Cybran.MobileArtillery, Count = 2},
        },
        NormalUnits = {
            {Blueprint = UnitBlueprints.Cybran.SiegeAssaultT3, Count = 2},
        },
        HardUnits = {
            {Blueprint = UnitBlueprints.Cybran.SiegeAssaultT3, Count = 1},
            {Blueprint = UnitBlueprints.Cybran.HeavyArtilleryT3, Count = 1},
        },
    },
    PHASE3_EMERGENCY_AIR = {
        Name = 'PHASE3_EMERGENCY_AIR',
        Phase = 3,
        Army = Army.EnemyMain,
        SpawnMarker = 'PHASE3_GATEWAY_CENTER',
        AllowRepeat = true,
        TrackPool = 'AirAttackUnits',
        Air = true,
        AirTargeting = true,
        Units = {
            {Blueprint = UnitBlueprints.Cybran.Interceptor, Count = 3},
            {Blueprint = UnitBlueprints.Cybran.Gunship, Count = 2},
        },
        NormalUnits = {
            {Blueprint = UnitBlueprints.Cybran.AirSuperiorityT3, Count = 1},
        },
        HardUnits = {
            {Blueprint = UnitBlueprints.Cybran.StrategicBomberT3, Count = 1},
        },
    },
}

local MissionState = {
    CurrentPhase = 0,
    ActivePlayers = 0,
    Difficulty = 2,
    DifficultyName = 'Normal',
    Objectives = {},
    CompletedObjectives = {},
    MissionEnded = false,
    MissionStarted = false,
    PlayerCommanders = {},
    PlayerAlive = {},
    PlayerPresent = {},
    Targets = {},
    TargetDestroyed = {},
    Threads = {},
    Scale = {},

    ForwardGroups = {},
    SpawnedWaves = {},
    CancelledWaves = {},
    WavePressure = {
        Player1 = 0,
        Player2 = 0,
    },
    ReinforcementUnits = {},
    ReinforcementCounter = 0,

    ForwardObjectiveAssigned = false,
    RadarObjectiveAssigned = false,
    RadarDestroyed = false,
    RadarRewardApplied = false,
    CommandPostDestroyed = false,
    CounterattackStarted = false,
    CounterattackResolved = false,
    CounterattackUnits = {},
    CounterattackInitialCount = 0,
    Phase1Completed = false,

    Phase2 = {
        Started = false,
        WestCompleted = false,
        EastCompleted = false,
        WestCommandDestroyed = false,
        EastCommandDestroyed = false,
        CentralResponseTriggered = false,
        AdaptiveResponseTriggered = false,
        FirstCompletedSide = false,
        WestConvoysDestroyed = 0,
        WestConvoysArrived = 0,
        WestReinforcementReduced = false,
        RadarNetworkDestroyed = false,
        RadarRewardApplied = false,
        Finished = false,
        Phase3Started = false,
        WestGroups = {},
        EastGroups = {},
        RadarUnits = {},
        WestAttackUnits = {},
        EastAirUnits = {},
        ConvoyUnits = {},
        CentralResponseUnits = {},
        Convoys = {},
        ConvoyCounter = 0,
        AirRaidCounter = 0,
        PatrolCounter = 0,
        Limits = {},
    },

    Phase3 = {
        Started = false,
        ArtilleryDestroyed = false,
        DefenseNodeDestroyed = false,
        ReinforcementGatewayDestroyed = false,
        StrategicResponseTriggered = false,
        EmergencyResponseTriggered = false,
        RadarNetworkDestroyed = false,
        RadarRewardApplied = false,
        DataCoreDestroyed = false,
        IntelRewardApplied = false,
        ArtilleryWarningShown = false,
        FinaleUnlocked = false,
        Finished = false,
        CompletedPrimaryCount = 0,
        AttackCounter = 0,
        TargetSelectionCounter = 0,
        GatewayCounter = 0,
        TransportCounter = 0,
        BombardmentCounter = 0,
        DefenseRebuilds = 0,
        InitialDefenseStaticCount = 0,
        LastAttackedPlayer = false,
        Groups = {},
        RadarUnits = {},
        LandAttackUnits = {},
        AirAttackUnits = {},
        GatewayUnits = {},
        TransportUnits = {},
        Limits = {},
    },
}

local function Log(category, message)
    LOG(string.format('[OTS][%s] %s', category, message))
end

local function DebugLog(category, message)
    if DEBUG then
        Log('DEBUG/' .. category, message)
    end
end

local function IsUnitAlive(unit)
    return unit ~= nil and not unit.Dead and not unit:BeenDestroyed()
end

local function CountLivingUnits(units)
    local count = 0
    if not units then
        return 0
    end
    for _, unit in ipairs(units) do
        if IsUnitAlive(unit) then
            count = count + 1
        end
    end
    return count
end

local function AppendUnits(destination, units)
    if not units then
        return destination
    end
    for _, unit in ipairs(units) do
        table.insert(destination, unit)
    end
    return destination
end

local function PruneLivingUnits(units)
    local result = {}
    if units then
        for _, unit in ipairs(units) do
            if IsUnitAlive(unit) then
                table.insert(result, unit)
            end
        end
    end
    return result
end

local function AnyUnitAlive(units)
    return CountLivingUnits(units) > 0
end

local function ClampDifficulty(value)
    value = tonumber(value) or 2
    if value < 1 then
        return 1
    end
    if value > 3 then
        return 3
    end
    return value
end

local function GetArmyNameAtIndex(index)
    local armies = ListArmies()
    if not armies then
        return nil
    end
    return armies[index]
end

local function IsArmyActive(index, expectedName)
    local name = GetArmyNameAtIndex(index)
    if not name then
        return false
    end
    return expectedName == nil or name == expectedName
end

function GetActivePlayerCount()
    local count = 0
    if IsArmyActive(ScenarioInfo.Player1, Army.Player1) then
        count = count + 1
    end
    if IsArmyActive(ScenarioInfo.Player2, Army.Player2) then
        count = count + 1
    end
    return count
end

local function GetPlayerScale()
    return PlayerScaling[MissionState.ActivePlayers] or PlayerScaling[1]
end

local function GetDifficultyScale()
    return DifficultyScaling[MissionState.Difficulty] or DifficultyScaling[2]
end

function GetScaledUnitCount(baseCount)
    if baseCount <= 0 then
        return 0
    end
    local value = baseCount * GetPlayerScale().EnemyMultiplier * GetDifficultyScale().UnitMultiplier
    return math.max(1, math.floor(value + 0.5))
end

function GetScaledDelay(baseDelay)
    local value = baseDelay * GetPlayerScale().DelayMultiplier * GetDifficultyScale().DelayMultiplier
    if DEBUG then
        return math.max(0.25, value * 0.10)
    end
    return value
end

function GetScaledResourceMultiplier()
    return GetPlayerScale().ResourceMultiplier * GetDifficultyScale().ResourceMultiplier
end

local function GetPhase2Limits()
    local byDifficulty = {
        [1] = {West = 12, East = 6, Convoy = 6, Central = 12},
        [2] = {West = 16, East = 12, Convoy = 10, Central = 18},
        [3] = {West = 22, East = 18, Convoy = 16, Central = 32},
    }
    local selected = byDifficulty[MissionState.Difficulty] or byDifficulty[2]
    local coop = MissionState.ActivePlayers >= 2

    return {
        MaxActiveWestAttackUnits = selected.West + (coop and 4 or 0),
        MaxActiveEastAirUnits = selected.East + (coop and 4 or 0),
        MaxActiveConvoyUnits = selected.Convoy + (coop and 2 or 0),
        MaxActiveCentralResponseUnits = selected.Central + (coop and 4 or 0),
    }
end

local function GetPhase3Limits()
    local byDifficulty = {
        [1] = {Land = 30, Air = 10, Reinforcement = 18},
        [2] = {Land = 42, Air = 16, Reinforcement = 28},
        [3] = {Land = 54, Air = 24, Reinforcement = 38},
    }
    local selected = byDifficulty[MissionState.Difficulty] or byDifficulty[2]
    local coop = MissionState.ActivePlayers >= 2

    return {
        Phase3MaxLandAttackUnits = math.floor(selected.Land * (coop and 1.45 or 1.00) + 0.5),
        Phase3MaxAirAttackUnits = math.floor(selected.Air * (coop and 1.50 or 1.00) + 0.5),
        Phase3MaxReinforcementUnits = math.floor(selected.Reinforcement * (coop and 1.50 or 1.00) + 0.5),
    }
end

local function GetMarkerPosition(markerName)
    local marker = ScenarioUtils.GetMarker(markerName)
    if not marker or not marker.position then
        Log('FAIL', 'Required marker missing: ' .. tostring(markerName))
        return nil
    end
    return marker.position
end

local function GetPriorityAirTargetPosition(armyName)
    local fallbackMarker = armyName == Army.Player2 and 'P2_ATTACK_TARGET' or 'P1_ATTACK_TARGET'
    local fallback = GetMarkerPosition(fallbackMarker)
    local brain = GetArmyBrain(armyName)
    if not brain or not categories then
        return fallback
    end

    local priorityCategories = {
        categories.STRUCTURE * categories.ENERGYPRODUCTION,
        categories.FACTORY,
        categories.EXPERIMENTAL,
        categories.MOBILE,
    }

    local commander = MissionState.PlayerCommanders[armyName]
    for _, category in ipairs(priorityCategories) do
        local units = brain:GetListOfUnits(category, false) or {}
        for _, unit in ipairs(units) do
            if IsUnitAlive(unit) and unit ~= commander then
                return unit:GetPosition()
            end
        end
    end

    return fallback
end

local function SpawnUnitAtPosition(armyName, blueprintId, position, heading, altitude)
    if not position then
        return nil
    end

    local brain = GetArmyBrain(armyName)
    if not brain then
        Log('FAIL', 'Army brain unavailable: ' .. tostring(armyName))
        return nil
    end

    local terrainHeight = GetTerrainHeight(position[1], position[3])
    local unit = CreateUnitHPR(
        blueprintId,
        armyName,
        position[1], terrainHeight + (altitude or 0), position[3],
        heading or 0, 0, 0
    )

    if not unit then
        Log('FAIL', string.format('Failed to spawn %s for %s', blueprintId, armyName))
    end

    return unit
end

local function SpawnUnitAtMarker(armyName, blueprintId, markerName, heading)
    return SpawnUnitAtPosition(armyName, blueprintId, GetMarkerPosition(markerName), heading)
end

local function SpawnOffsetUnit(armyName, blueprintId, markerName, offsetX, offsetZ, heading, altitude)
    local base = GetMarkerPosition(markerName)
    if not base then
        return nil
    end

    return SpawnUnitAtPosition(
        armyName,
        blueprintId,
        {base[1] + offsetX, base[2], base[3] + offsetZ},
        heading,
        altitude
    )
end

local function AlignUnitsToTerrain(units)
    if not units then
        return
    end
    for _, unit in ipairs(units) do
        if IsUnitAlive(unit) then
            local position = unit:GetPosition()
            Warp(unit, {
                position[1],
                GetTerrainHeight(position[1], position[3]),
                position[3],
            })
        end
    end
end

local function SpawnEditorGroup(armyName, groupName)
    local units = ScenarioUtils.CreateArmyGroup(armyName, groupName)
    AlignUnitsToTerrain(units)
    DebugLog('GROUP', string.format('Spawned %s (%d units)', groupName, table.getn(units)))
    return units
end

local function GetNamedArmyUnit(armyName, unitName)
    local brain = GetArmyBrain(armyName)
    if not brain then
        Log('FAIL', 'Army brain unavailable while resolving named unit: ' .. tostring(armyName))
        return nil
    end

    local armyIndex = brain:GetArmyIndex()
    local unitNames = ScenarioInfo.UnitNames and ScenarioInfo.UnitNames[armyIndex]
    local unit = unitNames and unitNames[unitName]
    if not unit then
        Log('FAIL', string.format('Named unit missing: %s/%s', tostring(armyName), tostring(unitName)))
    end
    return unit
end

local function AddThread(name, thread)
    if thread then
        MissionState.Threads[name] = thread
    end
    return thread
end

local function StopMissionThread(name)
    local thread = MissionState.Threads[name]
    if thread then
        KillThread(thread)
        MissionState.Threads[name] = nil
    end
end

local function CountLivingPlayerCommanders()
    local count = 0
    for armyName, commander in pairs(MissionState.PlayerCommanders) do
        if MissionState.PlayerPresent[armyName] and MissionState.PlayerAlive[armyName] and IsUnitAlive(commander) then
            count = count + 1
        end
    end
    return count
end

local function MarkObjectiveCompleted(key)
    MissionState.CompletedObjectives[key] = true
end

local function SetObjectiveManualResultIfActive(objective, result)
    if objective and objective.Active then
        objective:ManualResult(result)
    end
end

local function ConfigureAlliances()
    local activePlayers = {
        {Name = Army.Player1, Index = ScenarioInfo.Player1},
    }

    if IsArmyActive(ScenarioInfo.Player2, Army.Player2) then
        table.insert(activePlayers, {Name = Army.Player2, Index = ScenarioInfo.Player2})
    end

    if table.getn(activePlayers) == 2 then
        SetAlliance(activePlayers[1].Index, activePlayers[2].Index, 'Ally')
        SetAlliance(activePlayers[2].Index, activePlayers[1].Index, 'Ally')
    end

    SetAlliance(ScenarioInfo.CybranMain, ScenarioInfo.CybranOutpost, 'Ally')
    SetAlliance(ScenarioInfo.CybranOutpost, ScenarioInfo.CybranMain, 'Ally')

    for _, player in ipairs(activePlayers) do
        SetAlliance(player.Index, ScenarioInfo.CybranMain, 'Enemy')
        SetAlliance(ScenarioInfo.CybranMain, player.Index, 'Enemy')
        SetAlliance(player.Index, ScenarioInfo.CybranOutpost, 'Enemy')
        SetAlliance(ScenarioInfo.CybranOutpost, player.Index, 'Enemy')
        SetAlliance(player.Index, ScenarioInfo.Neutral, 'Neutral')
        SetAlliance(ScenarioInfo.Neutral, player.Index, 'Neutral')
    end

    SetAlliance(ScenarioInfo.CybranMain, ScenarioInfo.Neutral, 'Neutral')
    SetAlliance(ScenarioInfo.Neutral, ScenarioInfo.CybranMain, 'Neutral')
    SetAlliance(ScenarioInfo.CybranOutpost, ScenarioInfo.Neutral, 'Neutral')
    SetAlliance(ScenarioInfo.Neutral, ScenarioInfo.CybranOutpost, 'Neutral')
end

local function OnPlayerCommanderKilled(deadCommander)
    if MissionState.MissionEnded then
        return
    end

    for armyName, commander in pairs(MissionState.PlayerCommanders) do
        if commander == deadCommander then
            if MissionState.PlayerAlive[armyName] then
                MissionState.PlayerAlive[armyName] = false
                Log('PLAYER', armyName .. ' ACU destroyed')
            end
            break
        end
    end

    if CountLivingPlayerCommanders() == 0 then
        MissionFailure('All active player ACUs have been destroyed')
    else
        Log('PLAYER', 'Mission continues with surviving commander')
    end
end

local function PlayerPresenceThread()
    while not MissionState.MissionEnded do
        WaitSeconds(5)

        local slots = {
            {Name = Army.Player1, Index = ScenarioInfo.Player1},
            {Name = Army.Player2, Index = ScenarioInfo.Player2},
        }

        local changed = false
        for _, slot in ipairs(slots) do
            if MissionState.PlayerPresent[slot.Name] and not IsArmyActive(slot.Index, slot.Name) then
                MissionState.PlayerPresent[slot.Name] = false
                changed = true
                Log('PLAYER', slot.Name .. ' is no longer present; excluding it from defeat checks')
            end
        end

        if changed and CountLivingPlayerCommanders() == 0 then
            MissionFailure('No active player commanders remain')
            return
        end
    end
end

local function GetAvailableWaveTargets()
    local targets = {}

    if MissionState.PlayerPresent[Army.Player1]
        and MissionState.PlayerAlive[Army.Player1]
        and IsUnitAlive(MissionState.PlayerCommanders[Army.Player1])
    then
        table.insert(targets, Army.Player1)
    end

    if MissionState.PlayerPresent[Army.Player2]
        and MissionState.PlayerAlive[Army.Player2]
        and IsUnitAlive(MissionState.PlayerCommanders[Army.Player2])
    then
        table.insert(targets, Army.Player2)
    end

    return targets
end

local function SelectWaveTarget(preferredTarget)
    local available = GetAvailableWaveTargets()
    if table.getn(available) == 0 then
        return nil
    end

    for _, target in ipairs(available) do
        if target == preferredTarget then
            MissionState.WavePressure[target] = (MissionState.WavePressure[target] or 0) + 1
            return target
        end
    end

    local selected = available[1]
    local selectedPressure = MissionState.WavePressure[selected] or 0
    for _, target in ipairs(available) do
        local pressure = MissionState.WavePressure[target] or 0
        if pressure < selectedPressure then
            selected = target
            selectedPressure = pressure
        end
    end

    MissionState.WavePressure[selected] = selectedPressure + 1
    return selected
end

local function IssueWaveOrders(units, target, air, config)
    if not units or table.getn(units) == 0 then
        return
    end

    if config and config.AttackChain then
        for _, position in ipairs(ScenarioUtils.ChainToPositions(config.AttackChain)) do
            IssueAggressiveMove(units, position)
        end
    end

    if not target then
        return
    end

    if air then
        local targetPosition = config and config.AirTargeting
            and GetPriorityAirTargetPosition(target)
            or GetMarkerPosition(target == Army.Player2 and 'P2_ATTACK_TARGET' or 'P1_ATTACK_TARGET')
        if targetPosition then
            IssueAggressiveMove(units, targetPosition)
        end
        return
    end

    if not (config and config.AttackChain) then
        local chainName = target == Army.Player2 and 'CHAIN_FORWARD_TO_P2' or 'CHAIN_FORWARD_TO_P1'
        for _, position in ipairs(ScenarioUtils.ChainToPositions(chainName)) do
            IssueAggressiveMove(units, position)
        end
    end
end

local function SpawnWaveUnits(config)
    local units = {}
    local spawnIndex = 0

    local function SpawnComposition(composition)
        if not composition then
            return
        end

        for _, unitSpec in ipairs(composition) do
            local count = GetScaledUnitCount(unitSpec.Count)
            for _ = 1, count do
                spawnIndex = spawnIndex + 1
                local column = math.mod(spawnIndex - 1, 4)
                local row = math.floor((spawnIndex - 1) / 4)
                local unit = SpawnOffsetUnit(
                    config.Army,
                    unitSpec.Blueprint,
                    config.SpawnMarker,
                    (column - 1.5) * 4,
                    row * 4,
                    3.141592653589793,
                    config.Air and 25 or 0
                )
                if unit then
                    table.insert(units, unit)
                end
            end
        end
    end

    SpawnComposition(config.Units)
    if MissionState.Difficulty >= 2 then
        SpawnComposition(config.NormalUnits)
    end
    if MissionState.Difficulty == 3 then
        SpawnComposition(config.HardUnits)
    end

    return units
end

function SpawnAttackWave(configOrName)
    if MissionState.MissionEnded then
        return {}
    end

    local config = configOrName
    if type(configOrName) == 'string' then
        config = WaveDefinitions[configOrName]
    end

    if not config then
        Log('WARN', 'Unknown wave config: ' .. tostring(configOrName))
        return {}
    end

    local requiredPhase = config.Phase or 1
    if MissionState.CurrentPhase ~= requiredPhase then
        return {}
    end

    local name = config.Name or 'UnnamedWave'
    if MissionState.CancelledWaves[name] then
        Log('WAVE', 'Skip cancelled wave ' .. name)
        return {}
    end

    if MissionState.SpawnedWaves[name] and not config.AllowRepeat then
        DebugLog('WAVE', 'Duplicate wave ignored: ' .. name)
        return {}
    end

    if requiredPhase == 1 and MissionState.CommandPostDestroyed and not config.AllowAfterCommand then
        DebugLog('WAVE', 'Wave suppressed after Command Post destruction: ' .. name)
        return {}
    end

    MissionState.SpawnedWaves[name] = true
    if requiredPhase == 2 then
        Log('PHASE2/WAVE', 'Spawn ' .. name)
    elseif requiredPhase == 3 then
        Log('PHASE3/WAVE', 'Spawn ' .. name)
    else
        Log('WAVE', 'Spawn ' .. name)
    end

    local units = SpawnWaveUnits(config)
    if table.getn(units) == 0 then
        Log('WARN', 'Wave spawned no units: ' .. name)
        return units
    end

    local brain = GetArmyBrain(config.Army)
    local platoon = nil
    if brain then
        platoon = brain:MakePlatoon(name, 'NoPlan')
        brain:AssignUnitsToPlatoon(platoon, units, 'Attack', config.Air and 'NoFormation' or 'AttackFormation')
    end

    if config.PatrolChain and platoon then
        ScenarioFramework.PlatoonPatrolChain(platoon, config.PatrolChain)
    elseif config.SplitTargets and table.getn(GetAvailableWaveTargets()) >= 2 then
        local p1Units = {}
        local p2Units = {}
        for index, unit in ipairs(units) do
            if math.mod(index, 2) == 0 then
                table.insert(p2Units, unit)
            else
                table.insert(p1Units, unit)
            end
        end

        if table.getn(p1Units) > 0 then
            Log('WAVE', 'Target Player1')
            IssueWaveOrders(p1Units, Army.Player1, config.Air, config)
        end
        if table.getn(p2Units) > 0 then
            Log('WAVE', 'Target Player2')
            IssueWaveOrders(p2Units, Army.Player2, config.Air, config)
        end
    else
        local target = SelectWaveTarget(config.PreferredTarget)
        if target then
            Log('WAVE', 'Target ' .. target)
            IssueWaveOrders(units, target, config.Air, config)
        elseif not config.PatrolChain then
            IssueWaveOrders(units, nil, config.Air, config)
        end
    end

    if config.Reinforcement then
        AppendUnits(MissionState.ReinforcementUnits, units)
    end

    if requiredPhase == 2 and config.TrackPool and MissionState.Phase2[config.TrackPool] then
        AppendUnits(MissionState.Phase2[config.TrackPool], units)
    elseif requiredPhase == 3 and config.TrackPool and MissionState.Phase3[config.TrackPool] then
        AppendUnits(MissionState.Phase3[config.TrackPool], units)
    end

    return units
end

local function WaitWhilePhase1(baseSeconds)
    local remaining = GetScaledDelay(baseSeconds)
    while remaining > 0 do
        if MissionState.MissionEnded or MissionState.CurrentPhase ~= 1 or MissionState.Phase1Completed then
            return false
        end
        local slice = math.min(5, remaining)
        WaitSeconds(slice)
        remaining = remaining - slice
    end
    return true
end

local function Phase1WaveTimelineThread()
    if not WaitWhilePhase1(120) then return end
    SpawnAttackWave('Phase1_Wave_01')

    if not WaitWhilePhase1(150) then return end
    SpawnAttackWave('Phase1_Wave_02')

    if not WaitWhilePhase1(160) then return end
    SpawnAttackWave('Phase1_Wave_03')

    if not WaitWhilePhase1(140) then return end
    if not MissionState.RadarDestroyed then
        SpawnAttackWave('Phase1_Wave_04')
    else
        Log('WAVE', 'Air harassment cancelled because Forward Radar is offline')
    end
end

local function ForwardReinforcementThread()
    if not WaitWhilePhase1(300) then
        return
    end

    while not MissionState.MissionEnded
        and MissionState.CurrentPhase == 1
        and not MissionState.CommandPostDestroyed
    do
        MissionState.ReinforcementUnits = PruneLivingUnits(MissionState.ReinforcementUnits)

        local production = MissionState.ForwardGroups.Production or {}
        if not AnyUnitAlive(production) then
            Log('WAVE', 'Forward production destroyed; reinforcements stopped')
            return
        end

        local maxActive = math.floor(10 * GetPlayerScale().EnemyMultiplier + 0.5)
        if table.getn(MissionState.ReinforcementUnits) < maxActive then
            MissionState.ReinforcementCounter = MissionState.ReinforcementCounter + 1
            local wave = {
                Name = 'Phase1_Reinforcement_' .. tostring(MissionState.ReinforcementCounter),
                Army = Army.EnemyOutpost,
                SpawnMarker = MissionState.ReinforcementCounter % 2 == 0
                    and 'CYBRAN_FORWARD_SPAWN_EAST'
                    or 'CYBRAN_FORWARD_SPAWN_WEST',
                AllowRepeat = true,
                Reinforcement = true,
                PreferredTarget = MissionState.ReinforcementCounter % 2 == 0
                    and Army.Player2
                    or Army.Player1,
                Units = {
                    {Blueprint = UnitBlueprints.Cybran.AssaultBot, Count = 2},
                    {Blueprint = UnitBlueprints.Cybran.MobileAA, Count = 1},
                },
            }
            SpawnAttackWave(wave)
        end

        if not WaitWhilePhase1(130) then
            return
        end
    end
end

local function ApplyRadarDisruption()
    if MissionState.RadarRewardApplied then
        return
    end

    MissionState.RadarRewardApplied = true
    MissionState.RadarDestroyed = true
    MissionState.CancelledWaves.Phase1_Wave_04 = true
    Log('OBJECTIVE', 'Forward Radar destroyed; air harassment coordination disrupted')
    ScenarioFramework.Dialogue(Dialogues.RadarDestroyed)
end

local function OnRadarDestroyed()
    if MissionState.MissionEnded or MissionState.RadarDestroyed then
        return
    end

    MissionState.RadarDestroyed = true
    MissionState.TargetDestroyed.Radar = true
    ApplyRadarDisruption()
end

local function CreateRadarObjective()
    if MissionState.RadarObjectiveAssigned then
        return
    end

    MissionState.RadarObjectiveAssigned = true
    local radar = MissionState.Targets.Radar
    if not radar then
        Log('WARN', 'Radar target missing; secondary objective skipped')
        return
    end

    local alreadyDestroyed = not IsUnitAlive(radar)
    MissionState.Objectives.Radar = Objectives.Kill(
        'secondary',
        alreadyDestroyed and 'complete' or 'incomplete',
        'Destroy Cybran Radar',
        'Destroy the Cybran radar to disrupt enemy air coordination.',
        {
            Units = {radar},
            MarkUnits = true,
            AlwaysVisible = true,
            ShowFaction = 'Cybran',
        }
    )

    if alreadyDestroyed then
        MarkObjectiveCompleted('Radar')
        ApplyRadarDisruption()
        return
    end

    MissionState.Objectives.Radar:AddResultCallback(
        function(success)
            if MissionState.MissionEnded then
                return
            end
            if success then
                MarkObjectiveCompleted('Radar')
                ApplyRadarDisruption()
            end
        end
    )
end

function StartCounterattack()
    if MissionState.MissionEnded
        or MissionState.CurrentPhase ~= 1
        or MissionState.CounterattackStarted
    then
        return
    end

    MissionState.CounterattackStarted = true
    Log('COUNTER', 'Starting Cybran counterattack')
    ScenarioFramework.Dialogue(Dialogues.Counterattack)

    local counterUnits = {}
    AppendUnits(counterUnits, SpawnAttackWave(WaveDefinitions.Counterattack_West))
    AppendUnits(counterUnits, SpawnAttackWave(WaveDefinitions.Counterattack_East))

    MissionState.CounterattackUnits = counterUnits
    MissionState.CounterattackInitialCount = table.getn(counterUnits)

    if MissionState.CounterattackInitialCount == 0 then
        Log('COUNTER', 'No counterattack units spawned; resolving safely')
        MissionState.CounterattackResolved = true
        CompletePhase1()
        return
    end

    ScenarioFramework.CreateGroupDeathTrigger(
        function()
            if not MissionState.CounterattackResolved then
                MissionState.CounterattackResolved = true
                CompletePhase1()
            end
        end,
        counterUnits,
        'OTS_COUNTERATTACK_ALL_DESTROYED'
    )

    AddThread(
        'CounterattackMonitor',
        ForkThread(
            function()
                local threshold = math.max(1, math.ceil(MissionState.CounterattackInitialCount * 0.30))
                while not MissionState.MissionEnded
                    and MissionState.CurrentPhase == 1
                    and not MissionState.CounterattackResolved
                do
                    WaitSeconds(5)
                    local alive = CountLivingUnits(MissionState.CounterattackUnits)
                    if alive <= threshold then
                        MissionState.CounterattackResolved = true
                        Log('COUNTER', string.format('Counterattack broken: %d/%d units remain', alive, MissionState.CounterattackInitialCount))
                        CompletePhase1()
                        return
                    end
                end
            end
        )
    )
end

local function CounterattackDelayThread()
    WaitSeconds(GetScaledDelay(20))
    if not MissionState.MissionEnded and MissionState.CurrentPhase == 1 then
        StartCounterattack()
    end
end

local function HandleForwardCommandDestroyed()
    if MissionState.MissionEnded or MissionState.CommandPostDestroyed then
        return
    end

    MissionState.CommandPostDestroyed = true
    MissionState.TargetDestroyed.ForwardCommand = true

    if MissionState.CurrentPhase == 0 then
        StartPhase1()
    end
    MarkObjectiveCompleted('ForwardCommand')

    SetObjectiveManualResultIfActive(MissionState.Objectives.ForwardCommand, true)

    Log('OBJECTIVE', 'Forward Command Post destroyed')
    ScenarioFramework.Dialogue(Dialogues.CommandDestroyed)

    AddThread('CounterattackDelay', ForkThread(CounterattackDelayThread))
end

function ActivateForwardObjective(source)
    if MissionState.MissionEnded or MissionState.ForwardObjectiveAssigned then
        return
    end

    MissionState.ForwardObjectiveAssigned = true
    Log('OBJECTIVE', 'Forward Outpost discovered via ' .. tostring(source or 'mission flow'))
    ScenarioFramework.Dialogue(Dialogues.ForwardDiscovered)

    local commandPost = MissionState.Targets.ForwardCommand
    if not commandPost then
        MissionFailure('Forward Command Post target missing')
        return
    end

    local alreadyDestroyed = not IsUnitAlive(commandPost)
    MissionState.Objectives.ForwardCommand = Objectives.Kill(
        'primary',
        alreadyDestroyed and 'complete' or 'incomplete',
        'Destroy the Forward Command Post',
        'Destroy the Cybran forward command facility and secure the southern sector.',
        {
            Units = {commandPost},
            MarkUnits = true,
            AlwaysVisible = true,
            ShowFaction = 'Cybran',
        }
    )

    CreateRadarObjective()

    if alreadyDestroyed then
        Log('OBJECTIVE', 'Command Post was destroyed before objective activation')
        HandleForwardCommandDestroyed()
        return
    end

    MissionState.Objectives.ForwardCommand:AddResultCallback(
        function(success)
            if MissionState.MissionEnded then
                return
            end

            if success then
                HandleForwardCommandDestroyed()
            else
                MissionFailure('Forward Command Post objective failed')
            end
        end
    )
end

local function ForwardDiscoveryTimeoutThread()
    if not WaitWhilePhase1(480) then
        return
    end

    if not MissionState.ForwardObjectiveAssigned then
        ActivateForwardObjective('maximum discovery timer')
    end
end

local function RegisterForwardDiscoveryTriggers()
    local function RegisterForPlayer(armyName, armyIndex, triggerName)
        if not IsArmyActive(armyIndex, armyName) then
            return
        end

        local brain = GetArmyBrain(armyName)
        if not brain then
            return
        end

        ScenarioFramework.CreateAreaTrigger(
            function()
                ActivateForwardObjective('area trigger: ' .. armyName)
            end,
            'AREA_FORWARD_DISCOVERY',
            categories.ALLUNITS,
            true,
            false,
            brain,
            1,
            true,
            triggerName
        )
    end

    RegisterForPlayer(Army.Player1, ScenarioInfo.Player1, 'OTS_FORWARD_DISCOVERY_P1')
    RegisterForPlayer(Army.Player2, ScenarioInfo.Player2, 'OTS_FORWARD_DISCOVERY_P2')

    AddThread('ForwardDiscoveryTimeout', ForkThread(ForwardDiscoveryTimeoutThread))
end


local function NewPhase2State()
    return {
        Started = false,
        WestCompleted = false,
        EastCompleted = false,
        WestCommandDestroyed = false,
        EastCommandDestroyed = false,
        CentralResponseTriggered = false,
        AdaptiveResponseTriggered = false,
        FirstCompletedSide = false,
        WestConvoysDestroyed = 0,
        WestConvoysArrived = 0,
        WestReinforcementReduced = false,
        RadarNetworkDestroyed = false,
        RadarRewardApplied = false,
        Finished = false,
        Phase3Started = false,
        WestGroups = {},
        EastGroups = {},
        RadarUnits = {},
        WestAttackUnits = {},
        EastAirUnits = {},
        ConvoyUnits = {},
        CentralResponseUnits = {},
        Convoys = {},
        ConvoyCounter = 0,
        AirRaidCounter = 0,
        PatrolCounter = 0,
        Limits = {},
    }
end

local function WaitWhilePhase2(baseSeconds, side)
    local remaining = GetScaledDelay(baseSeconds)
    while remaining > 0 do
        if MissionState.MissionEnded
            or MissionState.CurrentPhase ~= 2
            or MissionState.Phase2.Finished
        then
            return false
        end

        if side == 'West' and MissionState.Phase2.WestCompleted then
            return false
        end
        if side == 'East' and MissionState.Phase2.EastCompleted then
            return false
        end

        local slice = math.min(5, remaining)
        WaitSeconds(slice)
        remaining = remaining - slice
    end
    return true
end

local function DistanceSquared(a, b)
    if not a or not b then
        return 999999999
    end
    local dx = a[1] - b[1]
    local dz = a[3] - b[3]
    return dx * dx + dz * dz
end

local function SpawnPhase2Group(groupName)
    return SpawnEditorGroup(Army.EnemyMain, groupName)
end

local function ProtectObjectiveStructure(unit, customName)
    if not IsUnitAlive(unit) then
        return
    end
    unit:SetCapturable(false)
    unit:SetReclaimable(false)
    unit:SetCustomName(customName)
end

local function OnPhase2RadarNetworkDestroyed()
    local phase = MissionState.Phase2
    if phase.RadarRewardApplied then
        return
    end

    phase.RadarNetworkDestroyed = true
    phase.RadarRewardApplied = true
    MarkObjectiveCompleted('Phase2RadarNetwork')
    SetObjectiveManualResultIfActive(MissionState.Objectives.Phase2RadarNetwork, true)
    Log('EAST', 'Radar network destroyed; air raid cadence and patrol coverage reduced')

    if phase.Started and not MissionState.MissionEnded then
        ScenarioFramework.Dialogue(Dialogues.Phase2RadarDestroyed)
    end
end

local function OnPhase2WestCommandDestroyed()
    local phase = MissionState.Phase2
    phase.WestCommandDestroyed = true
    if phase.Started then
        CompleteWestObjective()
    else
        Log('OBJECTIVE', 'West objective structure destroyed before Phase 2 activation')
    end
end

local function OnPhase2EastCommandDestroyed()
    local phase = MissionState.Phase2
    phase.EastCommandDestroyed = true
    if phase.Started then
        CompleteEastObjective()
    else
        Log('OBJECTIVE', 'East objective structure destroyed before Phase 2 activation')
    end
end

local function SetupPhase2Garrison(units, platoonName, patrolChain)
    if not units or table.getn(units) == 0 then
        return
    end
    local brain = GetArmyBrain(Army.EnemyMain)
    if not brain then
        return
    end
    local platoon = brain:MakePlatoon(platoonName, 'NoPlan')
    brain:AssignUnitsToPlatoon(platoon, units, 'Attack', 'AttackFormation')
    ScenarioFramework.PlatoonPatrolChain(platoon, patrolChain)
end

local function InitializePhase2EnemyForces()
    local phase = MissionState.Phase2

    phase.WestGroups.Production = SpawnPhase2Group('WEST_PRODUCTION_BASE')
    if MissionState.Difficulty >= 2 then
        AppendUnits(phase.WestGroups.Production, SpawnPhase2Group('WEST_PRODUCTION_NORMAL'))
    end
    if MissionState.Difficulty == 3 then
        AppendUnits(phase.WestGroups.Production, SpawnPhase2Group('WEST_PRODUCTION_HARD'))
    end
    phase.WestGroups.Economy = SpawnPhase2Group('WEST_ECONOMY')
    phase.WestGroups.Defense = SpawnPhase2Group('WEST_DEFENSE_BASE')
    if MissionState.Difficulty >= 2 then
        AppendUnits(phase.WestGroups.Defense, SpawnPhase2Group('WEST_DEFENSE_NORMAL'))
    end
    if MissionState.Difficulty == 3 then
        AppendUnits(phase.WestGroups.Defense, SpawnPhase2Group('WEST_DEFENSE_HARD'))
    end
    phase.WestGroups.Engineers = SpawnPhase2Group('WEST_ENGINEERS')
    phase.WestGroups.Garrison = SpawnPhase2Group('WEST_GARRISON')

    phase.EastGroups.Production = SpawnPhase2Group('EAST_PRODUCTION_BASE')
    if MissionState.Difficulty >= 2 then
        AppendUnits(phase.EastGroups.Production, SpawnPhase2Group('EAST_PRODUCTION_NORMAL'))
    end
    if MissionState.Difficulty == 3 then
        AppendUnits(phase.EastGroups.Production, SpawnPhase2Group('EAST_PRODUCTION_HARD'))
    end
    phase.EastGroups.Economy = SpawnPhase2Group('EAST_ECONOMY')
    phase.EastGroups.Defense = SpawnPhase2Group('EAST_DEFENSE_BASE')
    if MissionState.Difficulty >= 2 then
        AppendUnits(phase.EastGroups.Defense, SpawnPhase2Group('EAST_DEFENSE_NORMAL'))
    end
    if MissionState.Difficulty == 3 then
        AppendUnits(phase.EastGroups.Defense, SpawnPhase2Group('EAST_DEFENSE_HARD'))
    end
    phase.EastGroups.Engineers = SpawnPhase2Group('EAST_ENGINEERS')
    phase.EastGroups.Garrison = SpawnPhase2Group('EAST_GARRISON')

    phase.WestGroups.Command = SpawnPhase2Group('WEST_COMMAND')
    phase.EastGroups.Command = SpawnPhase2Group('EAST_COMMAND')
    phase.RadarUnits = SpawnPhase2Group('EAST_RADAR_NETWORK')

    MissionState.Targets.WestLogisticsCommand = GetNamedArmyUnit(Army.EnemyMain, 'West_Logistics_Command')
    MissionState.Targets.EastAirControlCommand = GetNamedArmyUnit(Army.EnemyMain, 'East_Air_Control_Command')

    local westCommand = MissionState.Targets.WestLogisticsCommand
    local eastCommand = MissionState.Targets.EastAirControlCommand
    if not IsUnitAlive(westCommand) or not IsUnitAlive(eastCommand) then
        Log('FAIL', 'Phase 2 objective structure creation failed')
        return false
    end

    ProtectObjectiveStructure(westCommand, 'Western Logistics Command')
    ProtectObjectiveStructure(eastCommand, 'Eastern Air Control Command')

    ScenarioFramework.CreateUnitDeathTrigger(OnPhase2WestCommandDestroyed, westCommand)
    ScenarioFramework.CreateUnitDeathTrigger(OnPhase2EastCommandDestroyed, eastCommand)

    if phase.RadarUnits and table.getn(phase.RadarUnits) > 0 then
        for _, radar in ipairs(phase.RadarUnits) do
            if IsUnitAlive(radar) then
                radar:SetCapturable(false)
                radar:SetReclaimable(false)
            end
        end
        ScenarioFramework.CreateGroupDeathTrigger(
            OnPhase2RadarNetworkDestroyed,
            phase.RadarUnits,
            'OTS_PHASE2_RADAR_NETWORK_DESTROYED'
        )
    end

    SetupPhase2Garrison(phase.WestGroups.Garrison, 'OTS_West_Garrison', 'CHAIN_WEST_BASE_PATROL')
    SetupPhase2Garrison(phase.EastGroups.Garrison, 'OTS_East_Garrison', 'CHAIN_EAST_BASE_PATROL')

    Log('WEST', 'Logistics Base active')
    Log('EAST', 'Air Control Base active')
    return true
end

local function GetConvoyObjectiveThreshold()
    if MissionState.Difficulty == 3 then
        return 3
    end
    return 2
end

local function CompleteConvoySecondaryIfReady()
    local phase = MissionState.Phase2
    if phase.WestReinforcementReduced then
        return
    end
    if phase.WestConvoysDestroyed < GetConvoyObjectiveThreshold() then
        return
    end

    phase.WestReinforcementReduced = true
    MarkObjectiveCompleted('Phase2Convoys')
    SetObjectiveManualResultIfActive(MissionState.Objectives.Phase2Convoys, true)
    Log('CONVOY', 'Convoy objective complete; Western reinforcement cadence reduced')
    ScenarioFramework.Dialogue(Dialogues.Phase2ConvoysBroken)
end

local function HandleWestConvoyDestroyed(convoyId)
    local phase = MissionState.Phase2
    local convoy = phase.Convoys[convoyId]
    if not convoy or convoy.Resolved or phase.Finished then
        return
    end

    convoy.Resolved = true
    convoy.Destroyed = true
    phase.WestConvoysDestroyed = phase.WestConvoysDestroyed + 1
    Log('CONVOY', string.format('West convoy %d destroyed (%d total)', convoyId, phase.WestConvoysDestroyed))
    CompleteConvoySecondaryIfReady()
end

local function ApplyWestConvoyBonus(convoyId)
    local phase = MissionState.Phase2
    local convoy = phase.Convoys[convoyId]
    if not convoy or convoy.Resolved or phase.WestCompleted or phase.Finished then
        return
    end

    convoy.Resolved = true
    convoy.Arrived = true
    phase.WestConvoysArrived = phase.WestConvoysArrived + 1
    Log('CONVOY', string.format('West convoy %d reached Logistics Base', convoyId))

    if phase.WestReinforcementReduced then
        Log('CONVOY', 'Arrival bonus suppressed by destroyed logistics convoys')
        return
    end

    local defenders = SpawnWaveUnits({
        Army = Army.EnemyMain,
        SpawnMarker = 'WEST_BASE_CENTER',
        Units = {
            {Blueprint = UnitBlueprints.Cybran.AssaultBot, Count = 2},
            {Blueprint = UnitBlueprints.Cybran.MobileAA, Count = 1},
        },
        NormalUnits = {
            {Blueprint = UnitBlueprints.Cybran.HeavyTankT2, Count = 1},
        },
    })
    AppendUnits(phase.WestAttackUnits, defenders)
    SetupPhase2Garrison(defenders, 'OTS_West_Convoy_Defense_' .. tostring(convoyId), 'CHAIN_WEST_BASE_PATROL')
end

local function MonitorWestConvoy(convoyId)
    local phase = MissionState.Phase2
    local convoy = phase.Convoys[convoyId]
    local exitPosition = GetMarkerPosition('WEST_SUPPLY_EXIT')
    if not convoy or not exitPosition then
        return
    end

    while not MissionState.MissionEnded
        and MissionState.CurrentPhase == 2
        and not phase.Finished
        and not phase.WestCompleted
        and not convoy.Resolved
    do
        WaitSeconds(DEBUG and 1 or 4)
        for _, unit in ipairs(convoy.Units) do
            if IsUnitAlive(unit) and DistanceSquared(unit:GetPosition(), exitPosition) <= 225 then
                ApplyWestConvoyBonus(convoyId)
                return
            end
        end
    end
end

local function RefreshActiveConvoyUnits()
    local phase = MissionState.Phase2
    local active = {}
    for _, convoy in pairs(phase.Convoys) do
        if not convoy.Resolved then
            AppendUnits(active, PruneLivingUnits(convoy.Units))
        end
    end
    phase.ConvoyUnits = active
    return active
end

function SpawnWestConvoy()
    local phase = MissionState.Phase2
    if MissionState.MissionEnded
        or MissionState.CurrentPhase ~= 2
        or phase.WestCompleted
        or phase.Finished
    then
        return {}
    end

    RefreshActiveConvoyUnits()
    if table.getn(phase.ConvoyUnits) >= phase.Limits.MaxActiveConvoyUnits then
        DebugLog('CONVOY', 'Active convoy cap reached')
        return {}
    end

    phase.ConvoyCounter = phase.ConvoyCounter + 1
    local convoyId = phase.ConvoyCounter
    local units = SpawnWaveUnits({
        Army = Army.EnemyMain,
        SpawnMarker = 'WEST_SUPPLY_ENTRY',
        Units = {
            {Blueprint = UnitBlueprints.Cybran.Engineer, Count = 1},
            {Blueprint = UnitBlueprints.Cybran.AssaultBot, Count = 2},
            {Blueprint = UnitBlueprints.Cybran.MobileAA, Count = 1},
        },
        NormalUnits = {
            {Blueprint = UnitBlueprints.Cybran.AssaultBot, Count = 1},
        },
        HardUnits = {
            {Blueprint = UnitBlueprints.Cybran.HeavyTankT2, Count = 1},
            {Blueprint = UnitBlueprints.Cybran.MobileAAT2, Count = 1},
        },
    })

    if table.getn(units) == 0 then
        return units
    end

    phase.Convoys[convoyId] = {
        Units = units,
        Resolved = false,
        Destroyed = false,
        Arrived = false,
    }
    AppendUnits(phase.ConvoyUnits, units)

    local brain = GetArmyBrain(Army.EnemyMain)
    if brain then
        local platoon = brain:MakePlatoon('OTS_West_Convoy_' .. tostring(convoyId), 'NoPlan')
        brain:AssignUnitsToPlatoon(platoon, units, 'Attack', 'AttackFormation')
    end

    for _, position in ipairs(ScenarioUtils.ChainToPositions('CHAIN_WEST_SUPPLY')) do
        IssueMove(units, position)
    end

    ScenarioFramework.CreateGroupDeathTrigger(
        function()
            HandleWestConvoyDestroyed(convoyId)
        end,
        units,
        'OTS_WEST_CONVOY_' .. tostring(convoyId) .. '_DESTROYED'
    )
    AddThread('WestConvoyMonitor_' .. tostring(convoyId), ForkThread(MonitorWestConvoy, convoyId))
    Log('CONVOY', 'West convoy spawned')
    return units
end

function SpawnEastAirRaid(raidName)
    local phase = MissionState.Phase2
    if MissionState.MissionEnded
        or MissionState.CurrentPhase ~= 2
        or phase.EastCompleted
        or phase.Finished
    then
        return {}
    end

    phase.EastAirUnits = PruneLivingUnits(phase.EastAirUnits)
    if table.getn(phase.EastAirUnits) >= phase.Limits.MaxActiveEastAirUnits then
        DebugLog('AIR', 'Active East air cap reached')
        return {}
    end

    local base = WaveDefinitions[raidName or 'BOMBER_STRIKE']
    if not base then
        Log('WARN', 'Unknown East air raid: ' .. tostring(raidName))
        return {}
    end

    phase.AirRaidCounter = phase.AirRaidCounter + 1
    local config = {}
    for key, value in pairs(base) do
        config[key] = value
    end
    config.Name = (base.Name or raidName or 'AIR_RAID') .. '_' .. tostring(phase.AirRaidCounter)
    config.AllowRepeat = true

    local units = SpawnAttackWave(config)
    if table.getn(units) > 0 then
        Log('AIR', (base.Name or tostring(raidName)) .. ' launched')
    end
    return units
end

local function SpawnEastPatrol(routeName)
    local phase = MissionState.Phase2
    phase.EastAirUnits = PruneLivingUnits(phase.EastAirUnits)
    if table.getn(phase.EastAirUnits) >= phase.Limits.MaxActiveEastAirUnits then
        return {}
    end

    phase.PatrolCounter = phase.PatrolCounter + 1
    local base = WaveDefinitions.INTERCEPTOR_PATROL
    local config = {}
    for key, value in pairs(base) do
        config[key] = value
    end
    config.Name = 'INTERCEPTOR_PATROL_' .. tostring(phase.PatrolCounter)
    config.PatrolChain = routeName
    config.AllowRepeat = true
    return SpawnAttackWave(config)
end

local function WestAttackThread()
    if not WaitWhilePhase2(75, 'West') then
        return
    end

    local sequence = {'WEST_WAVE_LIGHT', 'WEST_WAVE_MECH', 'WEST_WAVE_ARTILLERY'}
    local index = 1
    local cycle = 0

    while not MissionState.Phase2.WestCompleted and not MissionState.Phase2.Finished do
        local phase = MissionState.Phase2
        phase.WestAttackUnits = PruneLivingUnits(phase.WestAttackUnits)
        cycle = cycle + 1

        local skipForLogistics = phase.WestReinforcementReduced and math.mod(cycle, 2) == 0
        if not skipForLogistics
            and table.getn(phase.WestAttackUnits) < phase.Limits.MaxActiveWestAttackUnits
        then
            SpawnAttackWave(sequence[index])
            index = index + 1
            if index > table.getn(sequence) then
                index = 1
            end
        end

        local delay = phase.WestReinforcementReduced and 165 or 120
        if not WaitWhilePhase2(delay, 'West') then
            return
        end
    end
end

local function WestConvoyThread()
    if not WaitWhilePhase2(100, 'West') then
        return
    end

    while not MissionState.Phase2.WestCompleted and not MissionState.Phase2.Finished do
        SpawnWestConvoy()
        local delay = MissionState.Phase2.WestReinforcementReduced and 260 or 190
        if not WaitWhilePhase2(delay, 'West') then
            return
        end
    end
end

local function EastAirAttackThread()
    if not WaitWhilePhase2(80, 'East') then
        return
    end

    local sequence = {'AIR_SCOUT', 'BOMBER_STRIKE'}
    if MissionState.Difficulty >= 2 then
        sequence = {'AIR_SCOUT', 'BOMBER_STRIKE', 'GUNSHIP_RAID', 'MIXED_AIR_ATTACK'}
    end
    if MissionState.Difficulty == 3 then
        sequence = {'BOMBER_STRIKE', 'GUNSHIP_RAID', 'MIXED_AIR_ATTACK', 'BOMBER_STRIKE', 'MIXED_AIR_ATTACK'}
    end

    local index = 1
    while not MissionState.Phase2.EastCompleted and not MissionState.Phase2.Finished do
        SpawnEastAirRaid(sequence[index])
        index = index + 1
        if index > table.getn(sequence) then
            index = 1
        end

        local delay = 125
        if MissionState.Difficulty == 1 then
            delay = 165
        elseif MissionState.Difficulty == 3 then
            delay = 100
        end
        if MissionState.Phase2.RadarNetworkDestroyed then
            delay = delay * 1.45
        end

        if not WaitWhilePhase2(delay, 'East') then
            return
        end
    end
end

local function EastPatrolThread()
    if not WaitWhilePhase2(45, 'East') then
        return
    end

    local index = 1
    local fullRoutes = {
        'CHAIN_EAST_AIR_PATROL_01',
        'CHAIN_EAST_AIR_PATROL_02',
        'CHAIN_CENTER_AIR_PATROL',
    }

    while not MissionState.Phase2.EastCompleted and not MissionState.Phase2.Finished do
        local route = fullRoutes[index]
        if MissionState.Phase2.RadarNetworkDestroyed then
            route = 'CHAIN_EAST_AIR_PATROL_01'
        end
        SpawnEastPatrol(route)

        index = index + 1
        if index > table.getn(fullRoutes) then
            index = 1
        end

        local delay = MissionState.Phase2.RadarNetworkDestroyed and 220 or 150
        if not WaitWhilePhase2(delay, 'East') then
            return
        end
    end
end

local function FindRepairTarget(groups)
    for _, group in ipairs(groups) do
        for _, unit in ipairs(group or {}) do
            if IsUnitAlive(unit)
                and unit.GetHealth
                and unit.GetMaxHealth
                and unit:GetHealth() < unit:GetMaxHealth()
            then
                return unit
            end
        end
    end
    return nil
end

local function Phase2EngineerSupportThread(side)
    local phase = MissionState.Phase2
    local isWest = side == 'West'
    local groups = isWest and phase.WestGroups or phase.EastGroups
    local patrolChain = isWest and 'CHAIN_WEST_BASE_PATROL' or 'CHAIN_EAST_BASE_PATROL'

    while not phase.Finished
        and ((isWest and not phase.WestCompleted) or ((not isWest) and not phase.EastCompleted))
    do
        if not WaitWhilePhase2(55, side) then
            return
        end

        groups.Engineers = PruneLivingUnits(groups.Engineers)
        local engineer = groups.Engineers[1]
        if IsUnitAlive(engineer) then
            local repairTarget = FindRepairTarget({groups.Production, groups.Defense, groups.Economy})
            IssueClearCommands({engineer})
            if repairTarget then
                IssueRepair({engineer}, repairTarget)
            else
                for _, position in ipairs(ScenarioUtils.ChainToPositions(patrolChain)) do
                    IssuePatrol({engineer}, position)
                end
            end
        end
    end
end

local function ApplyAdaptiveReinforcement(completedSide)
    local phase = MissionState.Phase2
    if phase.AdaptiveResponseTriggered or phase.Finished then
        return
    end

    phase.AdaptiveResponseTriggered = true
    if completedSide == 'West' and not phase.EastCompleted then
        Log('RESPONSE', 'East sector receives moderate adaptive reinforcement')
        SpawnAttackWave('EAST_ADAPTIVE_REINFORCEMENT')
        if MissionState.Difficulty == 3 then
            SpawnEastAirRaid('MIXED_AIR_ATTACK')
        end
    elseif completedSide == 'East' and not phase.WestCompleted then
        Log('RESPONSE', 'West sector receives moderate adaptive reinforcement')
        SpawnAttackWave('WEST_ADAPTIVE_REINFORCEMENT')
        if MissionState.Difficulty == 3 then
            SpawnAttackWave('WEST_WAVE_MECH')
        end
    end
end

function TriggerCentralResponse()
    local phase = MissionState.Phase2
    if MissionState.MissionEnded
        or MissionState.CurrentPhase ~= 2
        or phase.CentralResponseTriggered
        or phase.Finished
    then
        return
    end

    phase.CentralResponseTriggered = true
    Log('RESPONSE', 'Central response triggered')
    ScenarioFramework.Dialogue(Dialogues.Phase2CentralResponse)

    phase.CentralResponseUnits = PruneLivingUnits(phase.CentralResponseUnits)
    if table.getn(phase.CentralResponseUnits) < phase.Limits.MaxActiveCentralResponseUnits then
        SpawnAttackWave('CENTRAL_RESPONSE_MAIN')
        if MissionState.Difficulty == 3 and MissionState.ActivePlayers >= 2 then
            SpawnAttackWave('CENTRAL_RESPONSE_FLANK')
        end
    end
end

function CheckPhase2Completion()
    local phase = MissionState.Phase2
    if phase.Finished then
        return
    end
    if phase.WestCompleted and phase.EastCompleted then
        CompletePhase2()
    end
end

function CompleteWestObjective()
    local phase = MissionState.Phase2
    if phase.WestCompleted or phase.Finished then
        return
    end

    phase.WestCompleted = true
    phase.WestCommandDestroyed = true
    MarkObjectiveCompleted('Phase2West')
    SetObjectiveManualResultIfActive(MissionState.Objectives.Phase2West, true)
    Log('OBJECTIVE', 'West completed')
    ScenarioFramework.Dialogue(Dialogues.Phase2WestDestroyed)

    if not phase.FirstCompletedSide then
        phase.FirstCompletedSide = 'West'
        TriggerCentralResponse()
        ApplyAdaptiveReinforcement('West')
    end

    CheckPhase2Completion()
end

function CompleteEastObjective()
    local phase = MissionState.Phase2
    if phase.EastCompleted or phase.Finished then
        return
    end

    phase.EastCompleted = true
    phase.EastCommandDestroyed = true
    MarkObjectiveCompleted('Phase2East')
    SetObjectiveManualResultIfActive(MissionState.Objectives.Phase2East, true)
    Log('OBJECTIVE', 'East completed')
    ScenarioFramework.Dialogue(Dialogues.Phase2EastDestroyed)

    if not phase.FirstCompletedSide then
        phase.FirstCompletedSide = 'East'
        TriggerCentralResponse()
        ApplyAdaptiveReinforcement('East')
    end

    CheckPhase2Completion()
end

local function CreatePhase2Objectives()
    local phase = MissionState.Phase2
    local westCommand = MissionState.Targets.WestLogisticsCommand
    local eastCommand = MissionState.Targets.EastAirControlCommand

    if not westCommand or not eastCommand then
        MissionFailure('Phase 2 objective structures missing')
        return false
    end

    local westAlreadyDestroyed = phase.WestCommandDestroyed or not IsUnitAlive(westCommand)
    local eastAlreadyDestroyed = phase.EastCommandDestroyed or not IsUnitAlive(eastCommand)

    MissionState.Objectives.Phase2West = Objectives.Kill(
        'primary',
        westAlreadyDestroyed and 'complete' or 'incomplete',
        'Destroy Western Logistics Base',
        'Destroy the Cybran logistics hub supplying the northern defenses.',
        {
            Units = {westCommand},
            MarkUnits = true,
            AlwaysVisible = true,
            ShowFaction = 'Cybran',
        }
    )

    MissionState.Objectives.Phase2East = Objectives.Kill(
        'primary',
        eastAlreadyDestroyed and 'complete' or 'incomplete',
        'Destroy Eastern Air Control Base',
        'Eliminate the Cybran air-control installation supporting enemy operations in the sector.',
        {
            Units = {eastCommand},
            MarkUnits = true,
            AlwaysVisible = true,
            ShowFaction = 'Cybran',
        }
    )

    MissionState.Objectives.Phase2West:AddResultCallback(
        function(success)
            if MissionState.MissionEnded then return end
            if success then
                CompleteWestObjective()
            else
                MissionFailure('Western Logistics Base objective failed')
            end
        end
    )
    MissionState.Objectives.Phase2East:AddResultCallback(
        function(success)
            if MissionState.MissionEnded then return end
            if success then
                CompleteEastObjective()
            else
                MissionFailure('Eastern Air Control Base objective failed')
            end
        end
    )

    MissionState.Objectives.Phase2Convoys = Objectives.Unknown(
        'secondary',
        phase.WestReinforcementReduced and 'complete' or 'incomplete',
        'Intercept Cybran Supply Convoys',
        'Destroy multiple Cybran supply convoys before they reinforce the Western Logistics Base.'
    )

    local radarsAlive = {}
    for _, radar in ipairs(phase.RadarUnits or {}) do
        if IsUnitAlive(radar) then
            table.insert(radarsAlive, radar)
        end
    end
    local radarAlreadyDestroyed = phase.RadarNetworkDestroyed or table.getn(radarsAlive) == 0
    MissionState.Objectives.Phase2RadarNetwork = Objectives.Kill(
        'secondary',
        radarAlreadyDestroyed and 'complete' or 'incomplete',
        'Destroy Cybran Radar Network',
        'Destroy the Cybran radar network to reduce air-raid frequency and patrol coverage.',
        {
            Units = radarAlreadyDestroyed and (phase.RadarUnits or {}) or radarsAlive,
            MarkUnits = true,
            AlwaysVisible = true,
            ShowFaction = 'Cybran',
        }
    )
    if not radarAlreadyDestroyed then
        MissionState.Objectives.Phase2RadarNetwork:AddResultCallback(
            function(success)
                if success then
                    OnPhase2RadarNetworkDestroyed()
                end
            end
        )
    else
        OnPhase2RadarNetworkDestroyed()
    end

    if westAlreadyDestroyed then
        CompleteWestObjective()
    end
    if eastAlreadyDestroyed then
        CompleteEastObjective()
    end
    CompleteConvoySecondaryIfReady()
    return true
end

function CompletePhase2()
    local phase = MissionState.Phase2
    if MissionState.MissionEnded or phase.Finished then
        return
    end
    if not phase.WestCompleted or not phase.EastCompleted then
        DebugLog('PHASE2', 'Completion ignored until both sectors are neutralized')
        return
    end

    phase.Finished = true
    MarkObjectiveCompleted('Phase2')
    Log('PHASE2', 'Both sectors neutralized')
    ScenarioFramework.Dialogue(Dialogues.Phase2Complete)

    ScenarioFramework.SetPlayableArea('AREA_PHASE_3', true)
    Log('MAP', 'Expanding to AREA_PHASE_3')

    MissionState.CurrentPhase = 3
    StartPhase3()
end

local function NewPhase3State()
    return {
        Started = false,
        ArtilleryDestroyed = false,
        DefenseNodeDestroyed = false,
        ReinforcementGatewayDestroyed = false,
        StrategicResponseTriggered = false,
        EmergencyResponseTriggered = false,
        RadarNetworkDestroyed = false,
        RadarRewardApplied = false,
        DataCoreDestroyed = false,
        IntelRewardApplied = false,
        ArtilleryWarningShown = false,
        FinaleUnlocked = false,
        Finished = false,
        CompletedPrimaryCount = 0,
        AttackCounter = 0,
        TargetSelectionCounter = 0,
        GatewayCounter = 0,
        TransportCounter = 0,
        BombardmentCounter = 0,
        DefenseRebuilds = 0,
        InitialDefenseStaticCount = 0,
        LastAttackedPlayer = false,
        Groups = {},
        RadarUnits = {},
        LandAttackUnits = {},
        AirAttackUnits = {},
        GatewayUnits = {},
        TransportUnits = {},
        Limits = {},
    }
end

local function WaitWhilePhase3(baseSeconds, systemName)
    local remaining = baseSeconds
    if DEBUG then
        remaining = math.max(0.25, remaining * 0.10)
    end

    while remaining > 0 do
        local phase = MissionState.Phase3
        if MissionState.MissionEnded or MissionState.CurrentPhase ~= 3 or phase.Finished then
            return false
        end
        if systemName == 'Artillery' and phase.ArtilleryDestroyed then
            return false
        end
        if systemName == 'Defense' and phase.DefenseNodeDestroyed then
            return false
        end
        if systemName == 'Gateway' and phase.ReinforcementGatewayDestroyed then
            return false
        end

        local slice = math.min(5, remaining)
        WaitSeconds(slice)
        remaining = remaining - slice
    end
    return true
end

local function GetPhase3ArtilleryInterval()
    local values = {[1] = 105, [2] = 80, [3] = 60}
    local value = values[MissionState.Difficulty] or values[2]
    if MissionState.ActivePlayers >= 2 then
        value = value * 0.92
    end
    return value
end

local function GetPhase3AttackInterval()
    local values = {[1] = 145, [2] = 115, [3] = 92}
    local value = values[MissionState.Difficulty] or values[2]
    if MissionState.ActivePlayers == 1 then
        value = value * 1.18
    end
    return value
end

local function GetPhase3GatewayInterval()
    local values = {[1] = 190, [2] = 155, [3] = 125}
    local value = values[MissionState.Difficulty] or values[2]
    if MissionState.ActivePlayers == 1 then
        value = value * 1.12
    end
    return value
end

local function GetPhase3TransportInterval()
    local values = {[1] = 390, [2] = 315, [3] = 245}
    local value = values[MissionState.Difficulty] or values[2]
    if MissionState.ActivePlayers == 1 then
        value = value * 1.20
    end
    if MissionState.Phase3.RadarRewardApplied then
        value = value * 1.50
    end
    return value
end

local function SetUnitsFireState(units, state)
    if not units then
        return
    end
    for _, unit in ipairs(units) do
        if IsUnitAlive(unit) and unit.SetFireState then
            unit:SetFireState(state)
        end
    end
end

local function SetupPhase3Garrison(units, platoonName, patrolChain)
    if not units or table.getn(units) == 0 then
        return
    end
    local brain = GetArmyBrain(Army.EnemyMain)
    if not brain then
        return
    end
    local platoon = brain:MakePlatoon(platoonName, 'NoPlan')
    brain:AssignUnitsToPlatoon(platoon, units, 'Attack', 'AttackFormation')
    ScenarioFramework.PlatoonPatrolChain(platoon, patrolChain)
end

local function OnPhase3ArtilleryDestroyed()
    local phase = MissionState.Phase3
    phase.ArtilleryDestroyed = true
    Log('OBJECTIVE', 'Artillery destroyed')
    if phase.Started then
        CompleteArtilleryObjective()
    end
end

local function OnPhase3DefenseNodeDestroyed()
    local phase = MissionState.Phase3
    phase.DefenseNodeDestroyed = true
    Log('OBJECTIVE', 'Defense Node destroyed')
    if phase.Started then
        CompleteDefenseObjective()
    end
end

local function OnPhase3GatewayDestroyed()
    local phase = MissionState.Phase3
    phase.ReinforcementGatewayDestroyed = true
    Log('OBJECTIVE', 'Gateway destroyed')
    if phase.Started then
        CompleteGatewayObjective()
    end
end

local function ApplyPhase3RadarReward()
    local phase = MissionState.Phase3
    if phase.RadarRewardApplied then
        return
    end
    phase.RadarNetworkDestroyed = true
    phase.RadarRewardApplied = true
    MarkObjectiveCompleted('Phase3Radar')
    SetObjectiveManualResultIfActive(MissionState.Objectives.Phase3Radar, true)
    Log('OBJECTIVE', 'Strategic Radar destroyed; drop and air coordination reduced')
    if phase.Started and not MissionState.MissionEnded then
        ScenarioFramework.Dialogue(Dialogues.Phase3RadarDestroyed)
    end
end

local function OnPhase3DataCoreDestroyed()
    local phase = MissionState.Phase3
    if phase.IntelRewardApplied then
        return
    end
    phase.DataCoreDestroyed = true
    phase.IntelRewardApplied = true
    MarkObjectiveCompleted('Phase3DataCore')
    SetObjectiveManualResultIfActive(MissionState.Objectives.Phase3DataCore, true)
    Log('OBJECTIVE', 'Data Core destroyed; temporary finale intel granted')

    local mainBase = GetMarkerPosition('CYBRAN_MAIN_BASE')
    if mainBase then
        ScenarioFramework.CreateVisibleArea(70, mainBase[1], mainBase[3], 45, ScenarioInfo.Player1)
        if IsArmyActive(ScenarioInfo.Player2, Army.Player2) then
            ScenarioFramework.CreateVisibleArea(70, mainBase[1], mainBase[3], 45, ScenarioInfo.Player2)
        end
    end

    if phase.Started and not MissionState.MissionEnded then
        ScenarioFramework.Dialogue(Dialogues.Phase3DataCore)
    end
end

function InitializePhase3EnemyForces()
    local phase = MissionState.Phase3
    phase.Groups = phase.Groups or {}

    phase.Groups.ArtilleryBase = SpawnPhase2Group('PHASE3_ARTILLERY_BASE')
    phase.Groups.ArtilleryCore = SpawnPhase2Group('ARTILLERY_CORE')
    phase.Groups.ArtilleryDefense = SpawnPhase2Group('ARTILLERY_DEFENSE')
    if MissionState.Difficulty >= 2 then
        AppendUnits(phase.Groups.ArtilleryDefense, SpawnPhase2Group('ARTILLERY_DEFENSE_NORMAL'))
    end
    if MissionState.Difficulty == 3 then
        AppendUnits(phase.Groups.ArtilleryDefense, SpawnPhase2Group('ARTILLERY_DEFENSE_HARD'))
    end
    phase.Groups.ArtillerySupport = SpawnPhase2Group('ARTILLERY_SUPPORT')

    phase.Groups.DefenseBase = SpawnPhase2Group('PHASE3_DEFENSE_BASE')
    phase.Groups.DefenseNode = SpawnPhase2Group('DEFENSE_NODE')
    phase.Groups.DefenseStatic = SpawnPhase2Group('DEFENSE_STATIC')
    if MissionState.Difficulty >= 2 then
        AppendUnits(phase.Groups.DefenseStatic, SpawnPhase2Group('DEFENSE_STATIC_NORMAL'))
    end
    if MissionState.Difficulty == 3 then
        AppendUnits(phase.Groups.DefenseStatic, SpawnPhase2Group('DEFENSE_STATIC_HARD'))
    end
    phase.Groups.DefenseFactories = SpawnPhase2Group('DEFENSE_FACTORIES')
    if MissionState.Difficulty >= 2 then
        AppendUnits(phase.Groups.DefenseFactories, SpawnPhase2Group('DEFENSE_FACTORIES_NORMAL'))
    end
    if MissionState.Difficulty == 3 then
        AppendUnits(phase.Groups.DefenseFactories, SpawnPhase2Group('DEFENSE_FACTORIES_HARD'))
    end
    phase.Groups.DefenseEngineers = SpawnPhase2Group('DEFENSE_ENGINEERS')
    if MissionState.Difficulty == 3 then
        AppendUnits(phase.Groups.DefenseEngineers, SpawnPhase2Group('DEFENSE_ENGINEERS_HARD'))
    end
    phase.Groups.DefenseGarrison = SpawnPhase2Group('DEFENSE_GARRISON')

    phase.Groups.GatewayBase = SpawnPhase2Group('PHASE3_GATEWAY_BASE')
    phase.Groups.GatewayCore = SpawnPhase2Group('GATEWAY_CORE')
    phase.Groups.GatewayProduction = SpawnPhase2Group('GATEWAY_PRODUCTION')
    if MissionState.Difficulty >= 2 then
        AppendUnits(phase.Groups.GatewayProduction, SpawnPhase2Group('GATEWAY_PRODUCTION_NORMAL'))
    end
    if MissionState.Difficulty == 3 then
        AppendUnits(phase.Groups.GatewayProduction, SpawnPhase2Group('GATEWAY_PRODUCTION_HARD'))
    end
    phase.Groups.GatewayAA = SpawnPhase2Group('GATEWAY_AA')
    if MissionState.Difficulty == 3 then
        AppendUnits(phase.Groups.GatewayAA, SpawnPhase2Group('GATEWAY_AA_HARD'))
    end
    phase.Groups.GatewaySupport = SpawnPhase2Group('GATEWAY_SUPPORT')

    phase.RadarUnits = SpawnPhase2Group('PHASE3_STRATEGIC_RADAR')
    phase.Groups.DataCore = SpawnPhase2Group('PHASE3_DATA_CORE')

    MissionState.Targets.Phase3Artillery = GetNamedArmyUnit(Army.EnemyMain, 'Phase3_Artillery_Core')
    MissionState.Targets.Phase3DefenseNode = GetNamedArmyUnit(Army.EnemyMain, 'Heavy_Defense_Control_Node')
    MissionState.Targets.Phase3Gateway = GetNamedArmyUnit(Army.EnemyMain, 'Phase3_Reinforcement_Gateway')
    MissionState.Targets.Phase3DataCore = GetNamedArmyUnit(Army.EnemyMain, 'Phase3_Data_Core')

    local artillery = MissionState.Targets.Phase3Artillery
    local defenseNode = MissionState.Targets.Phase3DefenseNode
    local gateway = MissionState.Targets.Phase3Gateway
    local dataCore = MissionState.Targets.Phase3DataCore

    if not IsUnitAlive(artillery) or not IsUnitAlive(defenseNode) or not IsUnitAlive(gateway) then
        Log('FAIL', 'Phase 3 primary objective structure creation failed')
        return false
    end

    ProtectObjectiveStructure(artillery, 'Cybran Long-Range Artillery')
    ProtectObjectiveStructure(defenseNode, 'Heavy Defense Control Node')
    ProtectObjectiveStructure(gateway, 'Cybran Reinforcement Gateway')
    if IsUnitAlive(dataCore) then
        ProtectObjectiveStructure(dataCore, 'Cybran Data Core')
    end

    SetUnitsFireState(phase.Groups.ArtilleryCore, 'HoldFire')
    SetUnitsFireState(phase.Groups.ArtilleryDefense, 'HoldFire')
    SetUnitsFireState(phase.Groups.ArtillerySupport, 'HoldFire')
    SetUnitsFireState(phase.Groups.DefenseStatic, 'HoldFire')
    SetUnitsFireState(phase.Groups.DefenseGarrison, 'HoldFire')
    SetUnitsFireState(phase.Groups.GatewayAA, 'HoldFire')
    SetUnitsFireState(phase.Groups.GatewaySupport, 'HoldFire')

    ScenarioFramework.CreateUnitDeathTrigger(OnPhase3ArtilleryDestroyed, artillery)
    ScenarioFramework.CreateUnitDeathTrigger(OnPhase3DefenseNodeDestroyed, defenseNode)
    ScenarioFramework.CreateUnitDeathTrigger(OnPhase3GatewayDestroyed, gateway)

    if phase.RadarUnits and table.getn(phase.RadarUnits) > 0 then
        for _, radar in ipairs(phase.RadarUnits) do
            ProtectObjectiveStructure(radar, 'Cybran Strategic Radar')
        end
        ScenarioFramework.CreateGroupDeathTrigger(
            ApplyPhase3RadarReward,
            phase.RadarUnits,
            'OTS_PHASE3_RADAR_DESTROYED'
        )
    end

    if IsUnitAlive(dataCore) then
        ScenarioFramework.CreateUnitDeathTrigger(OnPhase3DataCoreDestroyed, dataCore)
    else
        phase.DataCoreDestroyed = true
    end

    phase.InitialDefenseStaticCount = CountLivingUnits(phase.Groups.DefenseStatic)
    Log('PHASE3', 'Strategic installations initialized in passive state')
    return true
end

local function CountPhase3PrimaryCompleted()
    local phase = MissionState.Phase3
    local count = 0
    if phase.ArtilleryDestroyed then count = count + 1 end
    if phase.DefenseNodeDestroyed then count = count + 1 end
    if phase.ReinforcementGatewayDestroyed then count = count + 1 end
    phase.CompletedPrimaryCount = count
    return count
end

function SelectPhase3AttackTarget()
    local phase = MissionState.Phase3
    local available = GetAvailableWaveTargets()
    if table.getn(available) == 0 then
        return nil
    end
    if table.getn(available) == 1 then
        phase.LastAttackedPlayer = available[1]
        return available[1]
    end

    phase.TargetSelectionCounter = phase.TargetSelectionCounter + 1
    local selected = nil
    if phase.LastAttackedPlayer and math.mod(phase.TargetSelectionCounter, 3) ~= 0 then
        for _, target in ipairs(available) do
            if target ~= phase.LastAttackedPlayer then
                selected = target
                break
            end
        end
    end

    if not selected then
        selected = available[1]
        local pressure = MissionState.WavePressure[selected] or 0
        for _, target in ipairs(available) do
            local targetPressure = MissionState.WavePressure[target] or 0
            if targetPressure < pressure then
                selected = target
                pressure = targetPressure
            end
        end
    end

    phase.LastAttackedPlayer = selected
    return selected
end

function GetAvailablePhase3AttackTypes()
    local phase = MissionState.Phase3
    local types = {}
    if not phase.ArtilleryDestroyed then
        table.insert(types, 'PHASE3_ATTACK_WEST')
    end
    if not phase.DefenseNodeDestroyed then
        table.insert(types, 'PHASE3_ATTACK_CENTER')
    end
    if not phase.ReinforcementGatewayDestroyed then
        table.insert(types, 'PHASE3_ATTACK_EAST')
    end
    if table.getn(types) == 0 then
        table.insert(types, 'PHASE3_ATTACK_CENTER')
    end
    return types
end

function CanSpawnPhase3Attack(poolName, expectedUnits)
    local phase = MissionState.Phase3
    local pool = phase[poolName] or {}
    pool = PruneLivingUnits(pool)
    phase[poolName] = pool

    local limit = phase.Limits.Phase3MaxLandAttackUnits
    if poolName == 'AirAttackUnits' then
        limit = phase.Limits.Phase3MaxAirAttackUnits
    elseif poolName == 'GatewayUnits' or poolName == 'TransportUnits' then
        limit = phase.Limits.Phase3MaxReinforcementUnits
    end

    return table.getn(pool) + (expectedUnits or 1) <= limit
end

function LaunchConfiguredAttack(configName, preferredTarget)
    local base = WaveDefinitions[configName]
    if not base or MissionState.CurrentPhase ~= 3 or MissionState.Phase3.Finished then
        return {}
    end

    local poolName = base.TrackPool or 'LandAttackUnits'
    if not CanSpawnPhase3Attack(poolName, 4) then
        DebugLog('PHASE3', 'Unit cap blocks ' .. tostring(configName))
        return {}
    end

    local config = {}
    for key, value in pairs(base) do
        config[key] = value
    end
    config.PreferredTarget = preferredTarget or SelectPhase3AttackTarget()
    return SpawnAttackWave(config)
end

function SpawnPhase3Attack()
    local types = GetAvailablePhase3AttackTypes()
    if table.getn(types) == 0 then
        return {}
    end
    local phase = MissionState.Phase3
    phase.AttackCounter = phase.AttackCounter + 1
    local index = math.mod(phase.AttackCounter - 1, table.getn(types)) + 1
    local target = SelectPhase3AttackTarget()
    local units = LaunchConfiguredAttack(types[index], target)

    if MissionState.ActivePlayers >= 2
        and MissionState.Difficulty >= 2
        and math.mod(phase.AttackCounter, 3) == 0
        and CanSpawnPhase3Attack('AirAttackUnits', 4)
        and not (phase.RadarRewardApplied and math.mod(phase.AttackCounter, 2) == 0)
    then
        LaunchConfiguredAttack('PHASE3_AIR_SUPPORT', SelectPhase3AttackTarget())
    end
    return units
end

local function Phase3ArtilleryThread()
    local phase = MissionState.Phase3
    local artillery = MissionState.Targets.Phase3Artillery

    if not phase.ArtilleryWarningShown then
        phase.ArtilleryWarningShown = true
        ScenarioFramework.Dialogue(Dialogues.Phase3ArtilleryWarning)
    end

    if not WaitWhilePhase3(15, 'Artillery') then
        return
    end

    while not MissionState.MissionEnded
        and MissionState.CurrentPhase == 3
        and not phase.ArtilleryDestroyed
        and not phase.Finished
    do
        if not IsUnitAlive(artillery) then
            OnPhase3ArtilleryDestroyed()
            return
        end

        -- Use the stock FAF artillery acquisition logic instead of querying the
        -- player army directly. The scripted layer only controls firing windows,
        -- so there is no perfect-information ACU/structure sniping and no custom
        -- damage or weapon blueprint modification.
        phase.BombardmentCounter = phase.BombardmentCounter + 1
        artillery:SetFireState('Aggressive')
        Log('ARTILLERY', 'Bombardment window active')

        if not WaitWhilePhase3(22, 'Artillery') then
            return
        end

        if IsUnitAlive(artillery) then
            artillery:SetFireState('HoldFire')
            IssueClearCommands({artillery})
        end

        if not WaitWhilePhase3(GetPhase3ArtilleryInterval(), 'Artillery') then
            return
        end
    end
end

local function Phase3DefenseRepairThread()
    local phase = MissionState.Phase3
    local rebuildLimit = ({[1] = 1, [2] = 2, [3] = 3})[MissionState.Difficulty] or 2
    local rebuildMarkers = {'PHASE3_DEFENSE_REBUILD_01', 'PHASE3_DEFENSE_REBUILD_02', 'PHASE3_DEFENSE_REBUILD_03'}

    while not MissionState.MissionEnded
        and MissionState.CurrentPhase == 3
        and not phase.DefenseNodeDestroyed
        and not phase.Finished
    do
        phase.Groups.DefenseEngineers = PruneLivingUnits(phase.Groups.DefenseEngineers)
        local engineers = phase.Groups.DefenseEngineers
        if table.getn(engineers) == 0 then
            return
        end

        local repairTarget = nil
        for _, unit in ipairs(phase.Groups.DefenseStatic or {}) do
            if IsUnitAlive(unit) and unit:GetHealth() < unit:GetMaxHealth() * 0.92 then
                repairTarget = unit
                break
            end
        end

        if repairTarget then
            IssueClearCommands(engineers)
            IssueRepair(engineers, repairTarget)
        elseif phase.DefenseRebuilds < rebuildLimit
            and CountLivingUnits(phase.Groups.DefenseStatic) < phase.InitialDefenseStaticCount
        then
            phase.DefenseRebuilds = phase.DefenseRebuilds + 1
            local markerName = rebuildMarkers[phase.DefenseRebuilds] or rebuildMarkers[1]
            local position = GetMarkerPosition(markerName)
            if position then
                local blueprint = math.mod(phase.DefenseRebuilds, 2) == 0 and 'urb2304' or 'urb2301'
                IssueClearCommands({engineers[1]})
                IssueBuildMobile({engineers[1]}, position, blueprint, {})
                Log('DEFENSE', 'Engineer reconstruction order issued: ' .. blueprint)
            end
        end

        if not WaitWhilePhase3(18, 'Defense') then
            return
        end
    end
end

local function Phase3GatewayReinforcementThread()
    local phase = MissionState.Phase3
    local cycle = {
        'PHASE3_GATEWAY_HEAVY',
        'PHASE3_GATEWAY_SIEGE',
        'PHASE3_GATEWAY_HEAVY',
        'PHASE3_GATEWAY_LATE_T3',
    }

    if not WaitWhilePhase3(70, 'Gateway') then
        return
    end

    while not MissionState.MissionEnded
        and MissionState.CurrentPhase == 3
        and not phase.ReinforcementGatewayDestroyed
        and not phase.Finished
    do
        phase.GatewayCounter = phase.GatewayCounter + 1
        local name = cycle[math.mod(phase.GatewayCounter - 1, table.getn(cycle)) + 1]
        if name == 'PHASE3_GATEWAY_LATE_T3' and MissionState.Difficulty == 1 then
            name = 'PHASE3_GATEWAY_HEAVY'
        end

        if CanSpawnPhase3Attack('GatewayUnits', 5) then
            LaunchConfiguredAttack(name, SelectPhase3AttackTarget())
            Log('GATEWAY', 'Reinforcement spawned: ' .. name)
        end

        if not WaitWhilePhase3(GetPhase3GatewayInterval(), 'Gateway') then
            return
        end
    end
end

local function SpawnTransportEscort(transportIndex)
    local escorts = {}
    local entry = 'PHASE3_TRANSPORT_ENTRY'
    local specs = {
        {Blueprint = UnitBlueprints.Cybran.Interceptor, Count = MissionState.Difficulty >= 2 and 2 or 1},
        {Blueprint = UnitBlueprints.Cybran.Gunship, Count = MissionState.Difficulty == 3 and 1 or 0},
        {Blueprint = UnitBlueprints.Cybran.AirSuperiorityT3, Count = MissionState.Difficulty == 3 and 1 or 0},
    }
    local offset = transportIndex * 5
    for _, spec in ipairs(specs) do
        for index = 1, spec.Count do
            local unit = SpawnOffsetUnit(
                Army.EnemyMain,
                spec.Blueprint,
                entry,
                offset + index * 3,
                -8 - index * 2,
                3.141592653589793,
                35
            )
            if unit then table.insert(escorts, unit) end
        end
    end
    return escorts
end

function SpawnTransportDrop()
    local phase = MissionState.Phase3
    if MissionState.MissionEnded
        or MissionState.CurrentPhase ~= 3
        or phase.Finished
        or phase.ReinforcementGatewayDestroyed
    then
        return {}
    end

    local transportCount = 1
    if MissionState.Difficulty == 3 and MissionState.ActivePlayers >= 2 then
        transportCount = 2
    end

    local transports = {}
    local cargoAll = {}
    local escortsAll = {}
    local target = SelectPhase3AttackTarget()
    local dropChain = target == Army.Player2 and 'CHAIN_REINFORCEMENT_DROP_EAST' or 'CHAIN_REINFORCEMENT_DROP_WEST'
    local flankChain = target == Army.Player2 and 'CHAIN_PHASE3_FLANK_EAST' or 'CHAIN_PHASE3_FLANK_WEST'
    local dropPositions = ScenarioUtils.ChainToPositions(dropChain)
    local exitPositions = ScenarioUtils.ChainToPositions('CHAIN_REINFORCEMENT_EXIT')

    for transportIndex = 1, transportCount do
        local transport = SpawnOffsetUnit(
            Army.EnemyMain,
            UnitBlueprints.Cybran.TransportT2,
            'PHASE3_TRANSPORT_ENTRY',
            transportIndex * 7,
            transportIndex * 4,
            3.141592653589793,
            40
        )
        if transport then
            table.insert(transports, transport)
            table.insert(phase.TransportUnits, transport)

            local cargo = {}
            local cargoSpecs = {
                {Blueprint = UnitBlueprints.Cybran.AssaultBot, Count = 4},
                {Blueprint = UnitBlueprints.Cybran.MobileAA, Count = 2},
                {Blueprint = UnitBlueprints.Cybran.MobileArtillery, Count = 2},
            }
            local cargoIndex = 0
            for _, spec in ipairs(cargoSpecs) do
                for _ = 1, spec.Count do
                    cargoIndex = cargoIndex + 1
                    local unit = SpawnOffsetUnit(
                        Army.EnemyMain,
                        spec.Blueprint,
                        'PHASE3_GATEWAY_CENTER',
                        transportIndex * 12 + math.mod(cargoIndex, 3) * 3,
                        12 + math.floor(cargoIndex / 3) * 3,
                        3.141592653589793,
                        0
                    )
                    if unit then
                        table.insert(cargo, unit)
                        table.insert(cargoAll, unit)
                        table.insert(phase.GatewayUnits, unit)
                    end
                end
            end

            if table.getn(cargo) > 0 then
                IssueClearCommands(cargo)
                IssueTransportLoad(cargo, transport)
            end
            AppendUnits(escortsAll, SpawnTransportEscort(transportIndex))
        end
    end

    if table.getn(transports) == 0 then
        return {}
    end

    phase.TransportCounter = phase.TransportCounter + 1
    Log('TRANSPORT', 'Drop mission launched')

    if not WaitWhilePhase3(14, 'Gateway') then
        return transports
    end

    for _, position in ipairs(ScenarioUtils.ChainToPositions('CHAIN_REINFORCEMENT_AIR_ENTRY')) do
        IssueMove(transports, position)
        if table.getn(escortsAll) > 0 then IssueMove(escortsAll, position) end
    end
    for _, position in ipairs(dropPositions) do
        IssueMove(transports, position)
        if table.getn(escortsAll) > 0 then IssueMove(escortsAll, position) end
    end

    local unload = dropPositions[table.getn(dropPositions)]
    if unload then
        IssueTransportUnload(transports, unload)
    end
    for _, position in ipairs(exitPositions) do
        IssueMove(transports, position)
        if table.getn(escortsAll) > 0 then IssueMove(escortsAll, position) end
    end

    if not WaitWhilePhase3(35, 'Gateway') then
        return transports
    end

    if table.getn(cargoAll) > 0 then
        IssueWaveOrders(cargoAll, target, false, {AttackChain = flankChain})
    end
    if table.getn(escortsAll) > 0 then
        IssueWaveOrders(escortsAll, target, true, {AirTargeting = true})
        AppendUnits(phase.AirAttackUnits, escortsAll)
    end

    return transports
end

local function Phase3TransportDropThread()
    if not WaitWhilePhase3(125, 'Gateway') then
        return
    end

    while not MissionState.MissionEnded
        and MissionState.CurrentPhase == 3
        and not MissionState.Phase3.ReinforcementGatewayDestroyed
        and not MissionState.Phase3.Finished
    do
        if CanSpawnPhase3Attack('GatewayUnits', 8) then
            SpawnTransportDrop()
        end
        if not WaitWhilePhase3(GetPhase3TransportInterval(), 'Gateway') then
            return
        end
    end
end

local function Phase3AttackDirectorThread()
    if not WaitWhilePhase3(65, nil) then
        return
    end

    while not MissionState.MissionEnded
        and MissionState.CurrentPhase == 3
        and not MissionState.Phase3.Finished
    do
        SpawnPhase3Attack()
        if not WaitWhilePhase3(GetPhase3AttackInterval(), nil) then
            return
        end
    end
end

function TriggerStrategicResponse()
    local phase = MissionState.Phase3
    if MissionState.MissionEnded
        or MissionState.CurrentPhase ~= 3
        or phase.Finished
        or phase.StrategicResponseTriggered
    then
        return
    end

    phase.StrategicResponseTriggered = true
    Log('RESPONSE', 'Strategic Response triggered')
    ScenarioFramework.Dialogue(Dialogues.Phase3StrategicResponse)

    LaunchConfiguredAttack('PHASE3_STRATEGIC_LAND', SelectPhase3AttackTarget())
    if not phase.RadarRewardApplied or MissionState.Difficulty == 3 then
        LaunchConfiguredAttack('PHASE3_STRATEGIC_AIR', SelectPhase3AttackTarget())
    end
end

function TriggerEmergencyResponse()
    local phase = MissionState.Phase3
    if MissionState.MissionEnded
        or MissionState.CurrentPhase ~= 3
        or phase.Finished
        or phase.EmergencyResponseTriggered
    then
        return
    end

    phase.EmergencyResponseTriggered = true
    Log('RESPONSE', 'Emergency Response triggered')
    ScenarioFramework.Dialogue(Dialogues.Phase3EmergencyResponse)

    LaunchConfiguredAttack('PHASE3_EMERGENCY_LAND', SelectPhase3AttackTarget())
    if not phase.RadarRewardApplied or MissionState.Difficulty == 3 then
        LaunchConfiguredAttack('PHASE3_EMERGENCY_AIR', SelectPhase3AttackTarget())
    end
    if not phase.ReinforcementGatewayDestroyed then
        AddThread('Phase3EmergencyDrop', ForkThread(SpawnTransportDrop))
    end
end

local function UpdatePhase3ResponseState()
    local count = CountPhase3PrimaryCompleted()
    if count >= 1 and not MissionState.Phase3.StrategicResponseTriggered then
        TriggerStrategicResponse()
    end
    if count >= 2 and not MissionState.Phase3.EmergencyResponseTriggered then
        TriggerEmergencyResponse()
    end
end

function CheckPhase3Completion()
    local phase = MissionState.Phase3
    if phase.Finished then
        return
    end
    if phase.ArtilleryDestroyed
        and phase.DefenseNodeDestroyed
        and phase.ReinforcementGatewayDestroyed
    then
        CompletePhase3()
    end
end

function CompleteArtilleryObjective()
    local phase = MissionState.Phase3
    if phase.ArtilleryDestroyed and MissionState.CompletedObjectives.Phase3Artillery then
        return
    end
    phase.ArtilleryDestroyed = true
    MarkObjectiveCompleted('Phase3Artillery')
    SetObjectiveManualResultIfActive(MissionState.Objectives.Phase3Artillery, true)
    StopMissionThread('Phase3Artillery')
    UpdatePhase3ResponseState()
    CheckPhase3Completion()
end

function CompleteDefenseObjective()
    local phase = MissionState.Phase3
    if phase.DefenseNodeDestroyed and MissionState.CompletedObjectives.Phase3Defense then
        return
    end
    phase.DefenseNodeDestroyed = true
    MarkObjectiveCompleted('Phase3Defense')
    SetObjectiveManualResultIfActive(MissionState.Objectives.Phase3Defense, true)
    StopMissionThread('Phase3DefenseRepair')
    if phase.Groups.DefenseEngineers then
        IssueClearCommands(phase.Groups.DefenseEngineers)
    end
    UpdatePhase3ResponseState()
    CheckPhase3Completion()
end

function CompleteGatewayObjective()
    local phase = MissionState.Phase3
    if phase.ReinforcementGatewayDestroyed and MissionState.CompletedObjectives.Phase3Gateway then
        return
    end
    phase.ReinforcementGatewayDestroyed = true
    MarkObjectiveCompleted('Phase3Gateway')
    SetObjectiveManualResultIfActive(MissionState.Objectives.Phase3Gateway, true)
    StopMissionThread('Phase3GatewayReinforcement')
    StopMissionThread('Phase3TransportDrops')
    UpdatePhase3ResponseState()
    CheckPhase3Completion()
end

local function CreatePhase3Objectives()
    local phase = MissionState.Phase3
    local artillery = MissionState.Targets.Phase3Artillery
    local defenseNode = MissionState.Targets.Phase3DefenseNode
    local gateway = MissionState.Targets.Phase3Gateway

    if not artillery or not defenseNode or not gateway then
        MissionFailure('Phase 3 objective structures missing')
        return false
    end

    local artilleryDestroyed = phase.ArtilleryDestroyed or not IsUnitAlive(artillery)
    local defenseDestroyed = phase.DefenseNodeDestroyed or not IsUnitAlive(defenseNode)
    local gatewayDestroyed = phase.ReinforcementGatewayDestroyed or not IsUnitAlive(gateway)

    MissionState.Objectives.Phase3Artillery = Objectives.Kill(
        'primary',
        artilleryDestroyed and 'complete' or 'incomplete',
        'Destroy Long-Range Artillery',
        'Destroy the Cybran artillery installation bombarding UEF positions.',
        {
            Units = {artillery},
            MarkUnits = true,
            AlwaysVisible = true,
            ShowFaction = 'Cybran',
        }
    )
    MissionState.Objectives.Phase3Defense = Objectives.Kill(
        'primary',
        defenseDestroyed and 'complete' or 'incomplete',
        'Disable the Heavy Defense Network',
        'Destroy the Cybran defense-control node coordinating the northern fortifications.',
        {
            Units = {defenseNode},
            MarkUnits = true,
            AlwaysVisible = true,
            ShowFaction = 'Cybran',
        }
    )
    MissionState.Objectives.Phase3Gateway = Objectives.Kill(
        'primary',
        gatewayDestroyed and 'complete' or 'incomplete',
        'Destroy the Reinforcement Gateway',
        'Neutralize the Cybran reinforcement staging facility before the final assault.',
        {
            Units = {gateway},
            MarkUnits = true,
            AlwaysVisible = true,
            ShowFaction = 'Cybran',
        }
    )

    if not artilleryDestroyed then
        MissionState.Objectives.Phase3Artillery:AddResultCallback(function(success)
            if success then CompleteArtilleryObjective() end
        end)
    end
    if not defenseDestroyed then
        MissionState.Objectives.Phase3Defense:AddResultCallback(function(success)
            if success then CompleteDefenseObjective() end
        end)
    end
    if not gatewayDestroyed then
        MissionState.Objectives.Phase3Gateway:AddResultCallback(function(success)
            if success then CompleteGatewayObjective() end
        end)
    end

    local radarsAlive = {}
    for _, radar in ipairs(phase.RadarUnits or {}) do
        if IsUnitAlive(radar) then table.insert(radarsAlive, radar) end
    end
    local radarDestroyed = phase.RadarNetworkDestroyed or table.getn(radarsAlive) == 0
    MissionState.Objectives.Phase3Radar = Objectives.Kill(
        'secondary',
        radarDestroyed and 'complete' or 'incomplete',
        'Destroy Strategic Radar',
        'Destroy the strategic radar to reduce transport drops and air-response coordination.',
        {
            Units = radarDestroyed and (phase.RadarUnits or {}) or radarsAlive,
            MarkUnits = true,
            AlwaysVisible = true,
            ShowFaction = 'Cybran',
        }
    )
    if not radarDestroyed then
        MissionState.Objectives.Phase3Radar:AddResultCallback(function(success)
            if success then ApplyPhase3RadarReward() end
        end)
    end

    local dataCore = MissionState.Targets.Phase3DataCore
    local dataDestroyed = phase.DataCoreDestroyed or not IsUnitAlive(dataCore)
    MissionState.Objectives.Phase3DataCore = Objectives.Kill(
        'secondary',
        dataDestroyed and 'complete' or 'incomplete',
        'Destroy the Cybran Data Core',
        'Destroy the data core to obtain a temporary reveal of the main-complex layout.',
        {
            Units = dataCore and {dataCore} or {},
            MarkUnits = true,
            AlwaysVisible = true,
            ShowFaction = 'Cybran',
        }
    )
    if dataCore and not dataDestroyed then
        MissionState.Objectives.Phase3DataCore:AddResultCallback(function(success)
            if success then OnPhase3DataCoreDestroyed() end
        end)
    end

    if radarDestroyed then ApplyPhase3RadarReward() end
    if dataDestroyed then OnPhase3DataCoreDestroyed() end
    if artilleryDestroyed then CompleteArtilleryObjective() end
    if defenseDestroyed then CompleteDefenseObjective() end
    if gatewayDestroyed then CompleteGatewayObjective() end
    return true
end

function UnlockFinaleArea()
    local phase = MissionState.Phase3
    if phase.FinaleUnlocked then
        return
    end
    phase.FinaleUnlocked = true
    ScenarioFramework.SetPlayableArea('AREA_FINALE', true)
    Log('MAP', 'Finale area unlocked')
end

function StartPhase4()
    if MissionState.MissionEnded or MissionState.CurrentPhase ~= 4 then
        return
    end
    if MissionState.Objectives.FinalePlaceholder then
        return
    end

    ScenarioFramework.Dialogue(Dialogues.FinaleReady)
    MissionState.Objectives.FinalePlaceholder = Objectives.Unknown(
        'primary',
        'incomplete',
        'Destroy the Cybran Command Complex',
        'The final assault is ready. Full finale logic is implemented in the next stage.'
    )
end

function CompletePhase3()
    local phase = MissionState.Phase3
    if MissionState.MissionEnded or phase.Finished then
        return
    end
    if not phase.ArtilleryDestroyed
        or not phase.DefenseNodeDestroyed
        or not phase.ReinforcementGatewayDestroyed
    then
        DebugLog('PHASE3', 'Completion ignored until all three strategic installations are destroyed')
        return
    end

    phase.Finished = true
    MarkObjectiveCompleted('Phase3')
    SetObjectiveManualResultIfActive(MissionState.Objectives.Phase3Artillery, true)
    SetObjectiveManualResultIfActive(MissionState.Objectives.Phase3Defense, true)
    SetObjectiveManualResultIfActive(MissionState.Objectives.Phase3Gateway, true)

    StopMissionThread('Phase3Artillery')
    StopMissionThread('Phase3DefenseRepair')
    StopMissionThread('Phase3GatewayReinforcement')
    StopMissionThread('Phase3TransportDrops')
    StopMissionThread('Phase3AttackDirector')
    StopMissionThread('Phase3EmergencyDrop')

    if phase.Groups.DefenseEngineers then
        IssueClearCommands(phase.Groups.DefenseEngineers)
    end

    Log('PHASE3', 'Complete')
    ScenarioFramework.Dialogue(Dialogues.Phase3Complete)
    ScenarioFramework.Dialogue(Dialogues.Phase3ExperimentalTease)
    UnlockFinaleArea()

    MissionState.CurrentPhase = 4
    StartPhase4()
end

function StartPhase3()
    local phase2 = MissionState.Phase2
    local phase = MissionState.Phase3
    if MissionState.MissionEnded or phase.Started then
        return
    end

    phase2.Phase3Started = true
    MissionState.CurrentPhase = 3
    phase.Started = true
    Log('PHASE3', 'Starting')
    ScenarioFramework.Dialogue(Dialogues.Phase3)

    SetUnitsFireState(phase.Groups.ArtilleryCore, 'Aggressive')
    SetUnitsFireState(phase.Groups.ArtilleryDefense, 'Aggressive')
    SetUnitsFireState(phase.Groups.ArtillerySupport, 'Aggressive')
    SetUnitsFireState(phase.Groups.DefenseStatic, 'Aggressive')
    SetUnitsFireState(phase.Groups.DefenseGarrison, 'Aggressive')
    SetUnitsFireState(phase.Groups.GatewayAA, 'Aggressive')
    SetUnitsFireState(phase.Groups.GatewaySupport, 'Aggressive')

    SetupPhase3Garrison(phase.Groups.ArtillerySupport, 'OTS_Phase3_Artillery_Support', 'CHAIN_PHASE3_ATTACK_WEST')
    SetupPhase3Garrison(phase.Groups.DefenseGarrison, 'OTS_Phase3_Defense_Garrison', 'CHAIN_PHASE3_ATTACK_CENTER')
    SetupPhase3Garrison(phase.Groups.GatewaySupport, 'OTS_Phase3_Gateway_Support', 'CHAIN_PHASE3_ATTACK_EAST')

    if not CreatePhase3Objectives() or MissionState.MissionEnded or phase.Finished then
        return
    end

    if not phase.ArtilleryDestroyed then
        AddThread('Phase3Artillery', ForkThread(Phase3ArtilleryThread))
        Log('ARTILLERY', 'Bombardment system active')
    end
    if not phase.DefenseNodeDestroyed then
        AddThread('Phase3DefenseRepair', ForkThread(Phase3DefenseRepairThread))
    end
    if not phase.ReinforcementGatewayDestroyed then
        AddThread('Phase3GatewayReinforcement', ForkThread(Phase3GatewayReinforcementThread))
        AddThread('Phase3TransportDrops', ForkThread(Phase3TransportDropThread))
    end
    AddThread('Phase3AttackDirector', ForkThread(Phase3AttackDirectorThread))
end

function InitializeMissionState()
    MissionState.CurrentPhase = 0
    MissionState.ActivePlayers = GetActivePlayerCount()
    MissionState.Difficulty = ClampDifficulty(ScenarioInfo.Options and ScenarioInfo.Options.Difficulty or 2)
    MissionState.DifficultyName = GetDifficultyScale().Name
    MissionState.Objectives = {}
    MissionState.CompletedObjectives = {}
    MissionState.MissionEnded = false
    MissionState.MissionStarted = false
    MissionState.PlayerCommanders = {}
    MissionState.PlayerAlive = {}
    MissionState.PlayerPresent = {}
    MissionState.Targets = {}
    MissionState.TargetDestroyed = {}
    MissionState.Threads = {}
    MissionState.Scale = {
        EnemyMultiplier = GetPlayerScale().EnemyMultiplier,
        DelayMultiplier = GetPlayerScale().DelayMultiplier,
        ResourceMultiplier = GetScaledResourceMultiplier(),
    }

    MissionState.ForwardGroups = {}
    MissionState.SpawnedWaves = {}
    MissionState.CancelledWaves = {}
    MissionState.WavePressure = {Player1 = 0, Player2 = 0}
    MissionState.ReinforcementUnits = {}
    MissionState.ReinforcementCounter = 0
    MissionState.ForwardObjectiveAssigned = false
    MissionState.RadarObjectiveAssigned = false
    MissionState.RadarDestroyed = false
    MissionState.RadarRewardApplied = false
    MissionState.CommandPostDestroyed = false
    MissionState.CounterattackStarted = false
    MissionState.CounterattackResolved = false
    MissionState.CounterattackUnits = {}
    MissionState.CounterattackInitialCount = 0
    MissionState.Phase1Completed = false
    MissionState.Phase2 = NewPhase2State()
    MissionState.Phase2.Limits = GetPhase2Limits()
    MissionState.Phase3 = NewPhase3State()
    MissionState.Phase3.Limits = GetPhase3Limits()

    ScenarioInfo.OperationTwinSpear = MissionState

    Log('INIT', 'Mission initialized')
    Log('PLAYER', 'Active players: ' .. tostring(MissionState.ActivePlayers))
    Log('INIT', string.format('Difficulty: %s (%d)', MissionState.DifficultyName, MissionState.Difficulty))
    Log('INIT', string.format('Enemy scale: %.2f', MissionState.Scale.EnemyMultiplier))
end

function InitializePlayers()
    if MissionState.ActivePlayers < 1 then
        Log('FAIL', 'No active player slots detected')
        return false
    end

    local playerDefinitions = {
        {
            Name = Army.Player1,
            Index = ScenarioInfo.Player1,
            Marker = 'PLAYER_1_START',
        },
        {
            Name = Army.Player2,
            Index = ScenarioInfo.Player2,
            Marker = 'PLAYER_2_START',
        },
    }

    for _, player in ipairs(playerDefinitions) do
        if IsArmyActive(player.Index, player.Name) then
            local commander = SpawnUnitAtMarker(player.Name, UnitBlueprints.UEF.Commander, player.Marker, 0)
            if not commander then
                Log('FAIL', 'Could not create ACU for ' .. player.Name)
                return false
            end

            MissionState.PlayerCommanders[player.Name] = commander
            MissionState.PlayerAlive[player.Name] = true
            MissionState.PlayerPresent[player.Name] = true

            if commander.PlayCommanderWarpInEffect then
                commander:PlayCommanderWarpInEffect()
            end

            ScenarioFramework.CreateUnitDeathTrigger(OnPlayerCommanderKilled, commander)
            Log('PLAYER', player.Name .. ' ACU spawned')
        end
    end

    ScenarioFramework.SetUEFPlayerColor(ScenarioInfo.Player1)
    if IsArmyActive(ScenarioInfo.Player2, Army.Player2) then
        ScenarioFramework.SetUEFAllyColor(ScenarioInfo.Player2)
    end

    return true
end

function InitializeEnemyArmies()
    ConfigureAlliances()
    ScenarioFramework.SetCybranColor(ScenarioInfo.CybranMain)
    ScenarioFramework.SetCybranColor(ScenarioInfo.CybranOutpost)

    local production = SpawnEditorGroup(Army.EnemyOutpost, 'FORWARD_PRODUCTION')
    MissionState.ForwardGroups.Production = production

    if MissionState.Difficulty >= 2 then
        AppendUnits(MissionState.ForwardGroups.Production, SpawnEditorGroup(Army.EnemyOutpost, 'FORWARD_PRODUCTION_EXTRA_D2'))
    end

    MissionState.ForwardGroups.Economy = SpawnEditorGroup(Army.EnemyOutpost, 'FORWARD_ECONOMY')
    MissionState.ForwardGroups.Defense = SpawnEditorGroup(Army.EnemyOutpost, 'FORWARD_DEFENSE')

    if MissionState.Difficulty >= 2 then
        AppendUnits(MissionState.ForwardGroups.Defense, SpawnEditorGroup(Army.EnemyOutpost, 'FORWARD_DEFENSE_NORMAL'))
    end
    if MissionState.Difficulty == 3 then
        AppendUnits(MissionState.ForwardGroups.Defense, SpawnEditorGroup(Army.EnemyOutpost, 'FORWARD_DEFENSE_HARD'))
    end

    local commandUnits = SpawnEditorGroup(Army.EnemyOutpost, 'FORWARD_COMMAND')
    MissionState.ForwardGroups.Command = commandUnits
    MissionState.Targets.ForwardCommand = GetNamedArmyUnit(Army.EnemyOutpost, 'Forward_Command_Post')

    local radarUnits = SpawnEditorGroup(Army.EnemyOutpost, 'FORWARD_RADAR')
    MissionState.ForwardGroups.Radar = radarUnits
    MissionState.Targets.Radar = GetNamedArmyUnit(Army.EnemyOutpost, 'Forward_Radar')

    MissionState.ForwardGroups.Garrison = SpawnEditorGroup(Army.EnemyOutpost, 'FORWARD_GARRISON')

    local commandPost = MissionState.Targets.ForwardCommand
    if not IsUnitAlive(commandPost) then
        Log('FAIL', 'Forward Command Post could not be created from FORWARD_COMMAND')
        return false
    end

    commandPost:SetCapturable(false)
    commandPost:SetReclaimable(false)
    commandPost:SetCustomName('Cybran Forward Command Post')

    local radar = MissionState.Targets.Radar
    if IsUnitAlive(radar) then
        radar:SetCapturable(false)
        radar:SetReclaimable(false)
        radar:SetCustomName('Cybran Forward Radar')
        ScenarioFramework.CreateUnitDeathTrigger(OnRadarDestroyed, radar)
    end

    ScenarioFramework.CreateUnitDeathTrigger(
        function()
            if not MissionState.ForwardObjectiveAssigned then
                ActivateForwardObjective('early Command Post destruction')
            end
            HandleForwardCommandDestroyed()
        end,
        commandPost
    )

    local garrisonBrain = GetArmyBrain(Army.EnemyOutpost)
    if garrisonBrain and MissionState.ForwardGroups.Garrison then
        local garrisonPlatoon = garrisonBrain:MakePlatoon('OTS_Forward_Garrison', 'NoPlan')
        garrisonBrain:AssignUnitsToPlatoon(
            garrisonPlatoon,
            MissionState.ForwardGroups.Garrison,
            'Attack',
            'AttackFormation'
        )
        ScenarioFramework.PlatoonPatrolChain(garrisonPlatoon, 'CHAIN_FORWARD_GARRISON')
    end

    Log('INIT', 'Forward Cybran Outpost initialized from save.lua groups')

    if not InitializePhase2EnemyForces() then
        return false
    end
    if not InitializePhase3EnemyForces() then
        return false
    end

    return true
end

function StartPhase1()
    if MissionState.MissionEnded or MissionState.Phase1Completed then
        return
    end

    if MissionState.CurrentPhase == 1 then
        return
    end

    MissionState.CurrentPhase = 1
    Log('PHASE1', 'Starting')

    RegisterForwardDiscoveryTriggers()
    AddThread('Phase1WaveTimeline', ForkThread(Phase1WaveTimelineThread))
    AddThread('ForwardReinforcements', ForkThread(ForwardReinforcementThread))
end

function CompletePhase1()
    if MissionState.MissionEnded or MissionState.Phase1Completed then
        return
    end

    if not MissionState.CommandPostDestroyed then
        DebugLog('PHASE1', 'Completion ignored: Command Post still active')
        return
    end

    if MissionState.CounterattackStarted and not MissionState.CounterattackResolved then
        DebugLog('PHASE1', 'Completion ignored: counterattack still active')
        return
    end

    MissionState.Phase1Completed = true
    MarkObjectiveCompleted('Phase1')
    Log('PHASE1', 'Completed')

    ScenarioFramework.Dialogue(Dialogues.Phase1Complete)
    ScenarioFramework.SetPlayableArea('AREA_PHASE_2', true)
    Log('MAP', 'Expanding playable area: AREA_PHASE_2')

    AddThread(
        'Phase2Transition',
        ForkThread(
            function()
                WaitSeconds(GetScaledDelay(8))
                if not MissionState.MissionEnded then
                    StartPhase2()
                end
            end
        )
    )
end

function StartPhase2()
    local phase = MissionState.Phase2
    if MissionState.MissionEnded
        or phase.Started
        or MissionState.CurrentPhase > 2
    then
        return
    end

    MissionState.CurrentPhase = 2
    phase.Started = true
    Log('PHASE2', 'Starting')
    ScenarioFramework.Dialogue(Dialogues.Phase2)

    if not CreatePhase2Objectives() or MissionState.MissionEnded then
        return
    end
    if phase.Finished then
        return
    end

    if not phase.WestCompleted then
        AddThread('Phase2WestAttack', ForkThread(WestAttackThread))
        AddThread('Phase2WestConvoys', ForkThread(WestConvoyThread))
        AddThread('Phase2WestEngineers', ForkThread(Phase2EngineerSupportThread, 'West'))
    end

    if not phase.EastCompleted then
        AddThread('Phase2EastAir', ForkThread(EastAirAttackThread))
        AddThread('Phase2EastPatrols', ForkThread(EastPatrolThread))
        AddThread('Phase2EastEngineers', ForkThread(Phase2EngineerSupportThread, 'East'))
    end
end

function MissionVictory()
    if MissionState.MissionEnded then
        return
    end

    MissionState.MissionEnded = true
    MissionState.CurrentPhase = 99
    Log('VICTORY', 'Mission completed')
    ScenarioFramework.EndOperation(true, true, false, false)
end

function MissionFailure(reason)
    if MissionState.MissionEnded then
        return
    end

    MissionState.MissionEnded = true
    MissionState.CurrentPhase = -1
    Log('FAIL', reason or 'Mission failed')
    ScenarioFramework.EndOperation(false, false, false, false)
end

function StartMission()
    if MissionState.MissionEnded or MissionState.MissionStarted then
        return
    end

    MissionState.MissionStarted = true
    Log('PHASE', 'Mission flow started')

    if DEBUG and DEBUG_OPTIONS.StartPhase3Immediately then
        MissionState.CommandPostDestroyed = true
        MissionState.CounterattackStarted = true
        MissionState.CounterattackResolved = true
        MissionState.Phase1Completed = true
        MissionState.Phase2.Started = true
        MissionState.Phase2.WestCompleted = true
        MissionState.Phase2.EastCompleted = true
        ScenarioFramework.SetPlayableArea('AREA_PHASE_3', false)
        MissionState.CurrentPhase = 3
        StartPhase3()
        return
    end

    if DEBUG and DEBUG_OPTIONS.StartPhase2Immediately then
        MissionState.CommandPostDestroyed = true
        MissionState.CounterattackStarted = true
        MissionState.CounterattackResolved = true
        MissionState.Phase1Completed = true
        ScenarioFramework.SetPlayableArea('AREA_PHASE_2', false)
        StartPhase2()
        return
    end

    if DEBUG and DEBUG_OPTIONS.StartPhase1Immediately then
        StartPhase1()
        return
    end

    if not (DEBUG and DEBUG_OPTIONS.SkipIntro) then
        WaitSeconds(GetScaledDelay(8))
        if MissionState.MissionEnded then return end
        ScenarioFramework.Dialogue(Dialogues.Intro1)

        WaitSeconds(GetScaledDelay(14))
        if MissionState.MissionEnded then return end
        ScenarioFramework.Dialogue(Dialogues.Intro2)
    end

    StartPhase1()
end

local function InitializeDebugControls()
    if not DEBUG then
        return
    end

    OTS_Debug = {
        Options = DEBUG_OPTIONS,

        SpawnWave = function(name)
            return SpawnAttackWave(name)
        end,

        CompleteForwardObjective = function()
            local target = MissionState.Targets.ForwardCommand
            if IsUnitAlive(target) then
                target:Kill()
            else
                ActivateForwardObjective('debug completion')
                HandleForwardCommandDestroyed()
            end
        end,

        StartCounterattack = function()
            StartCounterattack()
        end,

        CompletePhase1 = function()
            MissionState.CommandPostDestroyed = true
            MissionState.CounterattackStarted = true
            MissionState.CounterattackResolved = true
            CompletePhase1()
        end,

        StartPhase2 = function()
            if MissionState.CurrentPhase < 2 then
                MissionState.Phase1Completed = true
                MissionState.CurrentPhase = 1
            end
            StartPhase2()
        end,

        CompleteWestObjective = function()
            local target = MissionState.Targets.WestLogisticsCommand
            if IsUnitAlive(target) then
                target:Kill()
            else
                CompleteWestObjective()
            end
        end,

        CompleteEastObjective = function()
            local target = MissionState.Targets.EastAirControlCommand
            if IsUnitAlive(target) then
                target:Kill()
            else
                CompleteEastObjective()
            end
        end,

        TriggerCentralResponse = function()
            TriggerCentralResponse()
        end,

        SpawnWestConvoy = function()
            return SpawnWestConvoy()
        end,

        SpawnEastAirRaid = function(name)
            return SpawnEastAirRaid(name or 'BOMBER_STRIKE')
        end,

        CompletePhase2 = function()
            CompleteWestObjective()
            CompleteEastObjective()
            CompletePhase2()
        end,

        StartPhase3 = function()
            if MissionState.CurrentPhase < 3 then
                MissionState.Phase2.Started = true
                MissionState.Phase2.WestCompleted = true
                MissionState.Phase2.EastCompleted = true
                MissionState.CurrentPhase = 3
            end
            ScenarioFramework.SetPlayableArea('AREA_PHASE_3', true)
            StartPhase3()
        end,

        CompleteArtilleryObjective = function()
            local target = MissionState.Targets.Phase3Artillery
            if IsUnitAlive(target) then target:Kill() else CompleteArtilleryObjective() end
        end,

        CompleteDefenseObjective = function()
            local target = MissionState.Targets.Phase3DefenseNode
            if IsUnitAlive(target) then target:Kill() else CompleteDefenseObjective() end
        end,

        CompleteGatewayObjective = function()
            local target = MissionState.Targets.Phase3Gateway
            if IsUnitAlive(target) then target:Kill() else CompleteGatewayObjective() end
        end,

        TriggerStrategicResponse = function()
            TriggerStrategicResponse()
        end,

        TriggerEmergencyResponse = function()
            TriggerEmergencyResponse()
        end,

        SpawnTransportDrop = function()
            AddThread('DebugTransportDrop', ForkThread(SpawnTransportDrop))
        end,

        SpawnPhase3Attack = function()
            return SpawnPhase3Attack()
        end,

        CompletePhase3 = function()
            CompleteArtilleryObjective()
            CompleteDefenseObjective()
            CompleteGatewayObjective()
            CompletePhase3()
        end,

        UnlockFinaleArea = function()
            UnlockFinaleArea()
        end,
    }

    Log('DEBUG', 'OTS_Debug console controls enabled')
end

function OnPopulate(scenario)
    ScenarioUtils.InitializeScenarioArmies()
    InitializeMissionState()

    if not InitializePlayers() then
        MissionFailure('Player initialization failed')
        return
    end

    if not InitializeEnemyArmies() then
        MissionFailure('Enemy initialization failed')
        return
    end
end

function OnStart(scenario)
    if MissionState.MissionEnded then
        return
    end

    ScenarioFramework.SetSharedUnitCap(1000)
    ScenarioFramework.SetPlayableArea('AREA_PHASE_1', false)
    Log('MAP', 'Playable area: AREA_PHASE_1')

    InitializeDebugControls()
    AddThread('PlayerPresence', ForkThread(PlayerPresenceThread))
    AddThread('MissionStart', ForkThread(StartMission))
end
