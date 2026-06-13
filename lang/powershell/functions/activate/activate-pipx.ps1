# Activate pipx.
# @note Updated 2026-06-13.
function _koopa_activate_pipx {
    $pipx = Join-Path $env:KOOPA_PREFIX 'bin/pipx'
    if (-not (Test-Path $pipx)) { return }
    $prefix = Join-Path $env:XDG_DATA_HOME 'pipx'
    if (-not (Test-Path $prefix -PathType Container)) {
        New-Item -ItemType Directory -Path $prefix -Force | Out-Null
    }
    _koopa_add_to_path_start (Join-Path $prefix 'bin')
    $env:PIPX_HOME = $prefix
    $env:PIPX_BIN_DIR = Join-Path $prefix 'bin'
}
