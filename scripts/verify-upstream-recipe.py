#!/usr/bin/env python3
"""Fail when the OpenTelemetry Java 21 plan drifts from pinned upstream CI."""

from __future__ import annotations

import sys
import tomllib
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
EXPECTED = [
    "bash", "-euo", "pipefail", "-c",
    'exec ./gradlew build -PtestJavaVersion=21 "-Porg.gradle.java.installations.paths=${TEST_JAVA_HOME:?}" "-Porg.gradle.java.installations.auto-download=false"',
]


def require(condition: bool, message: str) -> None:
    if not condition:
        raise RuntimeError(message)


def main() -> int:
    try:
        plan = tomllib.loads((ROOT / ".boringcache.toml").read_text())
        require(plan["adapters"]["gradle"]["command"] == EXPECTED, "Gradle plan changed")
        upstream = (ROOT / "upstream/.github/workflows/build.yml").read_text()
        for fragment in ("test-java-version:", "distribution: zulu", "distribution: temurin", "java-version: 21", "./gradlew build", "-PtestJavaVersion=${{ matrix.test-java-version }}", '"-Porg.gradle.java.installations.paths=${TEST_JAVA_PATH}"', "TEST_JAVA_PATH: ${{ steps.setup-java-test.outputs.path }}", "-Porg.gradle.java.installations.auto-download=false"):
            require(fragment in upstream, f"upstream Gradle job changed: {fragment}")
        action = (ROOT / ".github/actions/opentelemetry-gradle-benchmark/action.yml").read_text()
        require("run-benchmark-plan.py gradle --working-directory upstream" in action, "workflow bypasses the plan")
        require("TEST_JAVA_HOME: ${{ steps.setup_java_test.outputs.path }}" in action, "test JDK path is not projected")
    except (KeyError, OSError, RuntimeError, tomllib.TOMLDecodeError) as error:
        print(f"OpenTelemetry Java recipe mismatch: {error}", file=sys.stderr)
        return 1
    print("Verified OpenTelemetry Java 21 Gradle plan against pinned upstream CI.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
