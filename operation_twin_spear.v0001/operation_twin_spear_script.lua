local Objectives = import('/lua/simobjectives.lua')
local ScenarioFramework = import('/lua/scenarioframework.lua')
local ScenarioUtils = import('/lua/sim/scenarioutilities.lua')

local DEBUG = false

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
        ForwardCommandPost = 'urb0301',
        FinalTestTarget = 'urb2302',
        LightAssaultBot = 'url0106',
        HeavyAssaultBot = 'url0107',
        AirScout = 'ura0101',
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
    local value = baseCount * GetPlayerScale().EnemyMultiplier * GetDifficultyScale().UnitMultiplier
    return math.max(1, math.ceil(value))
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

local function SpawnUnitAtPosition(armyName, blueprintId, position, heading)
    if not position then
        return nil
    end

    local brain = GetArmyBrain(armyName)
    if not brain then
        Log('FAIL', 'Army brain unavailable: ' .. tostring(armyName))
        return nil
    end

    local unit = CreateUnitHPR(
        blueprintId,
        armyName,
        position[1], position[2], position[3],
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

local function SpawnOffsetUnit(armyName, blueprintId, markerName, offsetX, offsetZ, heading)
    local base = GetMarkerPosition(markerName)
    if not base then
        return nil
    end

    return SpawnUnitAtPosition(
        armyName,
        blueprintId,
        {base[1] + offsetX, base[2], base[3] + offsetZ},
        heading
    )
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

local function SpawnOutpostDefenders()
    local lightCount = GetScaledUnitCount(3)
    local heavyCount = GetScaledUnitCount(1)
    local radius = 20

    for i = 1, lightCount do
        local angle = (i - 1) * 6.283185307179586 / lightCount
        SpawnOffsetUnit(
            Army.EnemyOutpost,
            UnitBlueprints.Cybran.LightAssaultBot,
            'ENEMY_OUTPOST_BASE',
            math.cos(angle) * radius,
            math.sin(angle) * radius,
            angle
        )
    end

    for i = 1, heavyCount do
        local xOffset = (i - (heavyCount + 1) / 2) * 8
        SpawnOffsetUnit(
            Army.EnemyOutpost,
            UnitBlueprints.Cybran.HeavyAssaultBot,
            'ENEMY_OUTPOST_BASE',
            xOffset,
            -14,
            3.141592653589793
        )
    end

    DebugLog('SPAWN', string.format('Outpost defenders: %d light, %d heavy', lightCount, heavyCount))
end

local function RegisterEarlyTargetDeath(targetKey, unit)
    if not IsUnitAlive(unit) then
        MissionState.TargetDestroyed[targetKey] = true
        return
    end

    ScenarioFramework.CreateUnitDeathTrigger(
        function()
            MissionState.TargetDestroyed[targetKey] = true
            DebugLog('TARGET', targetKey .. ' destroyed')
        end,
        unit
    )
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

    local forwardTarget = SpawnUnitAtMarker(
        Army.EnemyOutpost,
        UnitBlueprints.Cybran.ForwardCommandPost,
        'OBJECTIVE_OUTPOST',
        3.141592653589793
    )

    if not forwardTarget then
        Log('FAIL', 'Forward command target could not be created')
        return false
    end

    forwardTarget:SetCapturable(false)
    forwardTarget:SetReclaimable(false)
    forwardTarget:SetCustomName('Cybran Forward Command Post')

    MissionState.Targets.ForwardCommand = forwardTarget
    RegisterEarlyTargetDeath('ForwardCommand', forwardTarget)

    SpawnOutpostDefenders()

    Log('INIT', 'Enemy armies initialized')
    return true
end

function StartPhase1()
    if MissionState.MissionEnded or MissionState.CompletedObjectives.Phase1 then
        return
    end

    MissionState.CurrentPhase = 1
    Log('PHASE', 'Starting Phase 1')

    local target = MissionState.Targets.ForwardCommand
    if not IsUnitAlive(target) then
        Log('OBJECTIVE', 'Forward Command was destroyed before objective activation')
        CompletePhase1()
        return
    end

    local objective = Objectives.Kill(
        'primary',
        'incomplete',
        'Destroy the Cybran Forward Command Post',
        'Destroy the Cybran forward position and secure the sector.',
        {
            Units = {target},
            MarkUnits = true,
            AlwaysVisible = true,
            ShowFaction = 'Cybran',
        }
    )

    MissionState.Objectives.Phase1 = objective
    Log('OBJECTIVE', 'Forward Command objective created')

    objective:AddResultCallback(
        function(success)
            if MissionState.MissionEnded or MissionState.CompletedObjectives.Phase1 then
                return
            end

            if success then
                Log('OBJECTIVE', 'Forward Command destroyed')
                CompletePhase1()
            else
                MissionFailure('Forward Command objective failed')
            end
        end
    )
end

function CompletePhase1()
    if MissionState.MissionEnded or MissionState.CompletedObjectives.Phase1 then
        return
    end

    MarkObjectiveCompleted('Phase1')
    SetObjectiveManualResultIfActive(MissionState.Objectives.Phase1, true)
    Log('PHASE', 'Phase 1 complete')

    AddThread(
        'Phase2Delay',
        ForkThread(
            function()
                WaitSeconds(GetScaledDelay(3))
                if not MissionState.MissionEnded then
                    StartPhase2()
                end
            end
        )
    )
end

function StartPhase2()
    if MissionState.MissionEnded or MissionState.CompletedObjectives.Phase2 then
        return
    end

    MissionState.CurrentPhase = 2
    Log('PHASE', 'Starting Phase 2 test')

    local target = SpawnUnitAtMarker(
        Army.EnemyMain,
        UnitBlueprints.Cybran.FinalTestTarget,
        'OBJECTIVE_FINAL_TEST',
        3.141592653589793
    )

    if not target then
        MissionFailure('Final test target could not be created')
        return
    end

    target:SetCapturable(false)
    target:SetReclaimable(false)
    target:SetCustomName('Cybran Fire-Control Artillery')
    MissionState.Targets.FinalTest = target
    RegisterEarlyTargetDeath('FinalTest', target)

    local objective = Objectives.Kill(
        'primary',
        'incomplete',
        'Destroy the Cybran Fire-Control Artillery',
        'Destroy the final Cybran fire-control asset to complete the Stage 1 mission test.',
        {
            Units = {target},
            MarkUnits = true,
            AlwaysVisible = true,
            ShowFaction = 'Cybran',
        }
    )

    MissionState.Objectives.Phase2 = objective
    Log('OBJECTIVE', 'Final test objective created')

    objective:AddResultCallback(
        function(success)
            if MissionState.MissionEnded or MissionState.CompletedObjectives.Phase2 then
                return
            end

            if success then
                MarkObjectiveCompleted('Phase2')
                Log('OBJECTIVE', 'Final test objective completed')
                MissionVictory()
            else
                MissionFailure('Final test objective failed')
            end
        end
    )
end

function MissionVictory()
    if MissionState.MissionEnded then
        return
    end

    MissionState.MissionEnded = true
    MissionState.CurrentPhase = 99

    SetObjectiveManualResultIfActive(MissionState.Objectives.Phase1, true)
    SetObjectiveManualResultIfActive(MissionState.Objectives.Phase2, true)
    MarkObjectiveCompleted('Phase1')
    MarkObjectiveCompleted('Phase2')

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

    WaitSeconds(GetScaledDelay(3))
    if not MissionState.MissionEnded then
        StartPhase1()
    end
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
    AddThread('PlayerPresence', ForkThread(PlayerPresenceThread))
    AddThread('MissionStart', ForkThread(StartMission))
end
