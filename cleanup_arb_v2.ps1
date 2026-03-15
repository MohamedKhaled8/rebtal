
$path = "e:\Mt FlutterProject\rebtal\lib\l10n\app_ar.arb"
$raw = Get-Content $path -Raw
$json = $raw | ConvertFrom-Json
$json | ConvertTo-Json -Depth 10 | Set-Content $path
