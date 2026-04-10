---
title: "Wrapper Scripts (Skill Bin API)"
artifact: SPEC-004
track: implementable
status: Active
author: operator
created: 2026-03-30
last-updated: 2026-03-30
priority-weight: high
type: enhancement
parent-epic: EPIC-001
parent-initiative: ""
linked-artifacts: []
depends-on-artifacts:
  - SPEC-001
  - SPEC-002
  - SPEC-003
  - SPEC-006
addresses: []
evidence-pool: ""
source-issue: ""
swain-do: required
---

# Wrapper Scripts (Skill Bin API)

## Problem Statement

After SPEC-001/002/003, scripts run via `uv run --with pkg1 --with pkg2 public/office-pptx/scripts/thumbnail.py` or `deno run --allow-all public/office-pptx/scripts/html2pptx.js`. These invocations are long, error-prone, and force agents to construct runtime-specific command lines. A `bin/` directory per skill with simple wrapper scripts provides a stable, agent-friendly API: `public/office-pptx/bin/thumbnail input.pptx output/`.

## Desired Outcomes

Each skill has a `bin/` directory containing short shell scripts that wrap the underlying Python/Deno/system tool invocations. SKILL.md files reference these wrappers as the canonical way to invoke functionality. Agents never need to know about `uv run --with`, `deno run --allow-all`, or PEP 723 metadata — they just call the wrapper.

## External Behavior

**Convention:** `public/<skill>/bin/<command>` — cross-platform wrapper scripts. Each command has two files:
- `<command>` — bash script for macOS/Linux
- `<command>.cmd` — cmd script for Windows

Both resolve their own directory, locate the runtime binary (PATH or `tools/`), and pass through all arguments.

### Tool discovery

Wrappers locate `uv`, `deno`, and `soffice` using this search order:
1. **Environment variable override**: `OFFICE_SKILLS_UV`, `OFFICE_SKILLS_DENO`, `OFFICE_SKILLS_SOFFICE`
2. **Portable `tools/` directory**: `<repo-root>/tools/uv`, `<repo-root>/tools/deno`, etc.
3. **System PATH**: fall back to globally installed binaries

This allows the install skill (SPEC-006) to place portable binaries in `tools/` and have them work immediately without modifying PATH or environment.

### Bash wrappers (macOS/Linux)

**Example — `public/office-pptx/bin/thumbnail`:**
```bash
#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
UV="${OFFICE_SKILLS_UV:-${REPO_ROOT}/tools/uv}"
[ -x "$UV" ] || UV="uv"
exec "$UV" run "$SCRIPT_DIR/scripts/thumbnail.py" "$@"
```

**Example — `public/office-pptx/bin/html2pptx`:**
```bash
#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
DENO="${OFFICE_SKILLS_DENO:-${REPO_ROOT}/tools/deno}"
[ -x "$DENO" ] || DENO="deno"
exec "$DENO" run --allow-all "$SCRIPT_DIR/scripts/html2pptx.js" "$@"
```

**Example — `public/office-pptx/bin/markitdown`:**
```bash
#!/usr/bin/env bash
set -euo pipefail
REPO_ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"
UV="${OFFICE_SKILLS_UV:-${REPO_ROOT}/tools/uv}"
[ -x "$UV" ] || UV="uvx"
exec "$UV" markitdown "$@"
```

### Windows wrappers

**Example — `public/office-pptx/bin/thumbnail.cmd`:**
```cmd
@echo off
setlocal
set "SCRIPT_DIR=%~dp0.."
set "REPO_ROOT=%~dp0..\.."
if defined OFFICE_SKILLS_UV (set "UV=%OFFICE_SKILLS_UV%") else (
  if exist "%REPO_ROOT%\tools\uv.exe" (set "UV=%REPO_ROOT%\tools\uv.exe") else (set "UV=uv")
)
"%UV%" run "%SCRIPT_DIR%\scripts\thumbnail.py" %*
```

**Example — `public/office-pptx/bin/html2pptx.cmd`:**
```cmd
@echo off
setlocal
set "SCRIPT_DIR=%~dp0.."
set "REPO_ROOT=%~dp0..\.."
if defined OFFICE_SKILLS_DENO (set "DENO=%OFFICE_SKILLS_DENO%") else (
  if exist "%REPO_ROOT%\tools\deno.exe" (set "DENO=%REPO_ROOT%\tools\deno.exe") else (set "DENO=deno")
)
"%DENO%" run --allow-all "%SCRIPT_DIR%\scripts\html2pptx.js" %*
```

## Acceptance Criteria

1. **Given** each skill directory (`pptx`, `docx`, `pdf`, `xlsx`), **when** listing `bin/`, **then** every script referenced in that skill's SKILL.md has a corresponding wrapper.

2. **Given** any wrapper script, **when** run with `--help` or no args, **then** it passes through to the underlying script's usage message (no wrapper-specific help needed).

3. **Given** a wrapper script, **when** inspected, **then** it is under 15 lines, uses `exec` (bash) or direct invocation (cmd) to replace the shell process, and does not hardcode absolute paths.

4. **Given** the wrapper convention, **when** an agent reads SKILL.md, **then** all invocation examples use `public/<skill>/bin/<command>` paths.

5. **Given** all wrapper scripts, **when** `file public/*/bin/*` is run, **then** every bash file is executable (`chmod +x`) and every Windows wrapper has a `.cmd` extension.

6. **Given** portable binaries in `<repo-root>/tools/`, **when** a wrapper script is invoked, **then** it discovers and uses the portable binary without requiring PATH modifications.

7. **Given** `OFFICE_SKILLS_UV` or `OFFICE_SKILLS_DENO` is set, **when** a wrapper script is invoked, **then** the environment variable takes precedence over `tools/` and PATH.

## Verification

| Criterion | Evidence | Result |
|-----------|----------|--------|

## Scope & Constraints

**Wrapper inventory:**

### pptx/bin/
| Wrapper | Wraps | Runtime |
|---------|-------|---------|
| `thumbnail` | `scripts/thumbnail.py` | `uv run` |
| `inventory` | `scripts/inventory.py` | `uv run` |
| `replace` | `scripts/replace.py` | `uv run` |
| `rearrange` | `scripts/rearrange.py` | `uv run` |
| `unpack` | `ooxml/scripts/unpack.py` | `uv run` |
| `validate` | `ooxml/scripts/validate.py` | `uv run` |
| `pack` | `ooxml/scripts/pack.py` | `uv run` |
| `html2pptx` | `scripts/html2pptx.js` | `deno run` |
| `markitdown` | `markitdown` CLI | `uvx` |

### docx/bin/
| Wrapper | Wraps | Runtime |
|---------|-------|---------|
| `unpack` | `ooxml/scripts/unpack.py` | `uv run` |
| `validate` | `ooxml/scripts/validate.py` | `uv run` |
| `pack` | `ooxml/scripts/pack.py` | `uv run` |
| `extract-text` | `pandoc` text extraction | `uv run` (pypandoc-binary) |
| `markitdown` | `markitdown` CLI | `uvx` |

### pdf/bin/
| Wrapper | Wraps | Runtime |
|---------|-------|---------|
| `to-images` | `scripts/convert_pdf_to_images.py` | `uv run` |
| `fill-form` | `scripts/fill_pdf_form_with_annotations.py` | `uv run` |
| `fill-fields` | `scripts/fill_fillable_fields.py` | `uv run` |
| `check-fields` | `scripts/check_fillable_fields.py` | `uv run` |
| `extract-fields` | `scripts/extract_form_field_info.py` | `uv run` |
| `check-bounds` | `scripts/check_bounding_boxes.py` | `uv run` |
| `validate-image` | `scripts/create_validation_image.py` | `uv run` |

### xlsx/bin/
| Wrapper | Wraps | Runtime |
|---------|-------|---------|
| `recalc` | `recalc.py` (if exists) | `uv run` (soffice) |

**Out of scope:**
- Adding new functionality to scripts
- Changing script arguments or output format
- Creating a package manager or dependency resolver
- Installing tools (handled by SPEC-006 install skill)

## Implementation Approach

1. Create `bin/` directory in each skill under `public/`.
2. Write bash wrappers with tool discovery (env var → `tools/` → PATH).
3. Write matching `.cmd` wrappers for Windows with the same discovery logic.
4. `chmod +x` all bash wrappers.
5. Verify each wrapper works end-to-end (both with tools on PATH and with portable `tools/` binaries).
6. Update SKILL.md files to reference wrappers (done in SPEC-005).

## Lifecycle

| Phase | Date | Commit | Notes |
|-------|------|--------|-------|
| Active | 2026-03-30 | — | Initial creation |
