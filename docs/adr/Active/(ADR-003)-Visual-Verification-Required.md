---
title: "Visual Verification Required for Document Output"
artifact: ADR-003
track: standing
status: Active
author: operator
created: 2026-03-30
last-updated: 2026-03-30
linked-artifacts:
  - VISION-001
  - PERSONA-002
depends-on-artifacts: []
evidence-pool: ""
---

# Visual Verification Required for Document Output

## Context

AI agents (PERSONA-002) cannot open PowerPoint, Word, or Acrobat to visually inspect the documents they produce. They can verify XML structure, check that shapes contain text, and confirm files are valid ZIP archives — but structural correctness does not guarantee visual correctness. A presentation can have valid OOXML yet still render with text truncated by bounding boxes, overlapping elements, wrong fonts, or misaligned layouts. These are the defects that matter to the operator.

The gap between "structurally valid" and "visually correct" is where most agent-produced document failures occur.

## Decision

**Skills that produce visual documents (PPTX, DOCX, PDF) must include a rendered verification step.** The agent must convert the output to an image format it can inspect, then review the rendered result before declaring the task complete.

The verification methods, in order of preference:

1. **Thumbnail grid** (PPTX) — convert the presentation to PDF via LibreOffice, then render pages to a JPEG grid via the `thumbnail` script. The agent reads the grid image and checks for text truncation, overlap, alignment, and visual coherence. This is the primary verification method for presentations.

2. **PDF-to-image** (PDF, DOCX) — render PDF pages to JPEG at 150 DPI. For DOCX, first convert to PDF via LibreOffice. The agent reads the page images and checks for layout issues.

3. **OOXML validation** (PPTX, DOCX) — run the `validate` script to check XML structural integrity. This catches malformed XML, broken references, and schema violations. It is a necessary but not sufficient check — passing validation does not mean the document looks right.

**The workflow is: produce → render → inspect → iterate.** An agent must not declare a document task complete after only structural validation. At least one rendered image of the output must be read and assessed.

**SKILL.md files encode this requirement** by including the thumbnail/render step in the standard workflow, not as an optional "if you want to check" step.

## Alternatives Considered

**Structural validation only.** Run validate.py and check the exit code. Fast and deterministic but misses all visual defects. Rejected as insufficient — the whole point of these skills is producing documents that look right.

**Rely on the operator to check.** Produce the file and let the human open it. Works but defeats the purpose of delegation — the operator wanted the agent to handle the entire task. Acceptable as a final review, not as the primary quality gate.

**Headless browser rendering of OOXML.** Render the document in a browser using a JavaScript OOXML renderer. No reliable open-source option exists for faithful PowerPoint rendering. Rejected as infeasible.

## Consequences

**Positive:**
- Agents catch visual defects before the operator sees the file
- Iteration happens within the agent session, not as operator-agent back-and-forth
- Thumbnail grids are reusable — they serve as both verification and documentation of what was produced
- Consistent quality: the "produce → render → inspect → iterate" loop is the same whether a human or agent does the work

**Accepted downsides:**
- Requires LibreOffice for PDF conversion (already a prerequisite)
- Adds time to every document workflow (rendering + image analysis)
- Agent image analysis is imperfect — it catches gross layout issues but may miss subtle font rendering or color accuracy problems
- Thumbnail grids consume disk space (mitigated by outputting to gitignored `outputs/` directory)

## Lifecycle

| Phase | Date | Commit | Notes |
|-------|------|--------|-------|
| Active | 2026-03-30 | — | Initial creation |
