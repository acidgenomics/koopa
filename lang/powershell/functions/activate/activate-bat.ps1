# Activate bat.
# @note Updated 2026-06-13.
function _koopa_activate_bat {
    $bat = Join-Path $env:KOOPA_PREFIX 'bin/bat'
    if (-not (Test-Path $bat)) { return }
    $prefix = Join-Path $env:XDG_CONFIG_HOME 'bat'
    if (-not (Test-Path $prefix -PathType Container)) { return }
    $confFile = Join-Path $prefix 'config'
    if (-not (Test-Path $confFile)) { return }
    $env:BAT_CONFIG_PATH = $confFile
}
