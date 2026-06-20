function _koopa_activate_tealdeer
    # Activate tealdeer (tldr).
    # @note Updated 2026-06-13.
    test -x "$KOOPA_PREFIX/bin/tldr"; or return 0
    if not set -q TEALDEER_CONFIG_DIR
        set -gx TEALDEER_CONFIG_DIR "$XDG_CONFIG_HOME/tealdeer"
    end
end
