# claude-office-skills

A skills library that gives AI coding agents the ability to create and manipulate Office documents -- PowerPoint, Word, Excel, and PDF -- through structured, repeatable workflows.

## What this is

Each skill is a SKILL.md file that tells an agent exactly how to produce a specific type of document: which scripts to call, in what order, with what validation steps. The agent reads the skill, follows the workflow, and produces a polished document. No improvisation, no guessing at library APIs.

Forked from [tfriedel/claude-office-skills](https://github.com/tfriedel/claude-office-skills), which extracted the Office document skills from [Claude desktop](https://support.claude.com/en/articles/12111783-create-and-edit-files-with-claude). This fork has since diverged significantly: skills restructured for portability across any agent runtime, mandatory visual verification across all workflows, its own governance (vision, ADRs, specs), and a roadmap toward zero-install architecture.

## Supported formats

| Format | Skill | Capabilities |
|--------|-------|-------------|
| **PowerPoint** | `public/pptx/` | Create from scratch (HTML-to-PPTX), from templates (inventory/replace), OOXML editing |
| **Word** | `public/docx/` | Create (docx-js), edit (OOXML), redline with tracked changes |
| **Excel** | `public/xlsx/` | Create/edit with openpyxl, formula recalculation, zero-error validation |
| **PDF** | `public/pdf/` | Fill forms (fillable + non-fillable), merge, split, create (reportlab) |

## Prerequisites

Currently requires:

```bash
# Python environment
python3 -m venv venv && venv/bin/pip install -r requirements.txt

# Node.js dependencies (for html2pptx)
npm install

# System tools
brew install libreoffice poppler pandoc
```

This is being simplified. The [zero-install migration](docs/epic/Active/(EPIC-001)-Zero-Install-Office-Skills/(EPIC-001)-Zero-Install-Office-Skills.md) will reduce prerequisites to three tools: `uv`, `deno`, and `libreoffice`. Python scripts will declare their own dependencies inline (PEP 723), Node.js moves to Deno, and system tools like poppler and pandoc get replaced by Python packages with bundled binaries.

## Usage

Tell your agent what you want:

```
> Create a quarterly sales presentation with 5 slides
> Create a powerpoint presentation based on @input/slide_notes.txt
> Edit this Word document and add tracked changes
> Build an Excel financial model for budget projections
> Fill out this PDF form with data from this JSON
```

The agent will:

1. Read the appropriate SKILL.md workflow
2. Execute each step (scripts, validation, rendering)
3. Visually verify the output (render to images, inspect for issues)
4. Save everything to `outputs/<document-name>/`

### Manual usage

All scripts can be run directly:

```bash
# Create PowerPoint thumbnail grid
venv/bin/python public/pptx/scripts/thumbnail.py template.pptx outputs/review/thumbnails

# Rearrange slides (duplicate, reorder, delete by 0-based index)
venv/bin/python public/pptx/scripts/rearrange.py template.pptx outputs/deck/final.pptx 0,5,5,12,3

# Extract text inventory from a presentation
venv/bin/python public/pptx/scripts/inventory.py deck.pptx outputs/deck/inventory.json

# Replace text from a JSON mapping
venv/bin/python public/pptx/scripts/replace.py input.pptx outputs/deck/replacements.json outputs/deck/output.pptx

# Extract text from any Office document
venv/bin/python -m markitdown document.pptx
```

### Example: creating a presentation from a template

```bash
# 1. Extract template text
venv/bin/python -m markitdown template.pptx

# 2. Generate thumbnail grid for visual analysis
venv/bin/python public/pptx/scripts/thumbnail.py template.pptx outputs/sales-deck/thumbnails

# 3. Rearrange slides to match your outline
venv/bin/python public/pptx/scripts/rearrange.py template.pptx outputs/sales-deck/working.pptx 0,15,15,23,8

# 4. Extract text inventory (shapes and their current content)
venv/bin/python public/pptx/scripts/inventory.py outputs/sales-deck/working.pptx outputs/sales-deck/inventory.json

# 5. Create replacement JSON with new content + formatting
# (agent generates outputs/sales-deck/replacements.json)

# 6. Apply replacements
venv/bin/python public/pptx/scripts/replace.py outputs/sales-deck/working.pptx outputs/sales-deck/replacements.json outputs/sales-deck/final.pptx

# 7. Visual verification — thumbnail grid then per-slide renders
venv/bin/python public/pptx/scripts/thumbnail.py outputs/sales-deck/final.pptx outputs/sales-deck/final-thumbnails
soffice --headless --convert-to pdf --outdir outputs/sales-deck/ outputs/sales-deck/final.pptx
pdftoppm -jpeg -r 200 outputs/sales-deck/final.pdf outputs/sales-deck/slide
```

The agent handles all of this automatically when you ask it to create a presentation.

### Visual verification

Every document-producing workflow includes a mandatory render-and-inspect step. The agent converts output to images and checks for layout issues, text truncation, and formatting problems before declaring the task complete. Structural validation alone is not sufficient -- a document can have valid XML and still look wrong.

For presentations, this is a two-pass process: thumbnail grid for layout overview, then per-slide renders at 200 DPI for detail checks. Thumbnail grids are too low-resolution to catch fine text issues on their own.

See [ADR-003](docs/adr/Active/(ADR-003)-Visual-Verification-Required.md) for the rationale.

## Output directory convention

All generated files go to `outputs/<document-name>/`:

```
outputs/
├── quarterly-sales-report/
│   ├── final.pptx
│   ├── final-thumbnails.jpg
│   ├── slide-1.jpg, slide-2.jpg, ...
│   ├── inventory.json
│   └── replacements.json
├── employee-handbook/
│   ├── handbook.docx
│   └── unpacked/
└── budget-2024/
    └── budget.xlsx
```

This keeps your working directory clean and makes automation easier.

## Architecture decisions

| ADR | Decision |
|-----|----------|
| [ADR-001](docs/adr/Active/(ADR-001)-Run-First-No-Install.md) | **Run-first, no-install** -- uv for Python, Deno for Node.js, bundled alternatives for system tools |
| [ADR-002](docs/adr/Active/(ADR-002)-Wrapper-Scripts-As-Skill-API.md) | **Wrapper scripts as skill API** -- `<skill>/bin/<command>` hides runtime details from agents |
| [ADR-003](docs/adr/Active/(ADR-003)-Visual-Verification-Required.md) | **Visual verification required** -- agents must render and inspect output, not just validate structure |

## Repository structure

```
public/
  pptx/         PowerPoint skill (SKILL.md, scripts/, ooxml/)
  docx/         Word skill (SKILL.md, scripts/, ooxml/)
  pdf/          PDF skill (SKILL.md, FORMS.md, REFERENCE.md, scripts/)
  xlsx/         Excel skill (SKILL.md)

docs/
  vision/       Product vision
  epic/         Delivery epics
  spec/         Implementation specs
  adr/          Architecture decisions
  persona/      User personas
  research/     Completed research spikes

outputs/        Generated documents (gitignored)
```

## How it works

Each format has a SKILL.md file that defines the workflow. The agent:

1. **Reads the skill** -- loads the complete workflow from SKILL.md
2. **Follows the workflow** -- executes each step precisely
3. **Validates structure** -- runs OOXML validation scripts where applicable
4. **Verifies visually** -- renders output to images and inspects for problems
5. **Organizes files** -- all outputs go to `outputs/<document-name>/`

## Roadmap

**Zero-Install Office Skills** ([EPIC-001](docs/epic/Active/(EPIC-001)-Zero-Install-Office-Skills/(EPIC-001)-Zero-Install-Office-Skills.md)) -- eliminate all library installation steps. Python scripts get PEP 723 inline metadata, Node.js moves to Deno, each skill gets a `bin/` directory of wrapper scripts as the agent-facing API. Prerequisites shrink from five tools to three.

**Visual Verification Compliance** ([EPIC-002](docs/epic/Active/(EPIC-002)-Visual-Verification-Compliance/(EPIC-002)-Visual-Verification-Compliance.md)) -- complete. All SKILL.md files now include mandatory render-inspect-iterate loops.

## Documentation

- **Project conventions**: See `AGENTS.md` (via `@AGENTS.md` in CLAUDE.md)
- **Workflows**: Each `public/*/SKILL.md` defines complete workflows
- **Project vision**: [PURPOSE.md](PURPOSE.md) and [VISION-001](docs/vision/Active/(VISION-001)-Office-Skills/(VISION-001)-Office-Skills.md)

## Origin and attribution

This project is a fork of [tfriedel/claude-office-skills](https://github.com/tfriedel/claude-office-skills), which extracted the Office document skills bundled inside [Claude desktop](https://support.claude.com/en/articles/12111783-create-and-edit-files-with-claude). This fork has since taken its own direction: restructured for agent portability, governed by its own vision and ADRs, and evolving toward a zero-install architecture.
