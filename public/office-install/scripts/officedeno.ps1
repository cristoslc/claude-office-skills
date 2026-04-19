# officedeno.ps1 — Runs deno with the office-skills import map.
# Resolves --config to the installed deno.json so npm specifiers resolve.
# Usage: officedeno.ps1 <deno-subcommand> [args]

$skillRoot = "__SKILL_ROOT_PLACEHOLDER__"

$env:DENO_TLS_CA_STORE = "system"
$env:DENO_NODE_MODULES_DIR = $skillRoot

& "$skillRoot\tools\deno.exe" `
  --config "$skillRoot\deno.json" `
  --node-modules-dir `
  @args
