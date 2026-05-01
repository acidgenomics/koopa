function _koopa_activate_direnv
    # Activate direnv.
    # @note Updated 2026-05-01.
    set -l direnv (_koopa_bin_prefix)/direnv
    if not test -x "$direnv"
        return 0
    end
    set -e DIRENV_DIFF
    set -e DIRENV_DIR
    set -e DIRENV_FILE
    set -e DIRENV_WATCHES
    eval ($direnv hook fish)
    eval ($direnv export fish)
end
