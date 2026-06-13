# Activate koopa-managed PowerShell completions.
# @note Updated 2026-06-13.
function _koopa_activate_completions {
    $dir = Join-Path $env:KOOPA_PREFIX 'share/powershell/completions'
    if (-not (Test-Path $dir)) { return }
    Get-ChildItem -Path $dir -Filter '*.ps1' -ErrorAction SilentlyContinue | ForEach-Object {
        . $_.FullName
    }
}
