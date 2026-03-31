# claude-office-skills

A skills library that gives AI coding agents the ability to create and manipulate Office documents -- PowerPoint, Word, Excel, and PDF -- through structured, repeatable workflows.

## What this is

Each skill is a SKILL.md file that tells an agent exactly how to produce a specific type of document: which scripts to call, in what order, with what validation steps. The agent reads the skill, follows the workflow, and produces a polished document. No improvisation, no guessing at library APIs.

This project originated from Anthropic's internal [Office document skills](https://support.claude.com/en/articles/12111783-create-and-edit-files-with-claude) shipped with Claude desktop. It has since diverged significantly: the skills are restructured for portability across any agent that can read markdown and run shell commands, every workflow includes mandatory visual verification, and the project has its own governance driving it toward a zero-install architecture.

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
> Edit this Word document and add tracked changes for sections 3 and 5
> Fill out this PDF form with the data from applicant.json
> Build an Excel budget model with these line items
```

The agent reads the appropriate SKILL.md, executes each step, visually verifies the output, and saves everything to `outputs/<document-name>/`.

### Visual verification

Every document-producing workflow includes a mandatory render-and-inspect step. The agent converts output to images and checks for layout issues, text truncation, and formatting problems before declaring the task complete. Structural validation alone is not sufficient -- a document can have valid XML and still look wrong.

For presentations, this is a two-pass process: thumbnail grid for layout overview, then per-slide renders at 200 DPI for detail checks.

See [ADR-003](docs/adr/Active/(ADR-003)-Visual-Verification-Required.md) for the rationale.

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

## Roadmap

**Zero-Install Office Skills** ([EPIC-001](docs/epic/Active/(EPIC-001)-Zero-Install-Office-Skills/(EPIC-001)-Zero-Install-Office-Skills.md)) -- eliminate all library installation steps. Python scripts get PEP 723 inline metadata, Node.js moves to Deno, each skill gets a `bin/` directory of wrapper scripts as the agent-facing API. Prerequisites shrink from five tools to three.

**Visual Verification Compliance** ([EPIC-002](docs/epic/Active/(EPIC-002)-Visual-Verification-Compliance/(EPIC-002)-Visual-Verification-Compliance.md)) -- complete. All SKILL.md files now include mandatory render-inspect-iterate loops.

## Origin and attribution

This project began as a fork of the Office document skills bundled with [Claude desktop](https://support.claude.com/en/articles/12111783-create-and-edit-files-with-claude). The original scripts and workflows were authored by Anthropic's Claude. This fork has since taken its own direction -- restructured for agent portability, governed by its own vision and ADRs, and evolving toward a zero-install architecture.

If Anthropic wishes for this repository to be taken down, please contact me and I will comply immediately.
