function _koopa_activate_ripgrep
    # Activate ripgrep.
    # @note Updated 2026-06-13.
    test -x "$KOOPA_PREFIX/bin/rg"; or return 0
    set -l config_file "$XDG_CONFIG_HOME/ripgrep/config"
    if test -f "$config_file"
        set -gx RIPGREP_CONFIG_PATH "$config_file"
    end
end
