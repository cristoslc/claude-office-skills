---
title: "Wrapper Scripts as Skill API"
artifact: ADR-002
track: standing
status: Active
author: operator
created: 2026-03-30
last-updated: 2026-03-30
linked-artifacts:
  - VISION-001
  - EPIC-001
  - SPEC-004
  - PERSONA-002
depends-on-artifacts:
  - ADR-001
evidence-pool: ""
---

# Wrapper Scripts as Skill API

## Context

After adopting the run-first strategy (ADR-001), scripts are invoked via runtime-specific commands: `uv run public/pptx/scripts/thumbnail.py`, `deno run --allow-all public/pptx/scripts/html2pptx.js`, `uvx markitdown`. These invocations are:

- **Long and error-prone** — agents construct multi-flag commands that are easy to get wrong
- **Runtime-coupled** — SKILL.md instructions leak implementation details (which tool uses uv vs deno vs uvx)
- **Fragile** — if we later change a script's runtime (e.g., rewrite a Python script in JS), every reference breaks

PERSONA-002 (the Claude Agent) needs a stable, simple interface. The agent reads SKILL.md, finds a command, and runs it. The command should be the same regardless of what runtime powers it underneath.

## Decision

**Each skill has a `bin/` directory containing short shell wrapper scripts.** These wrappers are the canonical API — SKILL.md files reference them, agents call them, and the underlying runtime is an implementation detail.

Convention: `public/<skill>/bin/<command>`

Each wrapper is a 4-6 line bash script that:
1. Uses `#!/usr/bin/env bash` and `set -euo pipefail`
2. Resolves its own location to find the underlying script (via `SCRIPT_DIR`)
3. Calls `exec uv run`, `exec deno run --allow-all`, or `exec uvx` as appropriate
4. Passes through all arguments via `"$@"`

Example:
```bash
#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
exec uv run "$SCRIPT_DIR/scripts/thumbnail.py" "$@"
```

The PEP 723 metadata in `thumbnail.py` declares dependencies — the wrapper doesn't need to know or repeat them.

**Naming convention:** wrapper names are short, action-oriented, and match the operation (not the script filename). Examples: `thumbnail`, `inventory`, `replace`, `unpack`, `validate`, `pack`, `to-images`, `fill-form`, `markitdown`, `html2pptx`.

## Alternatives Considered

**Document raw commands in SKILL.md.** Status quo approach. Agents copy-paste long `uv run --with pkg1 --with pkg2 ...` commands. Rejected because it couples SKILL.md to runtime details and makes commands error-prone for agents.

**Makefile targets.** `make thumbnail INPUT=foo.pptx OUTPUT=bar/`. Familiar pattern but adds Make as a dependency, requires parsing Makefile syntax, and make's argument passing is awkward. Rejected.

**Python CLI package with entry points.** Package all scripts into one installable Python package with console_script entry points. Contradicts ADR-001 (no install step) and requires publishing/versioning overhead. Rejected.

**Shell aliases defined in SKILL.md.** Document aliases that the agent should `eval` at session start. Fragile, stateful, and agents handle shell state poorly. Rejected.

## Consequences

**Positive:**
- Agents call `public/pptx/bin/thumbnail input.pptx output/` — short, readable, memorable
- Runtime is an implementation detail: swapping a Python script for a Deno script only changes the wrapper, not SKILL.md
- Wrappers are trivial to audit (4-6 lines each, all follow the same pattern)
- Works with any agent that can run shell commands — no runtime-specific knowledge needed

**Accepted downsides:**
- One more layer of indirection (wrapper → runtime → script)
- Wrapper scripts must be kept in sync with the scripts they wrap (new script = new wrapper)
- `bin/` directories add files to the repo, though each file is tiny

## Lifecycle

| Phase | Date | Commit | Notes |
|-------|------|--------|-------|
| Active | 2026-03-30 | — | Initial creation |
