---
title: "Zero-Install Python Scripts via PEP 723 Inline Metadata"
artifact: SPEC-001
track: implementable
status: Active
author: operator
created: 2026-03-30
last-updated: 2026-03-30
priority-weight: high
type: enhancement
parent-epic: EPIC-001
parent-initiative: ""
linked-artifacts:
  - SPIKE-001
depends-on-artifacts: []
addresses: []
evidence-pool: ""
source-issue: ""
swain-do: required
---

# Zero-Install Python Scripts via PEP 723 Inline Metadata

## Problem Statement

Every Python script in this repo requires a pre-configured venv (`venv/bin/python`) with dependencies installed from `requirements.txt`. This creates a setup barrier: users must create the venv, install packages, and all SKILL.md documentation hardcodes the `venv/bin/python` prefix. With `uv run` and PEP 723 inline script metadata, each script can declare its own dependencies and run with zero prior setup.

## Desired Outcomes

Users (and Claude agents consuming these skills) can run any Python script with `uv run script.py` — no venv creation, no `pip install`, no `requirements.txt`. The skills become truly portable: clone the repo, have `uv` installed, and everything works.

## External Behavior

**Inputs:** Each Python script in `public/` gains a PEP 723 metadata block declaring its dependencies.

**Outputs:** Scripts run identically to today but via `uv run` instead of `venv/bin/python`.

**Preconditions:** `uv` must be installed (already required by project conventions).

**Constraints:**
- Scripts must remain individually runnable — no shared virtual environment
- Each script declares only the dependencies it actually imports
- System tool dependencies (`soffice`, `pdftoppm`, `pandoc`) are unchanged — they're external binaries

## Acceptance Criteria

1. **Given** any Python script under `public/`, **when** run via `uv run <script>`, **then** it executes successfully with no prior install step.

2. **Given** the PEP 723 metadata block in each script, **when** inspected, **then** it lists exactly the third-party packages that script imports (no extras, no missing).

3. **Given** all SKILL.md files and AGENTS.md, **when** reviewed, **then** all `venv/bin/python` references are replaced with `uv run` equivalents.

4. **Given** `requirements.txt`, **when** migration is complete, **then** the file is removed (dependencies live in individual scripts).

5. **Given** `markitdown` (used as a CLI tool, not imported), **when** invoked, **then** it runs via `uvx markitdown` instead of `venv/bin/python -m markitdown`.

6. **Given** the `venv/` directory convention in AGENTS.md and all SKILL.md files, **when** migration is complete, **then** no references to `venv/` remain.

## Verification

| Criterion | Evidence | Result |
|-----------|----------|--------|

## Scope & Constraints

**In scope:**
- All 18 Python scripts under `public/`
- All SKILL.md files referencing `venv/bin/python`
- AGENTS.md (formerly CLAUDE.md) command references
- Removal of `requirements.txt` and venv setup instructions

**Out of scope:**
- Node.js dependencies (covered by SPIKE-001)
- System tools (soffice, pdftoppm, pandoc) — these are external binaries
- Any behavioral changes to scripts — this is a packaging change only

**Dependency inventory (per script):**

| Script | Dependencies |
|--------|-------------|
| `pptx/scripts/thumbnail.py` | `python-pptx`, `Pillow`, `pdf2image` |
| `pptx/scripts/inventory.py` | `python-pptx` |
| `pptx/scripts/replace.py` | `python-pptx` |
| `pptx/scripts/rearrange.py` | `python-pptx` |
| `pptx/ooxml/scripts/unpack.py` | `defusedxml`, `lxml` |
| `pptx/ooxml/scripts/validate.py` | `lxml` |
| `pptx/ooxml/scripts/pack.py` | `lxml` |
| `docx/ooxml/scripts/unpack.py` | `defusedxml`, `lxml` |
| `docx/ooxml/scripts/validate.py` | `lxml` |
| `docx/ooxml/scripts/pack.py` | `lxml` |
| `docx/scripts/document.py` | `lxml` |
| `docx/scripts/utilities.py` | (stdlib only) |
| `pdf/scripts/fill_pdf_form_with_annotations.py` | `pypdf` |
| `pdf/scripts/fill_fillable_fields.py` | `pypdf` |
| `pdf/scripts/extract_form_field_info.py` | `pypdf` |
| `pdf/scripts/check_fillable_fields.py` | `pypdf` |
| `pdf/scripts/check_bounding_boxes.py` | `pypdf`, `Pillow` |
| `pdf/scripts/convert_pdf_to_images.py` | `pdf2image` |
| `pdf/scripts/create_validation_image.py` | `Pillow` |
| `markitdown` (CLI) | via `uvx markitdown` |

**Unused in requirements.txt:** `six` (not imported anywhere), `openpyxl` (not imported in public/ scripts — may be used inline in SKILL.md examples).

## Implementation Approach

1. Add PEP 723 inline metadata blocks to each Python script, declaring only what it imports.
2. Verify each script runs via `uv run` — test one per directory (pptx, docx, pdf).
3. Update all SKILL.md files: replace `venv/bin/python public/...` with `uv run public/...`.
4. Update AGENTS.md: replace all venv references.
5. Replace `venv/bin/python -m markitdown` with `uvx markitdown`.
6. Remove `requirements.txt`.
7. Remove venv setup instructions from documentation.

## Lifecycle

| Phase | Date | Commit | Notes |
|-------|------|--------|-------|
| Active | 2026-03-30 | — | Initial creation |
