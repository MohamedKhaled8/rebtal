
$path = "e:\Mt FlutterProject\rebtal\lib\l10n\app_ar.arb"
$enPath = "e:\Mt FlutterProject\rebtal\lib\l10n\app_en.arb"

$ar = Get-Content $path -Raw | ConvertFrom-Json
$en = Get-Content $enPath -Raw | ConvertFrom-Json

# Add missing keys from EN to AR (with placeholder or translation)
foreach ($key in $en.PSObject.Properties.Name) {
    if (-not $ar.PSObject.Properties.$key) {
        $ar | Add-Member -MemberType NoteProperty -Name $key -Value $en.$key
    }
}

# Add locale
if (-not $ar.PSObject.Properties."@@locale") {
    $ar | Add-Member -MemberType NoteProperty -Name "@@locale" -Value "ar"
}

# Save back as pretty JSON
$ar | ConvertTo-Json -Depth 10 | Set-Content $path
