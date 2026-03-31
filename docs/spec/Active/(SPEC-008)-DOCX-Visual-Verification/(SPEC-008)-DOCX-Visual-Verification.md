---
title: "DOCX: Add Visual Verification to All Workflows"
artifact: SPEC-008
track: implementable
status: Active
author: operator
created: 2026-03-30
last-updated: 2026-03-30
priority-weight: high
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

# DOCX: Add Visual Verification to All Workflows

## Problem Statement

The DOCX skill has zero visual verification across all three workflows (create, edit, redline). The skill documents how to convert DOCX to PDF and PDF to images, but never integrates these steps into the actual workflows. Agents produce Word documents and verify correctness only via markdown text extraction — they never see what the document looks like when opened in Word.

This is the worst compliance gap: 0/3 workflows meet ADR-003.

## Acceptance Criteria

1. **Given** the "create new document" workflow, **when** the DOCX is saved, **then** the workflow includes: convert to PDF via `soffice --headless`, render PDF pages to JPEG, read images, check for layout/formatting issues.

2. **Given** the "edit existing document" workflow, **when** OOXML edits are packed, **then** the workflow includes the same render → inspect → iterate loop.

3. **Given** the "redline/tracked changes" workflow, **when** tracked changes are applied, **then** the workflow includes a visual check that: insertions/deletions are visible and correctly positioned, formatting hasn't broken, page layout is intact.

4. **Given** all three workflows, **when** an agent follows them, **then** it reads at least one rendered image of the output before declaring complete.

## Scope & Constraints

- Modifies workflow instructions in `public/docx/SKILL.md`
- The conversion pipeline already exists (soffice → pdftoppm/pymupdf) — this is about making it mandatory in workflows
- After SPEC-002, the PDF-to-image step will use pymupdf instead of pdftoppm

## Implementation Approach

Add a "Visual Verification" section to each workflow in `docx/SKILL.md`:

```
## Visual Verification (mandatory)
1. Convert to PDF: `soffice --headless --convert-to pdf --outdir outputs/<name>/ outputs/<name>/document.docx`
2. Render to images: `bin/to-images outputs/<name>/document.pdf outputs/<name>/pages`
3. Read page images and check for:
   - Text rendering correctly (no garbled characters, correct fonts)
   - Page layout intact (margins, headers/footers, columns)
   - Tables and lists properly formatted
   - Tracked changes visible (for redline workflow)
4. If issues found, fix the document and repeat from step 1.
```

## Lifecycle

| Phase | Date | Commit | Notes |
|-------|------|--------|-------|
| Active | 2026-03-30 | — | Initial creation |
