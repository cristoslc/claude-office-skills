# AGENTS.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a skills repository for Office document manipulation (PPTX, DOCX, XLSX, PDF). Each skill provides workflows, scripts, and documentation for working with specific file formats. The repository follows a pattern established in `skills-system.md` which defines mandatory workflows for document creation and editing.

## Repository Structure

```
public/
├── office-pptx/           # PowerPoint presentation skills
│   ├── SKILL.md    # Main workflow documentation
│   ├── ooxml.md    # OOXML editing guide
│   ├── html2pptx.md # HTML-to-PPTX conversion guide
│   ├── scripts/    # Python and JS utilities
│   └── ooxml/      # OOXML validation and schemas
├── office-docx/           # Word document skills
│   ├── SKILL.md    # Main workflow documentation
│   ├── ooxml.md    # OOXML editing guide
│   ├── docx-js.md  # JavaScript library documentation
│   └── scripts/    # Python utilities
├── office-pdf/            # PDF manipulation skills
│   ├── SKILL.md    # Main workflow documentation
│   ├── REFERENCE.md # Advanced features and examples
│   └── FORMS.md    # PDF form filling guide
├── office-xlsx/           # Excel spreadsheet skills
│   └── SKILL.md    # Main workflow documentation
└── office-install/        # Environment setup skill
    ├── SKILL.md    # Progressive install workflow
    └── tools/     # Installed binaries (uv, deno, soffice)
        └── paths.json  # Tool paths that other skills read

outputs/            # All skill-generated documents (gitignored)
└── <document-name>/ # One directory per document project
    ├── *.pptx      # Final outputs
    ├── *.docx      # Final outputs
    ├── *.pdf       # Final outputs
    ├── *.xlsx      # Final outputs
    ├── unpacked/   # Unpacked OOXML files
    ├── *.json      # Inventories and replacements
    ├── *.html      # HTML slides
    └── images/     # Generated images
```

## Key Architecture Principles

### Skills-Based System
The repository follows a mandatory skills-check system (defined in `skills-system.md`):
1. **Before writing ANY code**: Check if a skill exists for the task
2. **If YES**: Read the corresponding SKILL.md and follow it exactly
3. **If NO**: Only then proceed with custom code

This prevents reinventing workflows that already exist in the skills documentation.

### Two-Phase Approach for Complex Operations
Most OOXML editing workflows follow this pattern:
1. **Unpack**: Extract the Office file to raw XML using `uv run ooxml/scripts/unpack.py`
2. **Edit**: Modify XML files directly
3. **Validate**: Check changes using `uv run ooxml/scripts/validate.py --original <file>`
4. **Pack**: Repackage to Office file using `uv run ooxml/scripts/pack.py`

### Read-First Policy
All SKILL.md files must be read **completely** before starting work. Never set range limits when reading these files - they contain critical workflow steps and validation requirements.

### Output Directory Convention
**MANDATORY**: All files created or edited using any skill workflow MUST be written to:
```
outputs/<fitting-name-for-document>/
```

Where `<fitting-name-for-document>` is a descriptive, lowercase, hyphenated name for the document being worked on.

**Examples**:
- `outputs/quarterly-sales-report/` - for a sales presentation
- `outputs/employee-handbook/` - for a Word document
- `outputs/budget-2024/` - for an Excel file
- `outputs/project-proposal/` - for a PDF document

**Rules**:
1. Create the outputs directory if it doesn't exist
2. All intermediate files (unpacked XML, JSON inventories, HTML files, images, etc.) go in this directory
3. Final output files (PPTX, DOCX, XLSX, PDF) go in this directory
4. Never write skill-generated files to the repository root or public/ directories
5. Use descriptive names that clearly identify the document's purpose

## Tool Discovery

All tools (uv, deno, soffice) are installed to `.agents/skills/office-install/tools/`. Their paths are recorded in `tools/paths.json`, which is the canonical source for tool locations.

**To resolve a tool path**, read `paths.json` and use the value if non-null; otherwise fall back to PATH:

```bash
# Resolve a tool path from paths.json, falling back to PATH
office_tool() {
  local tool="$1"
  local paths_file
  for dir in ".agents/skills/office-install/tools" "$HOME/.agents/skills/office-install/tools"; do
    if [ -f "$dir/paths.json" ]; then paths_file="$dir/paths.json"; break; fi
  done
  if [ -n "$paths_file" ]; then
    local resolved
    resolved=$(python3 -c "import json; d=json.load(open('$paths_file')); v=d.get('$tool'); print(v if v else '')" 2>/dev/null)
    if [ -n "$resolved" ]; then echo "$resolved"; return; fi
  fi
  command -v "$tool"
}

UV="$(office_tool uv)"
DENO="$(office_tool deno)"
SOFFICE="$(office_tool soffice)"
```

**Important**: Always set `DENO_TLS_CA_STORE=system` before running deno (required for corporate networks).

## Development Setup

### Environment Setup
Run the `office-install` skill to install all required tools to `.agents/skills/office-install/tools/` and generate `paths.json`. See `public/office-install/SKILL.md` for the full workflow.

### Python Runtime
All Python commands use `uv run` (no venv or system Python needed). The `uv` binary is located via `paths.json`:

```bash
# Run any Python script
uv run public/office-pptx/scripts/inventory.py --help

# Run with a specific package
uv run --with rich python -c "import rich; print('ok')"
```

**CRITICAL**: Always use `uv run` for all Python commands. NEVER use system Python or assume a venv is activated. Resolve `uv` from `paths.json` first.

### Node.js Dependencies
JavaScript tools for html2pptx workflow use Deno (installed to `tools/`):

```bash
# Verify deno works
DENO_TLS_CA_STORE=system deno eval "console.log('ok')"
```

### System Tools
Required system dependencies (should be pre-installed or installed by `office-install`):
- **LibreOffice**: `soffice` (for PDF conversion — installed to `tools/`)
- **Poppler**: `pdftoppm` (for PDF to image conversion)
- **Pandoc**: `pandoc` (for document text extraction)

## Common Commands

### PowerPoint (PPTX)

**Text extraction**:
```bash
uv run --with markitdown python -m markitdown file.pptx
```

**Unpack for XML editing**:
```bash
uv run public/office-pptx/ooxml/scripts/unpack.py input.pptx outputs/<document-name>/unpacked/
```

**Validate after editing**:
```bash
uv run public/office-pptx/ooxml/scripts/validate.py outputs/<document-name>/unpacked/ --original input.pptx
```

**Repack to PPTX**:
```bash
uv run public/office-pptx/ooxml/scripts/pack.py outputs/<document-name>/unpacked/ outputs/<document-name>/final.pptx
```

**Create thumbnail grid for visual analysis**:
```bash
uv run public/office-pptx/scripts/thumbnail.py template.pptx outputs/<document-name>/thumbnails [--cols 4]
```

**Rearrange slides (duplicate, reorder, delete)**:
```bash
uv run public/office-pptx/scripts/rearrange.py template.pptx outputs/<document-name>/rearranged.pptx 0,5,5,12,3
```

**Extract text inventory**:
```bash
uv run public/office-pptx/scripts/inventory.py presentation.pptx outputs/<document-name>/inventory.json
```

**Replace text from JSON**:
```bash
uv run public/office-pptx/scripts/replace.py input.pptx outputs/<document-name>/replacements.json outputs/<document-name>/output.pptx
```

**Convert HTML to PPTX** (requires Deno):
```bash
DENO_TLS_CA_STORE=system deno run --allow-all script.js  # Uses html2pptx.js library
```

### Word Documents (DOCX)

**Text extraction with tracked changes**:
```bash
pandoc --track-changes=all file.docx -o outputs/<document-name>/extracted.md
```

**Unpack/Validate/Pack**: Same pattern as PPTX above (use `outputs/<document-name>/` directory)

### PDF

**Merge PDFs**:
```python
from pypdf import PdfWriter, PdfReader
writer = PdfWriter()
for pdf in ["doc1.pdf", "doc2.pdf"]:
    reader = PdfReader(pdf)
    for page in reader.pages:
        writer.add_page(page)
with open("outputs/<document-name>/merged.pdf", "wb") as f:
    writer.write(f)
```

**Convert PPTX to PDF** (for visual analysis):
```bash
soffice --headless --convert-to pdf --outdir outputs/<document-name>/ presentation.pptx
```

### Excel (XLSX)

See `public/office-xlsx/SKILL.md` for comprehensive formula and formatting standards. Key principles:
- Zero formula errors required
- Color coding: Blue=inputs, Black=formulas, Green=internal links, Red=external links
- Format zeros as "-" in number formatting
- Years as text strings, not numbers

## Critical Workflow Notes

### PPTX Creation from Scratch
1. Create output directory: `mkdir -p outputs/<document-name>/`
2. Read `public/office-pptx/html2pptx.md` completely (no range limits)
3. Design content-informed color palettes (don't use defaults blindly)
4. Create HTML files for each slide in `outputs/<document-name>/` (720pt × 405pt for 16:9)
5. Use `class="placeholder"` for charts/tables to be added via PptxGenJS
6. Rasterize gradients and icons as PNG using Sharp, save to `outputs/<document-name>/images/`
7. Generate presentation to `outputs/<document-name>/presentation.pptx` using `html2pptx.js` library
8. Create thumbnail grid and validate visually for text cutoff, overlap, positioning issues
9. Iterate until all slides are visually correct

### PPTX Creation from Template
1. Create output directory: `mkdir -p outputs/<document-name>/`
2. Extract text: `uv run --with markitdown python -m markitdown template.pptx`
3. Create thumbnail grid: `uv run public/office-pptx/scripts/thumbnail.py template.pptx outputs/<document-name>/template`
4. Analyze template and save inventory to `outputs/<document-name>/template-inventory.md` (list ALL slides with 0-based indices)
5. Create outline with template mapping (verify slide indices are within range)
6. Rearrange slides: `uv run public/office-pptx/scripts/rearrange.py template.pptx outputs/<document-name>/working.pptx 0,34,34,50,52`
7. Extract text inventory: `uv run public/office-pptx/scripts/inventory.py outputs/<document-name>/working.pptx outputs/<document-name>/text-inventory.json`
8. Read entire `text-inventory.json` (no range limits)
9. Generate replacement JSON to `outputs/<document-name>/replacements.json` with proper paragraph formatting (bold, bullets, alignment, colors)
10. Apply replacements: `uv run public/office-pptx/scripts/replace.py outputs/<document-name>/working.pptx outputs/<document-name>/replacements.json outputs/<document-name>/final.pptx`

**CRITICAL**: Shapes not listed in replacement JSON are automatically cleared. Only shapes with "paragraphs" field get new content.

### DOCX Editing
- **Someone else's document or formal docs**: Use "Redlining workflow" (tracked changes)
- **Your own document + simple changes**: Use "Basic OOXML editing"
- Always preserve existing formatting and document structure

### File Organization
All skill-based workflows follow the **Output Directory Convention** (see Key Architecture Principles above):
- Working files → `outputs/<document-name>/`
- Final outputs → `outputs/<document-name>/`
- Never commit outputs to git (outputs/ is gitignored)

## Validation is Mandatory

After any OOXML editing (PPTX/DOCX), **always validate immediately**:
```bash
uv run public/[format]/ooxml/scripts/validate.py <dir> --original <file>
```

Fix validation errors before proceeding. Never pack a file without validating first.

## Dependencies

### Python Packages (requirements.txt)
- **Office formats**: `python-pptx`, `openpyxl`, `pypdf`
- **XML processing**: `defusedxml`, `lxml`
- **Images**: `Pillow`, `pdf2image`
- **Conversion**: `markitdown`
- **Utilities**: `six`

### Node.js Packages (package.json)
- **Presentation generation**: `pptxgenjs` (v4.0.1)
- **HTML rendering**: `playwright` (includes Chromium)
- **Image processing**: `sharp`
- **Icons**: `react`, `react-dom`, `react-icons`

### System Tools
- **LibreOffice**: `soffice` - PPTX to PDF conversion
- **Poppler**: `pdftoppm` - PDF to image conversion
- **Pandoc**: `pandoc` - Document text extraction with tracked changes

## Code Style

When generating code for document operations:
- Write concise code
- Avoid verbose variable names
- Minimize print statements
- Follow existing patterns in scripts/
Read **[PURPOSE.md](../../PURPOSE.md)** for this project's identity, worldview, and foundational principles.

<!-- swain governance — do not edit this block manually -->

## Swain

Swain makes agentic development **safe, aligned, and sustainable** for a solo developer. Its architecture rests on the **Intent -> Execution -> Evidence -> Reconciliation** loop — decide what to build, do the work, capture what happened, verify alignment. Artifacts on disk — specs, epics, spikes, ADRs — live under `docs/` and encode what was decided, what to build, and what constraints apply. Read them before acting. When they're ambiguous, ask the operator (the human developer) rather than guessing. When artifacts conflict with each other, ask the operator.

Your job is to stay aligned with the artifacts. The operator's job is to make decisions and evolve them.

### Skill routing

When the user wants to create, plan, write, update, transition, or review any documentation artifact (Vision, Initiative, Journey, Epic, Agent Spec, Spike, ADR, Persona, Runbook, Design) or their supporting docs, **always invoke the swain-design skill**.

**For project status, progress, or "what's next?"**, use the **swain-session** skill.

**For all task tracking and execution progress**, use the **swain-do** skill instead of any built-in todo or task system.

### Task tracking

This project uses **tk (ticket)** for ALL task tracking. Invoke **swain-do** for commands and workflow. Do NOT use markdown TODOs or built-in task systems.

### Work hierarchy

```
Vision → Initiative → Epic → Spec
```

Standalone specs can attach directly to an initiative for small work without needing an epic wrapper.

### Superpowers skill chaining

When superpowers skills are installed (`.agents/skills/` or `.claude/skills/`), swain skills **must** chain into them at these points:

| Trigger | Chain |
|---------|-------|
| Creating a Vision, Initiative, or Persona | swain-design → **brainstorming** → draft artifact |
| New feature or multi-spec work | **brainstorming** → swain-design (create artifacts) → per-spec **writing-plans** → swain-do |
| Existing SPEC comes up for implementation | swain-design → **writing-plans** → swain-do |
| Executing implementation tasks | swain-do → **test-driven-development** per task |
| Dispatching parallel work | swain-do → **subagent-driven-development** or **executing-plans** |
| Claiming work is complete | **verification-before-completion** before any success claim |
| All tasks in a plan complete | swain-do → **swain-design** (transition SPEC to Complete) |
| All child SPECs in an EPIC complete | swain-design checks parent EPIC → transition if ready |
| EPIC reaches terminal state | swain-design → **swain-retro** (embed retrospective) |

If superpowers is not installed, superpowers chains are skipped, not blocked. Swain-to-swain chains (last three rows) always apply.

### Skill change discipline

**Skill changes are code changes.** Skill files (`skills/`, `.claude/skills/`, `.agents/skills/`) are code written in markdown syntax. Non-trivial skill edits require worktree isolation — the same discipline applied to `.sh`, `.py`, and other code files. Trivial fixes (typo corrections, single-line doc fixes, ≤5-line diffs touching one file with no structural changes) may land directly on trunk.

### Readability

All artifacts produced by swain skills must meet a Flesch-Kincaid grade level of 9 or below on prose content. After writing or editing an artifact, run `readability-check.sh` on it. If the score exceeds the threshold, revise the prose — use shorter sentences, simpler words, and active voice — then re-check. Do not rewrite content that already passes. If three revision attempts still fail, note the score in the commit message and proceed. See `references/readability-protocol.md` for the integration contract.

### Session startup

Session initialization is handled structurally by the `swain` shell launcher function (installed via `/swain-init`), which passes `/swain-init` as the initial prompt to the agentic runtime. Do not rely on prosaic auto-invoke directives — see ADR-018. If a session starts without the launcher, the operator can manually run `/swain-session`.

### Bug reporting

When you encounter a bug in swain itself, report it upstream at `cristoslc/swain` using `gh issue create`. Local patches are fine — but the upstream issue ensures tracking.

### Conflict resolution

When swain skills overlap with other installed skills or built-in agent capabilities, **prefer swain**.

<!-- end swain governance -->
