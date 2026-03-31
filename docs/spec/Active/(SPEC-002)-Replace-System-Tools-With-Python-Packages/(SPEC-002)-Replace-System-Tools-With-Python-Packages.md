---
title: "Replace System Tools with Python Packages"
artifact: SPEC-002
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
depends-on-artifacts:
  - SPEC-001
addresses: []
evidence-pool: ""
source-issue: ""
swain-do: required
---

# Replace System Tools with Python Packages

## Problem Statement

Two system tool prerequisites — `pdftoppm` (poppler) and `pandoc` — can be replaced by Python packages that bundle their native binaries inside wheels. This eliminates them from the prereq list and makes them zero-install via `uv run`.

## Desired Outcomes

Users no longer need to install poppler or pandoc. The functionality runs via Python packages that uv downloads and caches automatically.

## External Behavior

**pdftoppm replacement:**
- `pdf2image` (which wraps pdftoppm) is replaced by `pymupdf` (bundles MuPDF, AGPL license) or `pypdfium2` (bundles PDFium, BSD license)
- Scripts that call `pdftoppm` via subprocess are rewritten to use the Python library directly
- Output format (JPEG/PNG at configurable DPI) remains identical

**pandoc replacement:**
- `pypandoc-binary` bundles the pandoc binary inside its wheel
- DOCX text extraction with tracked changes uses `pypandoc.convert_file()` instead of subprocess `pandoc`
- Output format (markdown with tracked changes) remains identical

**Preconditions:** `uv` installed (handled by SPEC-001).

## Acceptance Criteria

1. **Given** `convert_pdf_to_images.py`, **when** run via `uv run`, **then** it converts PDF pages to JPEG images at 150 DPI without `pdftoppm` installed.

2. **Given** `thumbnail.py`, **when** run via `uv run`, **then** it creates slide thumbnail grids without `pdftoppm` installed (thumbnail.py calls pdf2image internally — this must be updated).

3. **Given** a DOCX file with tracked changes, **when** extracted via the updated workflow, **then** markdown output with tracked changes is produced without `pandoc` installed.

4. **Given** the system, **when** `pdftoppm` and `pandoc` are not on PATH, **then** all scripts still function correctly.

## Verification

| Criterion | Evidence | Result |
|-----------|----------|--------|

## Scope & Constraints

**In scope:**
- `public/pdf/scripts/convert_pdf_to_images.py` — replace `pdf2image` (pdftoppm wrapper) with `pymupdf`
- `public/pptx/scripts/thumbnail.py` — replace `pdf2image` dependency chain
- DOCX text extraction workflow — replace `pandoc` subprocess call with `pypandoc-binary`

**Out of scope:**
- LibreOffice (`soffice`) — no Python replacement exists
- Any behavioral changes to output format

**License note:** `pymupdf` is AGPL-3.0. Acceptable for this internal tooling repo. If a permissive license is needed, `pypdfium2` (BSD/Apache) is the alternative.

## Implementation Approach

1. Replace `pdf2image` usage in `convert_pdf_to_images.py` with `pymupdf` (add PEP 723 metadata: `pymupdf`).
2. Update `thumbnail.py` to use `pymupdf` instead of the `pdf2image` → `pdftoppm` chain.
3. Create a Python wrapper for pandoc text extraction using `pypandoc-binary`.
4. Update PEP 723 metadata blocks in affected scripts.
5. Remove `pdf2image` from any remaining dependency references.

## Lifecycle

| Phase | Date | Commit | Notes |
|-------|------|--------|-------|
| Active | 2026-03-30 | — | Initial creation |
