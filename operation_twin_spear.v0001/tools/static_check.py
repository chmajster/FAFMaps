#!/usr/bin/env python3
"""Stage 1 static checks for Operation Twin Spear.

This deliberately avoids pretending to validate the binary .scmap. If `luac` is
available it is used for syntax parsing; otherwise deterministic structural
checks still validate the mission contract and Lua delimiter balance.
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
    "ENEMY_OUTPOST_BASE",
    "ENEMY_MAIN_BASE",
    "OBJECTIVE_OUTPOST",
    "OBJECTIVE_FINAL_TEST",
    "EXPANSION_1_CENTER",
    "ATTACK_PATH_WEST_01",
    "ATTACK_PATH_WEST_02",
    "ATTACK_PATH_WEST_03",
    "ATTACK_PATH_EAST_01",
    "ATTACK_PATH_EAST_02",
    "ATTACK_PATH_EAST_03",
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
    "MissionVictory",
    "MissionFailure",
    "GetActivePlayerCount",
    "GetScaledUnitCount",
    "GetScaledDelay",
    "GetScaledResourceMultiplier",
}


def fail(message: str) -> None:
    print(f"[FAIL] {message}")
    raise SystemExit(1)


def ok(message: str) -> None:
    print(f"[ OK ] {message}")


def strip_strings_and_comments(source: str) -> str:
    source = re.sub(r"--\\[\\[.*?\\]\\]", "", source, flags=re.S)
    source = re.sub(r"--[^\\n]*", "", source)
    source = re.sub(r"'(?:\\\\.|[^'\\\\])*'", "''", source)
    source = re.sub(r'"(?:\\\\.|[^"\\\\])*"', '""', source)
    return source


def check_delimiters(path: pathlib.Path) -> None:
    source = strip_strings_and_comments(path.read_text(encoding="utf-8"))
    pairs = {')': '(', ']': '[', '}': '{'}
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


def main() -> int:
    for path in LUA_FILES:
        if not path.is_file():
            fail(f"missing Lua file: {path.name}")
        check_delimiters(path)

    scenario = (ROOT / "operation_twin_spear_scenario.lua").read_text(encoding="utf-8")
    save = (ROOT / "operation_twin_spear_save.lua").read_text(encoding="utf-8")
    script = (ROOT / "operation_twin_spear_script.lua").read_text(encoding="utf-8")

    for token in ("type = 'campaign_coop'", "'Player1'", "'Player2'", "{'uef'}"):
        if token not in scenario:
            fail(f"scenario contract missing: {token}")
    ok("campaign_coop scenario with two UEF player slots")

    for army in ("Player1", "Player2", "CybranMain", "CybranOutpost", "Neutral"):
        if re.search(rf"\\b{re.escape(army)}\\s*=\\s*EmptyArmy", save) is None:
            fail(f"save.lua missing army: {army}")
    ok("all Stage 1 armies declared")

    missing_markers = sorted(marker for marker in REQUIRED_MARKERS if marker not in save)
    if missing_markers:
        fail("missing markers: " + ", ".join(missing_markers))
    ok(f"required marker set present ({len(REQUIRED_MARKERS)})")

    for function in REQUIRED_FUNCTIONS:
        if re.search(rf"function\\s+{re.escape(function)}\\s*\\(", script) is None:
            fail(f"mission function missing: {function}")
    ok("mission lifecycle/scaling functions present")

    required_apis = (
        "ScenarioUtils.InitializeScenarioArmies()",
        "Objectives.Kill(",
        "ScenarioFramework.CreateUnitDeathTrigger",
        "ScenarioFramework.EndOperation(",
        "ForkThread(",
        "WaitSeconds(",
    )
    for api in required_apis:
        if api not in script:
            fail(f"required FAF API missing: {api}")
    ok("required current FAF APIs referenced")

    if "GetArmyBrain('Player2')" in script or 'GetArmyBrain("Player2")' in script:
        fail("unconditional literal Player2 brain lookup detected")
    ok("no unconditional literal Player2 brain lookup")

    if (ROOT / "operation_twin_spear.scmap").exists():
        size = (ROOT / "operation_twin_spear.scmap").stat().st_size
        if size < 1024:
            fail("suspicious/fake .scmap detected")
        ok("binary .scmap candidate exists and is non-trivial")
    else:
        print("[INFO] .scmap intentionally absent; must be created with FAF Map Editor")

    run_luac_if_available()
    print("[PASS] Operation Twin Spear Stage 1 static checks passed")
    return 0


if __name__ == "__main__":
    sys.exit(main())
