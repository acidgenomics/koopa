# Activate starship cross-shell prompt.
# @note Updated 2026-05-01.
function _koopa_activate_starship {
    $starship = Join-Path $env:KOOPA_PREFIX 'bin/starship'
    if (-not (Test-Path $starship)) { return }
    Invoke-Expression (& $starship init powershell)
}
