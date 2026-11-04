#!/usr/bin/env python3
"""Confere o resultado funcional, evitando aprovar apenas um build sem cenários."""
import argparse
import json
import os
from pathlib import Path


def verify_report(path: Path, expected_scenarios: int, expected_steps: int) -> str:
    features = json.loads(path.read_text(encoding="utf-8"))
    scenarios = [scenario for feature in features for scenario in feature.get("elements", [])
                 if scenario.get("type") == "scenario"]
    steps = [step for scenario in scenarios for step in scenario.get("steps", [])]
    problems = []
    if len(scenarios) != expected_scenarios or len(steps) != expected_steps:
        problems.append(f"Esperados {expected_scenarios} cenários e {expected_steps} passos; "
                        f"encontrados {len(scenarios)} e {len(steps)}")
    for scenario in scenarios:
        checks = scenario.get("steps", []) + scenario.get("before", []) + scenario.get("after", [])
        if not scenario.get("steps") or any(check.get("result", {}).get("status") != "passed"
                                           for check in checks):
            problems.append(f"Cenário não aprovado: {scenario.get('name', '(sem nome)')}")
    if problems:
        raise ValueError("\n".join(problems))
    return ("## Resultado BDD com Oracle\n\n"
            f"- Cenários aprovados: **{len(scenarios)}**\n"
            f"- Passos aprovados: **{len(steps)}**\n"
            "- Nenhum cenário com falha, pendente ou ignorado.\n"
            "- Relatórios e logs disponíveis nos artifacts da execução.\n")


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("report", type=Path)
    parser.add_argument("--expected-scenarios", type=int, default=34)
    parser.add_argument("--expected-steps", type=int, default=188)
    args = parser.parse_args()
    try:
        summary = verify_report(args.report, args.expected_scenarios, args.expected_steps)
    except (OSError, ValueError, TypeError, KeyError) as error:
        print(f"Relatório não aprovado: {error}")
        return 1
    print(summary)
    if summary_file := os.environ.get("GITHUB_STEP_SUMMARY"):
        with Path(summary_file).open("a", encoding="utf-8") as output:
            output.write(summary)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
