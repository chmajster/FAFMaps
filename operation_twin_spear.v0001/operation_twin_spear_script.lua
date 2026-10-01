local Objectives = import('/lua/simobjectives.lua')
local ScenarioFramework = import('/lua/scenarioframework.lua')
local ScenarioUtils = import('/lua/sim/scenarioutilities.lua')

local DEBUG = false
local DEBUG_OPTIONS = {
    StartPhase1Immediately = false,
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
        Interceptor = 'ura0102',
        Bomber = 'ura0103',
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
            text = '[UEF Command]: New sector unlocked. Advance north and stand by for updated objectives.',
            faction = 'UEF',
            duration = 5,
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

local function GetMarkerPosition(markerName)
    local marker = ScenarioUtils.GetMarker(markerName)
    if not marker or not marker.position then
        Log('FAIL', 'Required marker missing: ' .. tostring(markerName))
        return nil
    end
    return marker.position
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

local function IssueWaveOrders(units, target, air)
    if not units or table.getn(units) == 0 or not target then
        return
    end

    if air then
        local markerName = target == Army.Player2 and 'P2_ATTACK_TARGET' or 'P1_ATTACK_TARGET'
        IssueAggressiveMove(units, GetMarkerPosition(markerName))
        return
    end

    local chainName = target == Army.Player2 and 'CHAIN_FORWARD_TO_P2' or 'CHAIN_FORWARD_TO_P1'
    for _, position in ipairs(ScenarioUtils.ChainToPositions(chainName)) do
        IssueAggressiveMove(units, position)
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
    if MissionState.Difficulty == 3 then
        SpawnComposition(config.HardUnits)
    end

    return units
end

function SpawnAttackWave(configOrName)
    if MissionState.MissionEnded or MissionState.CurrentPhase ~= 1 then
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

    local name = config.Name or 'UnnamedWave'
    if MissionState.CancelledWaves[name] then
        Log('WAVE', 'Skip cancelled wave ' .. name)
        return {}
    end

    if MissionState.SpawnedWaves[name] and not config.AllowRepeat then
        DebugLog('WAVE', 'Duplicate wave ignored: ' .. name)
        return {}
    end

    if MissionState.CommandPostDestroyed and not config.AllowAfterCommand then
        DebugLog('WAVE', 'Wave suppressed after Command Post destruction: ' .. name)
        return {}
    end

    MissionState.SpawnedWaves[name] = true
    Log('WAVE', 'Spawn ' .. name)

    local units = SpawnWaveUnits(config)
    if table.getn(units) == 0 then
        Log('WARN', 'Wave spawned no units: ' .. name)
        return units
    end

    local brain = GetArmyBrain(config.Army)
    if brain then
        local platoon = brain:MakePlatoon(name, 'NoPlan')
        brain:AssignUnitsToPlatoon(platoon, units, 'Attack', config.Air and 'NoFormation' or 'AttackFormation')
    end

    if config.SplitTargets and table.getn(GetAvailableWaveTargets()) >= 2 then
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
            IssueWaveOrders(p1Units, Army.Player1, config.Air)
        end
        if table.getn(p2Units) > 0 then
            Log('WAVE', 'Target Player2')
            IssueWaveOrders(p2Units, Army.Player2, config.Air)
        end
    else
        local target = SelectWaveTarget(config.PreferredTarget)
        if target then
            Log('WAVE', 'Target ' .. target)
            IssueWaveOrders(units, target, config.Air)
        end
    end

    if config.Reinforcement then
        AppendUnits(MissionState.ReinforcementUnits, units)
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
    if MissionState.MissionEnded or MissionState.CurrentPhase >= 2 then
        return
    end

    MissionState.CurrentPhase = 2
    Log('PHASE2', 'Placeholder started')
    ScenarioFramework.Dialogue(Dialogues.Phase2)

    MissionState.Objectives.Phase2Placeholder = Objectives.Unknown(
        'primary',
        'incomplete',
        'Investigate the Northern Cybran Network',
        'Advance into the newly opened sector and await updated intelligence.'
    )
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
