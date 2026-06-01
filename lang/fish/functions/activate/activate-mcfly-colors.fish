function _koopa_activate_mcfly_colors
    # Activate mcfly color mode.
    # @note Updated 2026-05-31.
    if test "$KOOPA_COLOR_MODE" = light; and begin
            not set -q TMUX; or test "$OSTYPE" = darwin
        end
        set -gx MCFLY_LIGHT true
    else
        set -e MCFLY_LIGHT
    end
end
