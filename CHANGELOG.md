# Changelog

## v1.0.0 — 2026-03-30

### Features

#### Office Document Skills
Four complete skill workflows for AI agents: PowerPoint (create from scratch,
from template, OOXML editing), Word (create, edit, redline with tracked changes),
Excel (create/edit with formulas, recalculation, zero-error validation), and
PDF (fill forms, merge, split, create with reportlab).

#### Visual Verification
All document-producing workflows now include mandatory render-and-inspect steps.
Agents convert output to images and check for layout issues before declaring
tasks complete. PPTX uses a two-pass approach: thumbnail grid for layout overview,
then per-slide renders at 200 DPI for detail. Structural validation alone is no
longer sufficient.

### Roadmap
- Zero-install migration planned: PEP 723 for Python scripts, Deno for Node.js,
  wrapper scripts as the agent-facing API. Prerequisites will shrink from five
  tools to three (uv, deno, LibreOffice).
- System tools (pandoc, poppler) being replaced by Python packages with bundled
  binaries (pymupdf, pypandoc-binary).

### Supporting
- Project governance established: PURPOSE.md, VISION-001, two personas (Operator,
  Claude Agent), three ADRs (run-first no-install, wrapper scripts, visual
  verification), two epics with ten specs.
- Forked from Anthropic's Claude desktop Office skills; restructured for agent
  portability and independent governance.
