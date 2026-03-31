---
title: "PPTX: Add Visual Verification to Edit and Template Workflows"
artifact: SPEC-007
track: implementable
status: Active
author: operator
created: 2026-03-30
last-updated: 2026-03-30
priority-weight: medium
type: enhancement
parent-epic: EPIC-002
parent-initiative: ""
linked-artifacts:
  - ADR-003
  - SPEC-006
depends-on-artifacts: []
addresses: []
evidence-pool: ""
source-issue: ""
swain-do: required
---

# PPTX: Add Visual Verification to Edit and Template Workflows

## Problem Statement

PPTX SKILL.md has full ADR-003 compliance for the "create from scratch" workflow but two gaps:

1. **Edit existing (OOXML) workflow** — after unpacking, editing XML, validating, and repacking, there is no step to render the output and visually inspect it. The agent only runs structural validation (`validate.py`).

2. **Create from template workflow** — the template is analyzed visually (thumbnail grid of the template), but after text replacement the final output is never rendered or inspected. The agent doesn't see what the filled-in presentation looks like.

## Acceptance Criteria

1. **Given** the OOXML editing workflow in `pptx/SKILL.md`, **when** the pack step completes, **then** the workflow includes: create thumbnail grid of output → read grid → check for visual issues → iterate if needed.

2. **Given** the template-based creation workflow, **when** `replace.py` produces the final PPTX, **then** the workflow includes: create thumbnail grid of output → read grid → check for text truncation, overflow, misalignment → iterate by adjusting replacements if needed.

3. **Given** both updated workflows, **when** an agent follows SKILL.md, **then** it cannot declare the task complete without having read at least one rendered image of the output.

## Scope & Constraints

- Only modifies workflow instructions in `public/pptx/SKILL.md`
- Does not change any scripts
- The thumbnail tool already exists — this is about integrating it into workflows that currently skip it

## Implementation Approach

1. In the OOXML editing workflow (after `pack.py`), add: "Create thumbnail grid of output. Read the grid and check for visual issues (text cutoff, broken layouts, missing content). Fix and repack if needed."
2. In the template workflow (after `replace.py`), add: "Create thumbnail grid of the final presentation. Read the grid and verify all replaced text fits correctly, no placeholders remain visible, and layouts are intact. If issues found, adjust replacement JSON and re-run."

## Lifecycle

| Phase | Date | Commit | Notes |
|-------|------|--------|-------|
| Active | 2026-03-30 | — | Initial creation |
