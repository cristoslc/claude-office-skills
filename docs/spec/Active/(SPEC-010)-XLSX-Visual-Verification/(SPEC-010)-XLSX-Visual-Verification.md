---
title: "XLSX: Add Visual Verification to All Workflows"
artifact: SPEC-010
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

# XLSX: Add Visual Verification to All Workflows

## Problem Statement

The XLSX skill has zero visual verification. It has structural validation (formula recalculation via `recalc.py` catches #REF!, #DIV/0!, etc.) but no way for an agent to see what the spreadsheet looks like when opened in Excel. Charts, conditional formatting, color coding, number formatting, merged cells, and column widths are all invisible to structural checks.

## Acceptance Criteria

1. **Given** the "create new spreadsheet" workflow, **when** the XLSX is saved and recalculated, **then** the workflow includes: convert to PDF via `soffice --headless`, render PDF pages to images, read images, check for visual correctness.

2. **Given** the "edit existing spreadsheet" workflow, **when** edits are saved, **then** the same render → inspect loop applies.

3. **Given** the rendered images, **when** an agent inspects them, **then** it checks for: number formatting display, color coding (blue=inputs, black=formulas per SKILL.md conventions), column widths adequate for content, chart rendering, merged cell appearance.

4. **Given** all workflows, **when** an agent follows SKILL.md, **then** it cannot declare the task complete without having read at least one rendered image.

## Scope & Constraints

- Modifies workflow instructions in `public/xlsx/SKILL.md`
- LibreOffice is required for XLSX → PDF conversion (already a prerequisite)
- After SPEC-002, PDF → image uses pymupdf
- Charts are particularly important to verify visually — openpyxl creates chart definitions but only LibreOffice renders them

## Implementation Approach

Add a "Visual Verification" section to `xlsx/SKILL.md`:

```
## Visual Verification (mandatory)
1. Recalculate: `soffice --headless --calc --convert-to xlsx --outdir outputs/<name>/ outputs/<name>/workbook.xlsx`
2. Convert to PDF: `soffice --headless --convert-to pdf --outdir outputs/<name>/ outputs/<name>/workbook.xlsx`
3. Render to images: `bin/to-images outputs/<name>/workbook.pdf outputs/<name>/pages`
4. Read page images and check for:
   - Number formatting displays correctly (commas, decimals, currency symbols)
   - Color coding follows conventions (blue inputs, black formulas)
   - Column widths accommodate content (no truncation or ####)
   - Charts render with correct data, labels, and legends
   - Merged cells display properly
   - Conditional formatting visible where expected
5. If issues found, fix the workbook and repeat.
```

## Lifecycle

| Phase | Date | Commit | Notes |
|-------|------|--------|-------|
| Active | 2026-03-30 | — | Initial creation |
