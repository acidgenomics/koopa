function _koopa_activate_pipx
    # Activate pipx.
    # @note Updated 2026-06-13.
    test -x "$KOOPA_PREFIX/bin/pipx"; or return 0
    set -l prefix "$XDG_DATA_HOME/pipx"
    if not test -d "$prefix"
        mkdir -p "$prefix" >/dev/null
    end
    _koopa_add_to_path_start "$prefix/bin"
    set -gx PIPX_HOME "$prefix"
    set -gx PIPX_BIN_DIR "$prefix/bin"
end
