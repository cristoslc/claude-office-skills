---
title: "Update Documentation for Zero-Install"
artifact: SPEC-005
track: implementable
status: Active
author: operator
created: 2026-03-30
last-updated: 2026-03-30
priority-weight: medium
type: enhancement
parent-epic: EPIC-001
parent-initiative: ""
linked-artifacts: []
depends-on-artifacts:
  - SPEC-004
  - SPEC-006
addresses: []
evidence-pool: ""
source-issue: ""
swain-do: required
---

# Update Documentation for Zero-Install

## Problem Statement

After SPEC-001 through SPEC-004, all invocation patterns have changed. Documentation (AGENTS.md, all SKILL.md files, README) still references `venv/bin/python`, `npm install`, `pdftoppm`, `pandoc`, and raw script paths. Everything must be updated to reference the `bin/` wrapper scripts and the new prerequisite list.

## Desired Outcomes

A user reading any SKILL.md file sees simple `bin/<command>` invocations. The prerequisites section lists only `uv`, `deno`, and `LibreOffice`, and points to the install skill (`public/office-install/SKILL.md`) for setup. No mention of venv, pip, npm, pdftoppm, or pandoc remains.

## External Behavior

**AGENTS.md changes:**
- Prerequisites: uv, deno, LibreOffice (+ one-time Chromium setup)
- All command examples use `public/<skill>/bin/<command>` paths
- Remove venv setup section, npm install section, requirements.txt references
- Remove pdftoppm and pandoc from system tools section

**SKILL.md changes (per skill):**
- All invocation examples use wrapper scripts
- Setup sections simplified to "Prerequisites: uv, deno, LibreOffice"
- Remove references to `venv/bin/python`, `node`, `npm`

**README changes:**
- Updated setup instructions
- Updated example commands

## Acceptance Criteria

1. **Given** AGENTS.md, **when** searched for `venv`, `pip`, `npm install`, `pdftoppm`, `pandoc`, **then** zero matches are found.

2. **Given** any SKILL.md file, **when** searched for `venv/bin/python` or `node `, **then** zero matches are found.

3. **Given** the prerequisites section of AGENTS.md, **when** read, **then** it lists exactly: uv, deno, LibreOffice, and one-time Chromium setup.

4. **Given** a new user following the documentation, **when** they install the three prerequisites and clone the repo, **then** they can run every example command successfully.

## Verification

| Criterion | Evidence | Result |
|-----------|----------|--------|

## Scope & Constraints

**In scope:**
- AGENTS.md (full rewrite of setup and commands sections)
- `public/office-pptx/SKILL.md`
- `public/office-pptx/html2pptx.md`
- `public/office-pptx/ooxml.md`
- `public/office-docx/SKILL.md`
- `public/office-docx/ooxml.md`
- `public/office-docx/docx-js.md`
- `public/office-pdf/SKILL.md`
- `public/office-pdf/REFERENCE.md`
- `public/office-pdf/FORMS.md`
- `public/office-xlsx/SKILL.md`
- `README.md`

**Out of scope:**
- Script behavior changes (already done in SPEC-001 through SPEC-004)

## Implementation Approach

1. Update AGENTS.md prerequisites and command reference sections.
2. Update each SKILL.md file to use `bin/` wrapper invocations.
3. Update README.md setup instructions.
4. Grep for stale references (`venv`, `pip`, `npm install`, `pdftoppm`, `pandoc`) and fix any remaining.

## Lifecycle

| Phase | Date | Commit | Notes |
|-------|------|--------|-------|
| Active | 2026-03-30 | — | Initial creation |
