# Activate zoxide.
# @note Updated 2026-05-01.
function _koopa_activate_zoxide {
    $zoxide = Join-Path $env:KOOPA_PREFIX 'bin/zoxide'
    if (-not (Test-Path $zoxide)) { return }
    Invoke-Expression (& $zoxide init powershell)
}
