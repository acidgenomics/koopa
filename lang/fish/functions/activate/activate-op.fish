function _koopa_activate_op
    # Activate 1Password CLI ('op') shell plugins.
    # @note Updated 2026-06-13.
    #
    # Sources the POSIX alias definitions written by 'op plugin init <cli>'.
    # koopa never runs 'op plugin init' (interactive, user-specific); it only
    # auto-sources the generated file when present.
    #
    # @seealso
    # - https://developer.1password.com/docs/cli/shell-plugins/
    set -l plugins_file
    if set -q OP_CONFIG_DIR
        set plugins_file "$OP_CONFIG_DIR/plugins.sh"
    else
        set plugins_file "$XDG_CONFIG_HOME/op/plugins.sh"
    end
    test -f "$plugins_file"; or return 0
    source "$plugins_file"
end
