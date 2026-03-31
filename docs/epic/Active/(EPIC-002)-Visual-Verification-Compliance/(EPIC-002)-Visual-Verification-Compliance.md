---
title: "Visual Verification Compliance"
artifact: EPIC-002
track: container
status: Active
author: operator
created: 2026-03-30
last-updated: 2026-03-30
parent-vision: VISION-001
parent-initiative: ""
priority-weight: high
success-criteria:
  - "Every document-producing workflow in every SKILL.md includes a mandatory render → inspect → iterate step"
  - "No workflow declares completion after structural validation alone"
  - "Agents read at least one rendered image of output before task completion"
depends-on-artifacts:
  - ADR-003
addresses: []
evidence-pool: ""
---

# Visual Verification Compliance

## Goal / Objective

Bring all four skills (PPTX, DOCX, PDF, XLSX) into full compliance with ADR-003. Every workflow that produces a visual document must include a mandatory "produce → render → inspect → iterate" loop. Structural validation (XML checks, formula recalc) is necessary but not sufficient — agents must see what the document looks like.

## Desired Outcomes

PERSONA-002 (the Claude Agent) catches visual defects — text truncation, broken layouts, misaligned elements, incorrect formatting — before the operator ever opens the file. Iteration happens within the agent session, not as operator-agent back-and-forth.

## Scope Boundaries

**In scope:**
- Adding render → inspect instructions to all document-producing workflows in all four SKILL.md files
- FORMS.md output verification for filled PDFs
- Leveraging existing tools (thumbnail.py, soffice, pdf-to-image scripts)

**Out of scope:**
- Writing new rendering tools (the tools exist, they just aren't wired into workflows)
- Changing script behavior
- Automated visual regression testing (agents do visual inspection manually via image reading)

## Child Specs

| Spec | Title | Status | Priority |
|------|-------|--------|----------|
| SPEC-006 | ADR-003 Compliance Audit | Active (audit complete) | high |
| SPEC-007 | PPTX: Visual Verification Gaps | Active | medium |
| SPEC-008 | DOCX: Visual Verification | Active | high |
| SPEC-009 | PDF: Output Verification | Active | medium |
| SPEC-010 | XLSX: Visual Verification | Active | medium |

## Key Dependencies

- ADR-003 defines the requirement
- LibreOffice required for DOCX/XLSX → PDF conversion (already a prerequisite)
- After EPIC-001 completes, PDF-to-image will use pymupdf instead of pdftoppm, and invocations will use bin/ wrappers

## Lifecycle

| Phase | Date | Commit | Notes |
|-------|------|--------|-------|
| Active | 2026-03-30 | — | Initial creation |
