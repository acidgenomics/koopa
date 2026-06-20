# Activate pyright.
# @note Updated 2026-06-13.
function _koopa_activate_pyright {
    $pyright = Join-Path $env:KOOPA_PREFIX 'bin/pyright'
    if (-not (Test-Path $pyright)) { return }
    $env:PYRIGHT_PYTHON_FORCE_VERSION = 'latest'
}
