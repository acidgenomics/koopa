# Activate tealdeer (tldr).
# @note Updated 2026-06-13.
function _koopa_activate_tealdeer {
    $tldr = Join-Path $env:KOOPA_PREFIX 'bin/tldr'
    if (-not (Test-Path $tldr)) { return }
    if (-not $env:TEALDEER_CONFIG_DIR) {
        $env:TEALDEER_CONFIG_DIR = Join-Path $env:XDG_CONFIG_HOME 'tealdeer'
    }
}
