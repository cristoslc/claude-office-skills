---
title: "Zero-Install Office Skills"
artifact: EPIC-001
track: container
status: Active
author: operator
created: 2026-03-30
last-updated: 2026-03-30
parent-vision: VISION-001
parent-initiative: ""
priority-weight: high
success-criteria:
  - "All Python scripts run via `uv run` with no prior venv or pip install"
  - "All Node.js scripts run via `deno run` with no prior npm install"
  - "System tool prerequisites reduced to: uv, deno, LibreOffice"
  - "Each skill has a bin/ directory with wrapper scripts that agents call instead of raw commands"
  - "SKILL.md files reference wrapper scripts, not raw tool invocations"
  - "Full toolchain is installable without elevation on corporate Windows via portable binaries"
  - "An agent-facing install skill provides progressive, environment-adaptive setup guidance"
depends-on-artifacts:
  - SPIKE-001
addresses: []
evidence-pool: ""
---

# Zero-Install Office Skills

## Goal / Objective

Eliminate all library installation steps (venv, pip, npm install) from this repository. Users clone the repo and run scripts immediately with only three system prerequisites: `uv`, `deno`, and `LibreOffice`. Every skill exposes a `bin/` directory of wrapper scripts that serve as a stable interface for agents — agents call simple commands instead of constructing complex `uv run --with` or `deno run --allow-all` invocations. The entire toolchain must be installable without elevation on corporate Windows — portable binaries in a local `tools/` directory, discovered automatically by wrapper scripts. An agent-facing install skill (`public/office-install/SKILL.md`) provides progressive, environment-adaptive setup guidance so agents can bootstrap any environment without a shell script trying to anticipate every case.

## Desired Outcomes

Claude agents (and human users) consuming these skills can work with Office documents immediately after cloning. No setup ceremony, no "install dependencies first" preamble. The wrapper scripts in each `<skill>/bin/` directory become the canonical API: SKILL.md says "run `bin/thumbnail input.pptx output/`" instead of "run `venv/bin/python public/office-pptx/scripts/thumbnail.py input.pptx output/`". This makes skills portable, self-contained, and agent-friendly.

## Scope Boundaries

**In scope:**
- PEP 723 inline metadata for all Python scripts (SPEC-001)
- Replace pdftoppm/pandoc with Python-bundled alternatives (SPEC-002)
- Migrate html2pptx.js to Deno runtime (SPEC-003)
- Wrapper scripts in each `<skill>/bin/` directory (SPEC-004)
- Documentation updates across all SKILL.md files and AGENTS.md (SPEC-005)
- Agent-facing install skill with portable binary support (SPEC-006)

**Out of scope:**
- Replacing LibreOffice (no Python alternative exists; Portable edition covers no-elevation installs)
- Changing script behavior — this is packaging/invocation only
- Publishing scripts to PyPI or npm

## Child Specs

| Spec | Title | Status | Depends on |
|------|-------|--------|------------|
| SPEC-001 | Zero-Install Python Scripts via PEP 723 | Active | — |
| SPEC-002 | Replace System Tools with Python Packages | Active | SPEC-001 |
| SPEC-003 | Migrate html2pptx to Deno | Active | — |
| SPEC-004 | Wrapper Scripts (Skill Bin API) | Active | SPEC-001, SPEC-002, SPEC-003 |
| SPEC-005 | Update Documentation | Active | SPEC-004, SPEC-006 |
| SPEC-006 | Agent-Facing Install Skill | Active | SPEC-001, SPEC-003 |

## Key Dependencies

- SPIKE-001 (Complete) — established Deno as the Node.js runtime choice
- LibreOffice remains the sole system tool that cannot be replaced (LibreOffice Portable covers no-elevation Windows)
- Portable binary distribution (zip download + extract to `tools/`) avoids elevation for uv and deno on corporate Windows

## Lifecycle

| Phase | Date | Commit | Notes |
|-------|------|--------|-------|
| Active | 2026-03-30 | — | Initial creation |
