# Activate pyright.
# @note Updated 2026-09-04.
function _koopa_activate_pyright {
    $pyright = Join-Path $env:KOOPA_PREFIX 'bin/pyright'
    if (-not (Test-Path $pyright)) { return }
    $env:PYRIGHT_PYTHON_IGNORE_WARNINGS = '1'
}
