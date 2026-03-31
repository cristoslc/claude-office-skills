---
title: "ADR-003 Compliance Audit — Visual Verification Gaps"
artifact: SPEC-006
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
  - VISION-001
depends-on-artifacts: []
addresses: []
evidence-pool: ""
source-issue: ""
swain-do: required
---

# ADR-003 Compliance Audit — Visual Verification Gaps

## Problem Statement

ADR-003 requires all skills that produce visual documents to include a mandatory "produce → render → inspect → iterate" workflow. An audit of all four SKILL.md files reveals that only 1 of 12 major workflows is fully compliant (PPTX create-from-scratch). The remaining 11 workflows either skip visual verification entirely or only partially implement it.

## Audit Results

| Skill | Workflow | Compliance | Gap |
|-------|----------|:---:|-----|
| PPTX | Create from scratch | FULL | — |
| PPTX | Edit existing (OOXML) | FAILED | No render/inspect after OOXML edits |
| PPTX | Create from template | PARTIAL | Verifies template but not final output after replacement |
| DOCX | Create new | FAILED | Zero visual verification |
| DOCX | Edit existing | FAILED | Zero visual verification |
| DOCX | Redline/tracked changes | FAILED | Only markdown text verification |
| PDF | Create new (reportlab) | FAILED | No render/inspect of created PDF |
| PDF | Fill forms (fillable) | FAILED | No verification of filled output |
| PDF | Fill forms (non-fillable) | PARTIAL | Verifies input structure, not filled output |
| XLSX | Create new | FAILED | Zero visual verification |
| XLSX | Edit existing | FAILED | Zero visual verification |

**Overall: ~8% compliance** (1/12 workflows fully meet ADR-003).

## Desired Outcomes

Every document-producing workflow in every SKILL.md includes a mandatory render-and-inspect step. Agents never declare a document task complete without visually verifying the output.

## Acceptance Criteria

1. **Given** each SKILL.md file, **when** audited against ADR-003, **then** every document-producing workflow includes a render → inspect → iterate step.

2. **Given** the audit, **when** gaps are identified, **then** a spec is created for each skill with specific remediation instructions.

## Remediation Specs Produced

This audit produced four child specs:

- SPEC-007 — PPTX: add visual verification to edit and template workflows
- SPEC-008 — DOCX: add visual verification to all workflows
- SPEC-009 — PDF: add output verification to form filling and creation workflows
- SPEC-010 — XLSX: add visual verification to all workflows

## Scope & Constraints

This spec is the audit itself — it produces the gap analysis and child specs. The child specs contain the implementation work.

## Implementation Approach

1. Read all SKILL.md files and supplementary docs
2. Compare each workflow against ADR-003 requirements
3. Classify compliance: FULL, PARTIAL, FAILED
4. For each gap, create a remediation spec with specific instructions

## Lifecycle

| Phase | Date | Commit | Notes |
|-------|------|--------|-------|
| Active | 2026-03-30 | — | Audit complete, child specs created |
