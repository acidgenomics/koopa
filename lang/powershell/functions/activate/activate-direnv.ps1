# Activate direnv.
# @note Updated 2026-05-12.
function _koopa_activate_direnv {
    $direnv = Join-Path $env:KOOPA_PREFIX 'bin/direnv'
    if (-not (Test-Path $direnv)) { return }
    Invoke-Expression (& $direnv hook pwsh)
}
