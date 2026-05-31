# Activate difftastic.
# @note Updated 2026-05-31.
export def _koopa_activate_difftastic [] {
    let difft = $"($env.KOOPA_PREFIX)/bin/difft"
    if not ($difft | path exists) {
        return
    }
    $env.DFT_BACKGROUND = $env.KOOPA_COLOR_MODE
    $env.DFT_DISPLAY = "side-by-side"
}
