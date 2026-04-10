---
title: "Agent-Facing Install Skill"
artifact: SPEC-006
track: implementable
status: Active
author: operator
created: 2026-04-09
last-updated: 2026-04-09
priority-weight: high
type: enhancement
parent-epic: EPIC-001
parent-initiative: ""
linked-artifacts:
  - SPIKE-001
depends-on-artifacts:
  - SPEC-001
  - SPEC-003
addresses: []
evidence-pool: ""
source-issue: ""
swain-do: required
---

# Agent-Facing Install Skill

## Problem Statement

The zero-install goal (EPIC-001) eliminates library installation steps, but `uv`, `deno`, and `LibreOffice` still need to be present on the machine. A traditional setup script (bash or PowerShell) cannot anticipate every environment — corporate lockdowns, proxy configurations, endpoint protection policies, and mixed package manager availability create too many branches for a static script to handle well. An LLM agent, however, can detect the environment, adapt its approach, and ask the user when it hits a wall.

## Desired Outcomes

An agent consuming the office-skills repository can bootstrap a new environment by following a progressive, phase-gated workflow in `public/office-install/SKILL.md`. The skill detects the platform and available package managers, installs only what's missing using the least-privileged method available, and verifies each tool before moving on. On corporate Windows where elevation is unavailable, the skill guides the agent to download standalone zip binaries into a local `tools/` directory — no installers, no registry writes, no elevation.

## External Behavior

**Inputs:** The agent's environment (detected, not declared).

**Outputs:** Working `uv`, `deno` (if needed), Playwright Chromium (if needed), and LibreOffice (if needed) — either on PATH or in `<repo-root>/tools/`.

**Trigger conditions** — the skill runs only when:
- A script fails because a tool is missing
- The user explicitly asks to set up the environment
- The agent is operating in a new environment for the first time

**Progressive phases:**
1. **Phase 0 — Detect**: Platform, elevation availability, package managers
2. **Phase 1 — uv**: Check → install (platform-adaptive) → verify
3. **Phase 2 — deno**: Check → install → verify (skip if html2pptx not needed)
4. **Phase 3 — Playwright Chromium**: Check → install → verify (skip if html2pptx not needed)
5. **Phase 4 — LibreOffice**: Check → install/guide → verify (skip if not needed)
6. **Phase 5 — Verify full stack**: End-to-end check of available capabilities

Each phase gates the next. Phases are skipped when their checks already pass.

**Corporate Windows path:** When the agent detects Windows with no elevation, each phase uses the "download zip, extract to `tools/`" method. Wrapper scripts (SPEC-004) discover these portable binaries via the `tools/` directory convention.

## Acceptance Criteria

1. **Given** a macOS machine with Homebrew, **when** the install skill is followed, **then** all tools are installed via `brew` with no manual downloads.

2. **Given** a corporate Windows machine with no elevation and no `uv`/`deno`, **when** the install skill is followed, **then** portable binaries are placed in `tools/` and verified working.

3. **Given** a machine where `uv` is already installed, **when** the install skill runs Phase 1, **then** it detects the existing install, skips it, and moves to Phase 2.

4. **Given** a downloaded binary blocked by endpoint protection, **when** the agent attempts to run it, **then** the skill instructs the agent to stop and inform the user rather than attempting workarounds.

5. **Given** a machine where only PDF/DOCX/XLSX skills are needed (no html2pptx), **when** the install skill runs, **then** Phases 2 and 3 (deno, Playwright) are skipped entirely.

6. **Given** tools installed in `tools/`, **when** wrapper scripts (SPEC-004) are invoked, **then** they discover and use the portable binaries without PATH modifications.

## Verification

| Criterion | Evidence | Result |
|-----------|----------|--------|

## Scope & Constraints

**In scope:**
- `public/office-install/SKILL.md` — the agent-facing workflow document
- Portable binary download instructions for Windows (uv, deno)
- LibreOffice Portable guidance for Windows
- Tool discovery convention (env var → `tools/` → PATH) documented for SPEC-004 integration
- Troubleshooting guidance (SmartScreen, proxy, PowerShell execution policy)

**Out of scope:**
- Automated setup scripts (the agent IS the automation)
- Modifying system PATH or environment variables permanently
- Bypassing security controls — the skill stops and informs the user
- Wrapper script implementation (SPEC-004)

## Implementation Approach

1. Write `public/office-install/SKILL.md` with progressive phase-gated workflow.
2. Document platform detection commands for Phase 0.
3. For each tool (uv, deno, LibreOffice), document install paths for: macOS (brew), Linux (curl/apt), Windows with elevation (winget), Windows without elevation (zip extract to `tools/`).
4. Include verification commands after each phase.
5. Document troubleshooting for common corporate environment issues.
6. Add `tools/` to `.gitignore`.

## Lifecycle

| Phase | Date | Commit | Notes |
|-------|------|--------|-------|
| Active | 2026-04-09 | — | Initial creation; SKILL.md draft complete |
