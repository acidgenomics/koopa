function _koopa_activate_fzf
    # Activate fzf, command-line fuzzy finder.
    # @note Updated 2026-05-31.
    test -x "$KOOPA_PREFIX/bin/fzf"; or return 0
    if not set -q FZF_DEFAULT_OPTS
        set -gx FZF_DEFAULT_OPTS "--border --color $KOOPA_COLOR_MODE --multi"
    end
end
