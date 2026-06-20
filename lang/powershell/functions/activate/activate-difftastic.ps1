# Activate difftastic.
# @note Updated 2026-05-31.
function _koopa_activate_difftastic {
    $difft = Join-Path $env:KOOPA_PREFIX 'bin/difft'
    if (-not (Test-Path $difft)) { return }
    $env:DFT_BACKGROUND = $env:KOOPA_COLOR_MODE
    $env:DFT_DISPLAY = 'side-by-side'
}
