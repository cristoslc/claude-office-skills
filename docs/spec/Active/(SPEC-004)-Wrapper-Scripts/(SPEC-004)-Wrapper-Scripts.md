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
addresses: []
evidence-pool: ""
source-issue: ""
swain-do: required
---

# Wrapper Scripts (Skill Bin API)

## Problem Statement

After SPEC-001/002/003, scripts run via `uv run --with pkg1 --with pkg2 public/pptx/scripts/thumbnail.py` or `deno run --allow-all public/pptx/scripts/html2pptx.js`. These invocations are long, error-prone, and force agents to construct runtime-specific command lines. A `bin/` directory per skill with simple wrapper scripts provides a stable, agent-friendly API: `public/pptx/bin/thumbnail input.pptx output/`.

## Desired Outcomes

Each skill has a `bin/` directory containing short shell scripts that wrap the underlying Python/Deno/system tool invocations. SKILL.md files reference these wrappers as the canonical way to invoke functionality. Agents never need to know about `uv run --with`, `deno run --allow-all`, or PEP 723 metadata — they just call the wrapper.

## External Behavior

**Convention:** `public/<skill>/bin/<command>` — executable shell scripts that:
1. Resolve their own directory to find the underlying script
2. Invoke `uv run` or `deno run` with the correct flags
3. Pass through all arguments
4. Use `#!/usr/bin/env bash` shebang

**Example — `public/pptx/bin/thumbnail`:**
```bash
#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
exec uv run "$SCRIPT_DIR/scripts/thumbnail.py" "$@"
```

The PEP 723 metadata in `thumbnail.py` declares its own deps — the wrapper just calls `uv run` and the script handles the rest.

**Example — `public/pptx/bin/html2pptx`:**
```bash
#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
exec deno run --allow-all "$SCRIPT_DIR/scripts/html2pptx.js" "$@"
```

**Example — `public/pptx/bin/markitdown`:**
```bash
#!/usr/bin/env bash
set -euo pipefail
exec uvx markitdown "$@"
```

## Acceptance Criteria

1. **Given** each skill directory (`pptx`, `docx`, `pdf`, `xlsx`), **when** listing `bin/`, **then** every script referenced in that skill's SKILL.md has a corresponding wrapper.

2. **Given** any wrapper script, **when** run with `--help` or no args, **then** it passes through to the underlying script's usage message (no wrapper-specific help needed).

3. **Given** a wrapper script, **when** inspected, **then** it is under 10 lines, uses `exec` to replace the shell process, and does not hardcode absolute paths.

4. **Given** the wrapper convention, **when** an agent reads SKILL.md, **then** all invocation examples use `public/<skill>/bin/<command>` paths.

5. **Given** all wrapper scripts, **when** `file public/*/bin/*` is run, **then** every file is executable (`chmod +x`).

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

## Implementation Approach

1. Create `bin/` directory in each skill under `public/`.
2. Write wrapper scripts — each is a 4-6 line bash script using `exec`.
3. `chmod +x` all wrappers.
4. Verify each wrapper works end-to-end.
5. Update SKILL.md files to reference wrappers (done in SPEC-005).

## Lifecycle

| Phase | Date | Commit | Notes |
|-------|------|--------|-------|
| Active | 2026-03-30 | — | Initial creation |
