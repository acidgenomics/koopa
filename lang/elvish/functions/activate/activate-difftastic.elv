# Activate difftastic.
# @note Updated 2026-05-31.
fn activate-difftastic {
    var difft = $E:KOOPA_PREFIX'/bin/difft'
    if (not (path:is-regular &follow-symlink $difft)) {
        return
    }
    set-env DFT_BACKGROUND $E:KOOPA_COLOR_MODE
    set-env DFT_DISPLAY 'side-by-side'
}
