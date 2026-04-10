$env:DENO_TLS_CA_STORE = "system"

$skillRoot = "__SKILL_ROOT_PLACEHOLDER__"

& "$skillRoot\tools\deno.exe" `
  --config "$skillRoot\deno.json" `
  --node-modules-dir="$skillRoot" `
  @args