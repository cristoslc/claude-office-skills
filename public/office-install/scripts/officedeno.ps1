$env:DENO_TLS_CA_STORE = "system"
$env:DENO_NODE_MODULES_DIR = "__SKILL_ROOT_PLACEHOLDER__"

$skillRoot = "__SKILL_ROOT_PLACEHOLDER__"

& "$skillRoot\tools\deno.exe" `
  --config "$skillRoot\deno.json" `
  --node-modules-dir `
  @args