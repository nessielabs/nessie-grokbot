#!/usr/bin/env bash
#
# Validate the skill version lockstep documented in CONTRIBUTING.md: the
# SKILL.md frontmatter version and the skill-version.json pointer must match,
# and the pointer must reference the published SKILL.md. The skill is maintained
# directly in this repository, and this check keeps its release metadata honest.
#
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

python3 - "$REPO_ROOT" <<'PY'
import json
import pathlib
import re
import sys

root = pathlib.Path(sys.argv[1])

mcp = json.loads((root / "mcp.json").read_text(encoding="utf-8"))
mcp_url = mcp.get("mcpServers", {}).get("nessie", {}).get("url")
expected_mcp_url = "https://mcp.nessielabs.com/mcp?client=grokbot"
if mcp_url != expected_mcp_url:
    raise SystemExit(
        f"mcp.json Nessie URL must be {expected_mcp_url}, got {mcp_url!r}"
    )

skill = (root / "skills/nessie/SKILL.md").read_text(encoding="utf-8")
skill_version = re.search(r"^version:\s*(\S+)\s*$", skill, re.MULTILINE)
if not skill_version:
    raise SystemExit("skills/nessie/SKILL.md must declare version frontmatter")
if "## Skill Updates" not in skill:
    raise SystemExit("skills/nessie/SKILL.md must keep the Skill Updates section")

pointer_path = root / "skill-version.json"
if not pointer_path.is_file():
    raise SystemExit("skill-version.json update pointer is required")
pointer = json.loads(pointer_path.read_text(encoding="utf-8"))
if pointer.get("version") != skill_version.group(1):
    raise SystemExit(
        f"version mismatch: skills/nessie/SKILL.md frontmatter is {skill_version.group(1)} "
        f"but skill-version.json is {pointer.get('version')}; bump both in the same commit"
    )
if pointer.get("skillUrl") != "https://raw.githubusercontent.com/nessielabs/nessie-grokbot/main/skills/nessie/SKILL.md":
    raise SystemExit("skill-version.json skillUrl must point at the published SKILL.md")
PY

echo "Nessie Grok Bot skill validation passed."
