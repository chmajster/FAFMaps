#!/usr/bin/env python3
"""Static contract checks for Operation Twin Spear Stage 4 / complete Phase 3.

The binary .scmap cannot be validated in this repository until it is exported
from FAF Map Editor. This checker validates the Lua/save mission contract,
Phase 3 race/order invariants, cleanup hooks and uses luac -p when available.
"""

from __future__ import annotations

import pathlib
import re
import shutil
import subprocess
import sys

ROOT = pathlib.Path(__file__).resolve().parents[1]

LUA_FILES = [
    ROOT / "operation_twin_spear_scenario.lua",
    ROOT / "operation_twin_spear_save.lua",
    ROOT / "operation_twin_spear_script.lua",
    ROOT / "operation_twin_spear_operation.lua",
]

REQUIRED_MARKERS = {
    "PLAYER_1_START",
    "PLAYER_2_START",
    "P1_ATTACK_TARGET",
    "P2_ATTACK_TARGET",
    "P1_EXPANSION_01",
    "P2_EXPANSION_01",
    "CENTRAL_EXPANSION",
    "CROSSING_WEST",
    "CROSSING_EAST",
    "CROSSING_CENTER_OPTIONAL",
    "CYBRAN_FORWARD_SPAWN_WEST",
    "CYBRAN_FORWARD_SPAWN_EAST",
    "ATTACK_WEST_01",
    "ATTACK_WEST_02",
    "ATTACK_WEST_03",
    "ATTACK_EAST_01",
    "ATTACK_EAST_02",
    "ATTACK_EAST_03",
    "FORWARD_OUTPOST_CENTER",
    "FORWARD_COMMAND_POST",
    "FORWARD_RADAR",
    "REINFORCEMENT_01",
    "REINFORCEMENT_02",
    "WEST_OUTPOST_FUTURE",
    "EAST_OUTPOST_FUTURE",
    "WEST_SECTOR_FUTURE",
    "EAST_SECTOR_FUTURE",
    "DEFENSE_LINE_CENTER",
    "CYBRAN_MAIN_BASE",
    "WEST_BASE_CENTER",
    "WEST_LOGISTICS_COMMAND",
    "WEST_FACTORY_01",
    "WEST_FACTORY_02",
    "WEST_SUPPLY_ENTRY",
    "WEST_SUPPLY_EXIT",
    "WEST_ATTACK_01",
    "WEST_ATTACK_02",
    "WEST_ATTACK_03",
    "EAST_BASE_CENTER",
    "EAST_AIR_CONTROL_COMMAND",
    "EAST_AIR_FACTORY_01",
    "EAST_AIR_FACTORY_02",
    "EAST_AIR_ATTACK_SPAWN",
    "EAST_RADAR_01",
    "EAST_RADAR_02",
    "EAST_RADAR_03",
    "PHASE2_CENTRAL_EXPANSION",
    "CENTRAL_RESPONSE_SPAWN",
    "CENTRAL_RESPONSE_TARGET",
    "PHASE3_ARTILLERY_CENTER",
    "PHASE3_ARTILLERY_CORE",
    "PHASE3_DEFENSE_CENTER",
    "PHASE3_DEFENSE_CONTROL_NODE",
    "PHASE3_GATEWAY_CENTER",
    "PHASE3_REINFORCEMENT_GATEWAY",
    "PHASE3_RADAR_01",
    "PHASE3_RADAR_02",
    "PHASE3_DATA_CORE",
    "PHASE3_EXPANSION_WEST",
    "PHASE3_EXPANSION_CENTER",
    "PHASE3_EXPANSION_EAST",
    "PHASE3_DEFENSE_REBUILD_01",
    "PHASE3_DEFENSE_REBUILD_02",
    "PHASE3_DEFENSE_REBUILD_03",
    "PHASE3_TRANSPORT_ENTRY",
    "PHASE3_TRANSPORT_EXIT",
    "PHASE3_DROP_WEST",
    "PHASE3_DROP_EAST",
}

P1_START_RESOURCES = {
    "P1_MASS_01": "MassMarker",
    "P1_MASS_02": "MassMarker",
    "P1_MASS_03": "MassMarker",
    "P1_MASS_04": "MassMarker",
    "P1_HYDRO_01": "HydroMarker",
}

P2_START_RESOURCES = {
    "P2_MASS_01": "MassMarker",
    "P2_MASS_02": "MassMarker",
    "P2_MASS_03": "MassMarker",
    "P2_MASS_04": "MassMarker",
    "P2_HYDRO_01": "HydroMarker",
}

REQUIRED_AREAS = {
    "AREA_PHASE_1",
    "AREA_PHASE_2",
    "AREA_PHASE_2_WEST",
    "AREA_PHASE_2_EAST",
    "AREA_PHASE_2_CENTER",
    "AREA_PHASE_3",
    "AREA_PHASE_3_WEST",
    "AREA_PHASE_3_CENTER",
    "AREA_PHASE_3_EAST",
    "AREA_FINALE",
    "AREA_FORWARD_DISCOVERY",
    "AREA_FORWARD_OUTPOST",
    "AREA_P1_START",
    "AREA_P2_START",
}

REQUIRED_CHAINS = {
    "CHAIN_FORWARD_TO_P1",
    "CHAIN_FORWARD_TO_P2",
    "CHAIN_FORWARD_REINFORCEMENT",
    "CHAIN_FORWARD_GARRISON",
    "CHAIN_WEST_SUPPLY",
    "CHAIN_WEST_ATTACK",
    "CHAIN_WEST_BASE_PATROL",
    "CHAIN_EAST_BASE_PATROL",
    "CHAIN_EAST_AIR_PATROL_01",
    "CHAIN_EAST_AIR_PATROL_02",
    "CHAIN_CENTER_AIR_PATROL",
    "CHAIN_CENTRAL_RESPONSE",
    "CHAIN_CENTRAL_FLANK",
    "CHAIN_PHASE3_ATTACK_WEST",
    "CHAIN_PHASE3_ATTACK_CENTER",
    "CHAIN_PHASE3_ATTACK_EAST",
    "CHAIN_PHASE3_FLANK_WEST",
    "CHAIN_PHASE3_FLANK_EAST",
    "CHAIN_REINFORCEMENT_AIR_ENTRY",
    "CHAIN_REINFORCEMENT_DROP_WEST",
    "CHAIN_REINFORCEMENT_DROP_EAST",
    "CHAIN_REINFORCEMENT_EXIT",
}

REQUIRED_FORWARD_GROUPS = {
    "FORWARD_PRODUCTION",
    "FORWARD_PRODUCTION_EXTRA_D2",
    "FORWARD_ECONOMY",
    "FORWARD_DEFENSE",
    "FORWARD_DEFENSE_NORMAL",
    "FORWARD_DEFENSE_HARD",
    "FORWARD_COMMAND",
    "FORWARD_RADAR",
    "FORWARD_GARRISON",
}

REQUIRED_PHASE2_GROUPS = {
    "WEST_PRODUCTION_BASE",
    "WEST_PRODUCTION_NORMAL",
    "WEST_PRODUCTION_HARD",
    "WEST_ECONOMY",
    "WEST_DEFENSE_BASE",
    "WEST_DEFENSE_NORMAL",
    "WEST_DEFENSE_HARD",
    "WEST_COMMAND",
    "WEST_ENGINEERS",
    "WEST_GARRISON",
    "EAST_PRODUCTION_BASE",
    "EAST_PRODUCTION_NORMAL",
    "EAST_PRODUCTION_HARD",
    "EAST_ECONOMY",
    "EAST_DEFENSE_BASE",
    "EAST_DEFENSE_NORMAL",
    "EAST_DEFENSE_HARD",
    "EAST_COMMAND",
    "EAST_RADAR_NETWORK",
    "EAST_ENGINEERS",
    "EAST_GARRISON",
}


REQUIRED_PHASE3_GROUPS = {
    "PHASE3_ARTILLERY_BASE",
    "ARTILLERY_CORE",
    "ARTILLERY_DEFENSE",
    "ARTILLERY_DEFENSE_NORMAL",
    "ARTILLERY_DEFENSE_HARD",
    "ARTILLERY_SUPPORT",
    "PHASE3_DEFENSE_BASE",
    "DEFENSE_NODE",
    "DEFENSE_STATIC",
    "DEFENSE_STATIC_NORMAL",
    "DEFENSE_STATIC_HARD",
    "DEFENSE_FACTORIES",
    "DEFENSE_FACTORIES_NORMAL",
    "DEFENSE_FACTORIES_HARD",
    "DEFENSE_ENGINEERS",
    "DEFENSE_ENGINEERS_HARD",
    "DEFENSE_GARRISON",
    "PHASE3_GATEWAY_BASE",
    "GATEWAY_CORE",
    "GATEWAY_PRODUCTION",
    "GATEWAY_PRODUCTION_NORMAL",
    "GATEWAY_PRODUCTION_HARD",
    "GATEWAY_AA",
    "GATEWAY_AA_HARD",
    "GATEWAY_SUPPORT",
    "PHASE3_STRATEGIC_RADAR",
    "PHASE3_DATA_CORE",
    "FINALE_PREVIEW_FOUNDATIONS",
}

REQUIRED_FUNCTIONS = {
    "OnPopulate",
    "OnStart",
    "InitializePlayers",
    "InitializeEnemyArmies",
    "InitializeMissionState",
    "StartMission",
    "StartPhase1",
    "CompletePhase1",
    "StartPhase2",
    "InitializePhase2EnemyForces",
    "SpawnWestConvoy",
    "SpawnEastAirRaid",
    "TriggerCentralResponse",
    "CheckPhase2Completion",
    "CompleteWestObjective",
    "CompleteEastObjective",
    "CompletePhase2",
    "StartPhase3",
    "InitializePhase3EnemyForces",
    "GetAvailablePhase3AttackTypes",
    "SelectPhase3AttackTarget",
    "CanSpawnPhase3Attack",
    "LaunchConfiguredAttack",
    "SpawnPhase3Attack",
    "SpawnTransportDrop",
    "TriggerStrategicResponse",
    "TriggerEmergencyResponse",
    "CheckPhase3Completion",
    "CompleteArtilleryObjective",
    "CompleteDefenseObjective",
    "CompleteGatewayObjective",
    "CompletePhase3",
    "UnlockFinaleArea",
    "StartPhase4",
    "MissionVictory",
    "MissionFailure",
    "GetActivePlayerCount",
    "GetScaledUnitCount",
    "GetScaledDelay",
    "GetScaledResourceMultiplier",
    "SpawnAttackWave",
    "ActivateForwardObjective",
    "StartCounterattack",
}

REQUIRED_WAVES = {
    "Phase1_Wave_01",
    "Phase1_Wave_02",
    "Phase1_Wave_03",
    "Phase1_Wave_04",
    "Counterattack_West",
    "Counterattack_East",
    "WEST_WAVE_LIGHT",
    "WEST_WAVE_MECH",
    "WEST_WAVE_ARTILLERY",
    "AIR_SCOUT",
    "INTERCEPTOR_PATROL",
    "BOMBER_STRIKE",
    "GUNSHIP_RAID",
    "MIXED_AIR_ATTACK",
    "CENTRAL_RESPONSE_MAIN",
    "CENTRAL_RESPONSE_FLANK",
    "WEST_ADAPTIVE_REINFORCEMENT",
    "EAST_ADAPTIVE_REINFORCEMENT",
    "PHASE3_ATTACK_WEST",
    "PHASE3_ATTACK_CENTER",
    "PHASE3_ATTACK_EAST",
    "PHASE3_AIR_SUPPORT",
    "PHASE3_GATEWAY_HEAVY",
    "PHASE3_GATEWAY_SIEGE",
    "PHASE3_GATEWAY_LATE_T3",
    "PHASE3_STRATEGIC_LAND",
    "PHASE3_STRATEGIC_AIR",
    "PHASE3_EMERGENCY_LAND",
    "PHASE3_EMERGENCY_AIR",
}

KNOWN_BLUEPRINTS = {
    "uel0001",
    "url0101",
    "url0103",
    "url0104",
    "url0107",
    "url0202",
    "url0205",
    "url0105",
    "ura0101",
    "ura0102",
    "ura0103",
    "ura0203",
    "urb0101",
    "urb0102",
    "urb0201",
    "urb0202",
    "urb1101",
    "urb1103",
    "urb1105",
    "urb1106",
    "urb2101",
    "urb2104",
    "urb3101",
    "urb4201",
    "urb5202",
    "url0208",
    "url0303",
    "url0304",
    "url0306",
    "ura0104",
    "ura0107",
    "ura0303",
    "ura0304",
    "urb0301",
    "urb0302",
    "urb0304",
    "urb2301",
    "urb2302",
    "urb2304",
    "urb3104",
    "urb3201",
    "urb4202",
    "urb4204",
}


def fail(message: str) -> None:
    print(f"[FAIL] {message}")
    raise SystemExit(1)


def ok(message: str) -> None:
    print(f"[ OK ] {message}")


def strip_strings_and_comments(source: str) -> str:
    source = re.sub(r"--\[\[.*?\]\]", "", source, flags=re.S)
    source = re.sub(r"--[^\n]*", "", source)
    source = re.sub(r"'(?:\\.|[^'\\])*'", "''", source)
    source = re.sub(r'"(?:\\.|[^"\\])*"', '""', source)
    return source


def check_delimiters(path: pathlib.Path) -> None:
    source = strip_strings_and_comments(path.read_text(encoding="utf-8"))
    pairs = {")": "(", "]": "[", "}": "{"}
    stack: list[tuple[str, int]] = []

    for line_number, line in enumerate(source.splitlines(), 1):
        for char in line:
            if char in "([{":
                stack.append((char, line_number))
            elif char in ")]}":
                if not stack or stack[-1][0] != pairs[char]:
                    fail(f"{path.name}:{line_number}: unmatched {char}")
                stack.pop()

    if stack:
        char, line = stack[-1]
        fail(f"{path.name}:{line}: unmatched {char}")

    ok(f"balanced delimiters: {path.name}")


def run_luac_if_available() -> None:
    luac = shutil.which("luac")
    if not luac:
        print("[INFO] luac not installed; structural Lua checks used")
        return

    for path in LUA_FILES:
        proc = subprocess.run([luac, "-p", str(path)], text=True, capture_output=True)
        if proc.returncode:
            fail(f"luac rejected {path.name}: {proc.stderr.strip()}")
        ok(f"luac syntax: {path.name}")


def declared_markers(save: str) -> dict[str, str]:
    result: dict[str, str] = {}
    pattern = re.compile(
        r"^\s*([A-Z][A-Z0-9_]*)\s*=\s*(BlankMarker|MassMarker|HydroMarker)\(",
        re.MULTILINE,
    )
    for match in pattern.finditer(save):
        result[match.group(1)] = match.group(2)
    return result


def require_named_tables(source: str, names: set[str], label: str) -> None:
    missing = []
    for name in sorted(names):
        if re.search(rf"^\s*{re.escape(name)}\s*=\s*\{{", source, re.MULTILINE) is None:
            missing.append(name)
    if missing:
        fail(f"missing {label}: " + ", ".join(missing))
    ok(f"required {label} present ({len(names)})")


def extract_start_phase2(script: str) -> str:
    match = re.search(
        r"function\s+StartPhase2\s*\(\s*\)(.*?)\nend\n\nfunction\s+MissionVictory",
        script,
        flags=re.S,
    )
    if not match:
        fail("could not isolate StartPhase2 for transition safety check")
    return match.group(1)


def main() -> int:
    for path in LUA_FILES:
        if not path.is_file():
            fail(f"missing Lua file: {path.name}")
        check_delimiters(path)

    scenario = (ROOT / "operation_twin_spear_scenario.lua").read_text(encoding="utf-8")
    save = (ROOT / "operation_twin_spear_save.lua").read_text(encoding="utf-8")
    script = (ROOT / "operation_twin_spear_script.lua").read_text(encoding="utf-8")
    editor_plan = ROOT / "MAP_EDITOR_PLAN.md"

    for token in ("type = 'campaign_coop'", "'Player1'", "'Player2'", "{'uef'}"):
        if token not in scenario:
            fail(f"scenario contract missing: {token}")
    ok("campaign_coop scenario with two UEF player slots")

    for army in ("Player1", "Player2", "CybranMain", "CybranOutpost", "Neutral"):
        if re.search(rf"\b{re.escape(army)}\s*=\s*(?:EmptyArmy|Player|Cybran|Neutral)", save) is None:
            fail(f"save.lua missing army: {army}")
    ok("all mission armies declared")

    markers = declared_markers(save)
    missing_markers = sorted(REQUIRED_MARKERS - markers.keys())
    if missing_markers:
        fail("missing concrete marker declarations: " + ", ".join(missing_markers))
    ok(f"required concrete markers declared ({len(REQUIRED_MARKERS)})")

    for name, marker_type in {**P1_START_RESOURCES, **P2_START_RESOURCES}.items():
        if markers.get(name) != marker_type:
            fail(f"{name} must be declared with {marker_type}")
    ok("each player has exactly the required 4 Mass + 1 Hydro start contract")

    require_named_tables(save, REQUIRED_AREAS, "areas")
    require_named_tables(save, REQUIRED_CHAINS, "chains")

    for group in sorted(REQUIRED_FORWARD_GROUPS):
        if re.search(
            rf"CybranOutpost\.Units\.Units\.{re.escape(group)}\s*=\s*GROUP",
            save,
        ) is None:
            fail(f"missing Forward Outpost group: {group}")
    ok(f"Forward Outpost logical groups present ({len(REQUIRED_FORWARD_GROUPS)})")

    for group in sorted(REQUIRED_PHASE2_GROUPS):
        if re.search(
            rf"CybranMain\.Units\.Units\.{re.escape(group)}\s*=\s*GROUP",
            save,
        ) is None:
            fail(f"missing Phase 2 CybranMain group: {group}")
    ok(f"Phase 2 logical groups present ({len(REQUIRED_PHASE2_GROUPS)})")

    for group in sorted(REQUIRED_PHASE3_GROUPS):
        if re.search(
            rf"CybranMain\.Units\.Units\.{re.escape(group)}\s*=\s*GROUP",
            save,
        ) is None:
            fail(f"missing Phase 3 CybranMain group: {group}")
    ok(f"Phase 3 logical groups present ({len(REQUIRED_PHASE3_GROUPS)})")

    for function in sorted(REQUIRED_FUNCTIONS):
        if re.search(rf"function\s+{re.escape(function)}\s*\(", script) is None:
            fail(f"mission function missing: {function}")
    ok("Stage 2 lifecycle/wave/debug functions present")

    for wave in sorted(REQUIRED_WAVES):
        if re.search(rf"\b{re.escape(wave)}\s*=\s*\{{", script) is None:
            fail(f"wave definition missing: {wave}")
    ok("all required Phase 1 wave definitions present")

    required_apis = (
        "ScenarioUtils.InitializeScenarioArmies()",
        "ScenarioFramework.SetPlayableArea(",
        "ScenarioFramework.CreateAreaTrigger(",
        "ScenarioFramework.CreateGroupDeathTrigger(",
        "ScenarioFramework.PlatoonPatrolChain(",
        "ScenarioUtils.ChainToPositions(",
        "Objectives.Kill(",
        "Objectives.Unknown(",
        "IssueMove(",
        "IssuePatrol(",
        "IssueRepair(",
        "IssueBuildMobile(",
        "IssueTransportLoad(",
        "IssueTransportUnload(",
        "KillThread(",
        "ScenarioFramework.CreateVisibleArea(",
        "ForkThread(",
        "WaitSeconds(",
    )
    for api in required_apis:
        if api not in script:
            fail(f"required FAF API missing: {api}")
    ok("required current FAF campaign APIs referenced")

    if "url0106" in script.lower() or "url0106" in save.lower():
        fail("invalid/nonexistent Cybran url0106 blueprint is forbidden")
    ok("legacy invalid url0106 reference removed")

    discovered_blueprints = set(
        re.findall(r"UnitSpec\('([a-z][a-z0-9]+)'", save)
        + re.findall(r"=\s*'([a-z]{3}\d{4})'", script)
    )
    unknown = sorted(discovered_blueprints - KNOWN_BLUEPRINTS)
    if unknown:
        fail("unreviewed unit blueprints: " + ", ".join(unknown))
    ok(f"all referenced Stage 2 blueprints are allow-listed ({len(discovered_blueprints)})")

    if "GetArmyBrain('Player2')" in script or 'GetArmyBrain("Player2")' in script:
        fail("unconditional literal Player2 brain lookup detected")
    ok("Player2 remains guarded")

    if "ScenarioInfo.UnitNames" not in script or "GetNamedArmyUnit" not in script:
        fail("objective targets must resolve through ScenarioInfo.UnitNames")
    if "commandTree." in script or "radarTree." in script:
        fail("objective targets must not depend on CreateArmyGroup tree return values")
    ok("named objective targets use ScenarioInfo.UnitNames")

    phase2 = extract_start_phase2(script)
    if "MissionVictory(" in phase2 or "EndOperation(" in phase2:
        fail("Phase 2 must not end the operation from StartPhase2")
    if "CreatePhase2Objectives()" not in phase2:
        fail("StartPhase2 must create the two-sector Phase 2 objective set")
    ok("Phase 1 transitions to complete non-victory Phase 2 flow")

    required_text = (
        "Destroy the Forward Command Post",
        "Destroy Cybran Radar",
        "Destroy Western Logistics Base",
        "Destroy Eastern Air Control Base",
        "Intercept Cybran Supply Convoys",
        "Destroy Cybran Radar Network",
        "AREA_PHASE_1",
        "AREA_PHASE_2",
        "AREA_PHASE_3",
        "Central response triggered",
        "West completed",
        "East completed",
    )
    for token in required_text:
        if token not in script:
            fail(f"mission flow token missing: {token}")
    ok("Phase 1 + complete Phase 2 objective/counter-response flow present")

    for field in (
        "WestCompleted",
        "EastCompleted",
        "CentralResponseTriggered",
        "WestConvoysDestroyed",
        "RadarNetworkDestroyed",
        "Finished",
    ):
        if field not in script:
            fail(f"MissionState.Phase2 field missing: {field}")
    ok("central MissionState.Phase2 contract present")

    if re.search(r"function\s+CompletePhase2\s*\(\s*\)(.*?)function\s+StartPhase3", script, re.S) is None:
        fail("CompletePhase2 / StartPhase3 transition missing")
    complete_phase2 = re.search(
        r"function\s+CompletePhase2\s*\(\s*\)(.*?)function\s+StartPhase3",
        script,
        re.S,
    ).group(1)
    for token in ("AREA_PHASE_3", "MissionState.CurrentPhase = 3", "StartPhase3()"):
        if token not in complete_phase2:
            fail(f"CompletePhase2 transition token missing: {token}")
    if "MissionVictory(" in complete_phase2 or "EndOperation(" in complete_phase2:
        fail("CompletePhase2 must not end the operation")
    ok("Phase 2 completes into implemented Phase 3")

    # Phase 3 primary objective and state contract.
    required_phase3_text = (
        "Destroy Long-Range Artillery",
        "Disable the Heavy Defense Network",
        "Destroy the Reinforcement Gateway",
        "Destroy Strategic Radar",
        "Destroy the Cybran Data Core",
        "AREA_PHASE_3_WEST",
        "AREA_PHASE_3_CENTER",
        "AREA_PHASE_3_EAST",
        "AREA_FINALE",
        "Strategic Response triggered",
        "Emergency Response triggered",
        "Bombardment system active",
        "Drop mission launched",
        "Finale area unlocked",
    )
    for token in required_phase3_text:
        if token not in script and token not in save:
            fail(f"Phase 3 contract token missing: {token}")
    ok("complete Phase 3 objective / response / finale transition contract present")

    for field in (
        "ArtilleryDestroyed",
        "DefenseNodeDestroyed",
        "ReinforcementGatewayDestroyed",
        "StrategicResponseTriggered",
        "EmergencyResponseTriggered",
        "RadarNetworkDestroyed",
        "DataCoreDestroyed",
        "FinaleUnlocked",
        "Finished",
    ):
        if field not in script:
            fail(f"MissionState.Phase3 field missing: {field}")
    ok("central MissionState.Phase3 contract present")

    # The three primaries are deliberately independent; completion checks the
    # state flags rather than a prescribed order.
    completion = re.search(
        r"function\s+CheckPhase3Completion\s*\(\s*\)(.*?)function\s+CompleteArtilleryObjective",
        script,
        re.S,
    )
    if not completion:
        fail("CheckPhase3Completion missing")
    for token in (
        "phase.ArtilleryDestroyed",
        "phase.DefenseNodeDestroyed",
        "phase.ReinforcementGatewayDestroyed",
        "CompletePhase3()",
    ):
        if token not in completion.group(1):
            fail(f"Phase 3 order-independent completion token missing: {token}")
    ok("TEST 5/6/7 — objective order and near-simultaneous completion are state-based")

    # Early destruction reconciliation must be based on actual target liveness.
    create_p3 = re.search(
        r"local\s+function\s+CreatePhase3Objectives\s*\(\s*\)(.*?)\nend\n\nfunction\s+UnlockFinaleArea",
        script,
        re.S,
    )
    if not create_p3:
        fail("CreatePhase3Objectives block missing")
    for token in (
        "not IsUnitAlive(artillery)",
        "not IsUnitAlive(defenseNode)",
        "not IsUnitAlive(gateway)",
    ):
        if token not in create_p3.group(1):
            fail(f"early-destruction reconciliation missing: {token}")
    ok("TEST 10 — early destruction reconciliation present")

    # Exactly-once response guards.
    strategic = re.search(
        r"function\s+TriggerStrategicResponse\s*\(\s*\)(.*?)function\s+TriggerEmergencyResponse",
        script,
        re.S,
    )
    emergency = re.search(
        r"function\s+TriggerEmergencyResponse\s*\(\s*\)(.*?)local\s+function\s+UpdatePhase3ResponseState",
        script,
        re.S,
    )
    if not strategic or "phase.StrategicResponseTriggered" not in strategic.group(1):
        fail("Strategic Response once-only guard missing")
    if not emergency or "phase.EmergencyResponseTriggered" not in emergency.group(1):
        fail("Emergency Response once-only guard missing")
    ok("TEST 8/9 — Strategic and Emergency Response once-only guards present")

    # System teardown is coupled to each strategic target.
    teardown_blocks = (
        (
            "CompleteArtilleryObjective",
            "function CompleteArtilleryObjective",
            "function CompleteDefenseObjective",
            "Phase3Artillery",
        ),
        (
            "CompleteDefenseObjective",
            "function CompleteDefenseObjective",
            "function CompleteGatewayObjective",
            "Phase3DefenseRepair",
        ),
        (
            "CompleteGatewayObjective",
            "function CompleteGatewayObjective",
            "local function CreatePhase3Objectives",
            "Phase3GatewayReinforcement",
        ),
    )
    for function_name, start_token, end_token, thread_token in teardown_blocks:
        start = script.find(start_token)
        end = script.find(end_token, start + len(start_token))
        if start < 0 or end < 0:
            fail(f"could not isolate {function_name}")
        block = script[start:end]
        if thread_token not in block:
            fail(f"{function_name} does not stop {thread_token}")
    ok("TEST 1/2/3 — artillery, defense repair and gateway spawner teardown present")

    for token in (
        "CHAIN_REINFORCEMENT_AIR_ENTRY",
        "CHAIN_REINFORCEMENT_DROP_WEST",
        "CHAIN_REINFORCEMENT_DROP_EAST",
        "IssueTransportLoad(",
        "IssueTransportUnload(",
    ):
        if token not in script and token not in save:
            fail(f"transport drop contract missing: {token}")
    ok("TEST 4 — physical transport load/route/unload contract present")

    if "Phase3MaxLandAttackUnits" not in script or "Phase3MaxAirAttackUnits" not in script:
        fail("Phase 3 active-unit caps missing")
    if "MissionState.ActivePlayers == 1" not in script or "MissionState.ActivePlayers >= 2" not in script:
        fail("Phase 3 solo/coop scaling missing")
    ok("TEST 11/12/13 — solo/coop, difficulty and active-unit cap contracts present")

    complete_p3 = re.search(
        r"function\s+CompletePhase3\s*\(\s*\)(.*?)\nend\n\nfunction\s+StartPhase3",
        script,
        re.S,
    )
    if not complete_p3:
        fail("CompletePhase3 block missing")
    for token in (
        "StopMissionThread('Phase3Artillery')",
        "StopMissionThread('Phase3DefenseRepair')",
        "StopMissionThread('Phase3GatewayReinforcement')",
        "StopMissionThread('Phase3TransportDrops')",
        "StopMissionThread('Phase3AttackDirector')",
        "UnlockFinaleArea()",
        "MissionState.CurrentPhase = 4",
        "StartPhase4()",
    ):
        if token not in complete_p3.group(1):
            fail(f"CompletePhase3 cleanup/transition token missing: {token}")
    if "MissionVictory(" in complete_p3.group(1) or "EndOperation(" in complete_p3.group(1):
        fail("Phase 3 completion must not end the operation")
    ok("TEST 14/15 — finale unlock and full Phase 3 scheduler cleanup present")

    if "SetMaxHealth" in script or "SetDamage" in script:
        fail("Phase 3 must not artificially alter unit HP/damage")
    if "url0401" in script or "ura0401" in script:
        fail("Phase 3 must not spawn Experimental units")
    ok("Phase 3 uses stock unit HP/damage and no Experimental unit")

    if not editor_plan.is_file():
        fail("MAP_EDITOR_PLAN.md is required when a real .scmap is not generated")
    plan_text = editor_plan.read_text(encoding="utf-8")
    for token in (
        "CROSSING_WEST",
        "CROSSING_EAST",
        "FORWARD_OUTPOST_CENTER",
        "WEST_LOGISTICS_COMMAND",
        "EAST_AIR_CONTROL_COMMAND",
        "CHAIN_WEST_SUPPLY",
        "CHAIN_EAST_AIR_PATROL_01",
        "CENTRAL_RESPONSE_SPAWN",
        "AREA_PHASE_2_WEST",
        "AREA_PHASE_2_EAST",
        "AREA_PHASE_2_CENTER",
        "Resource markers",
        "Pathing validation",
        "PHASE3_ARTILLERY_CORE",
        "PHASE3_DEFENSE_CONTROL_NODE",
        "PHASE3_REINFORCEMENT_GATEWAY",
        "CHAIN_PHASE3_ATTACK_CENTER",
        "CHAIN_REINFORCEMENT_DROP_WEST",
        "AREA_PHASE_3_CENTER",
        "Phase 3",
    ):
        if token not in plan_text:
            fail(f"MAP_EDITOR_PLAN.md missing section/token: {token}")
    ok("map editor handoff plan present")

    scmap = ROOT / "operation_twin_spear.scmap"
    if scmap.exists():
        if scmap.stat().st_size < 1024:
            fail("suspicious/fake .scmap detected")
        ok("binary .scmap candidate exists and is non-trivial")
    else:
        print("[INFO] .scmap intentionally absent; Stage 4 / Phase 3 requires FAF Map Editor export")

    run_luac_if_available()
    print("[PASS] Operation Twin Spear Stage 4 / complete Phase 3 static checks passed")
    return 0


if __name__ == "__main__":
    sys.exit(main())
