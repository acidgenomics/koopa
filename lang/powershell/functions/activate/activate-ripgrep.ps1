# Activate ripgrep.
# @note Updated 2026-06-13.
function _koopa_activate_ripgrep {
    $rg = Join-Path $env:KOOPA_PREFIX 'bin/rg'
    if (-not (Test-Path $rg)) { return }
    $configFile = Join-Path $env:XDG_CONFIG_HOME 'ripgrep/config'
    if (Test-Path $configFile) {
        $env:RIPGREP_CONFIG_PATH = $configFile
    }
}
