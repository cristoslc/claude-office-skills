---
title: "PDF: Add Output Verification to Form Filling and Creation"
artifact: SPEC-009
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

# PDF: Add Output Verification to Form Filling and Creation

## Problem Statement

The PDF skill has partial ADR-003 compliance: the non-fillable form workflow verifies input structure visually (bounding box analysis), but none of the workflows verify the *output* — the filled form or created PDF. An agent fills a PDF form but never sees whether the text landed in the right position, at the right size, with the right alignment.

Additionally, the PDF creation workflow (via reportlab) has no visual verification at all.

## Acceptance Criteria

1. **Given** the fillable fields workflow in FORMS.md, **when** `fill_fillable_fields.py` produces a filled PDF, **then** the workflow includes: render filled PDF to images, read images, verify field values appear correctly positioned and legible.

2. **Given** the non-fillable fields workflow in FORMS.md, **when** `fill_pdf_form_with_annotations.py` produces a filled PDF, **then** the workflow includes: render filled PDF to images, compare against the original blank form images, verify annotations land within expected bounding boxes.

3. **Given** PDF creation via reportlab in SKILL.md, **when** the PDF is saved, **then** the workflow includes: render to images, read images, check for layout/text/formatting issues.

4. **Given** all three workflows, **when** an agent follows them, **then** it reads at least one rendered image of the *output* PDF before declaring complete.

## Scope & Constraints

- Modifies workflow instructions in `public/pdf/SKILL.md` and `public/pdf/FORMS.md`
- The `convert_pdf_to_images.py` script already exists — this is about making it mandatory for output verification
- The non-fillable form workflow already renders the *input* — extend it to also render the *output*

## Implementation Approach

1. In FORMS.md fillable fields workflow, after the fill step, add: "Render the filled PDF to images. Read each page image and verify field values are visible, correctly positioned, and legible."

2. In FORMS.md non-fillable fields workflow, after the fill step, add: "Render the filled PDF to images. Compare against the original blank form images. Verify each annotation appears within its intended bounding box."

3. In SKILL.md PDF creation section, after saving the PDF, add: "Render to images and visually inspect layout, text rendering, and page composition."

## Lifecycle

| Phase | Date | Commit | Notes |
|-------|------|--------|-------|
| Active | 2026-03-30 | — | Initial creation |
