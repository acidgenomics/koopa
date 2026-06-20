function _koopa_activate_bat
    # Activate bat.
    # @note Updated 2026-06-13.
    test -x "$KOOPA_PREFIX/bin/bat"; or return 0
    set -l prefix "$XDG_CONFIG_HOME/bat"
    if not test -d "$prefix"
        return 0
    end
    set -l conf_file "$prefix/config"
    if not test -f "$conf_file"
        return 0
    end
    set -gx BAT_CONFIG_PATH "$conf_file"
end
