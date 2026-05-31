function _koopa_activate_difftastic
    # Activate difftastic.
    # @note Updated 2026-05-31.
    test -x "$KOOPA_PREFIX/bin/difft"; or return 0
    set -gx DFT_BACKGROUND "$KOOPA_COLOR_MODE"
    set -gx DFT_DISPLAY side-by-side
end
