#!/usr/bin/env bash

_koopa_which_realpath() {
    # """
    # Locate the realpath of a program.
    # @note Updated 2021-06-03.
    #
    # This resolves symlinks automatically.
    # For 'which' style return, use '_koopa_which' instead.
    #
    # @seealso
    # - https://stackoverflow.com/questions/7665
    # - https://unix.stackexchange.com/questions/85249
    # - https://stackoverflow.com/questions/7522712
    # - https://thoughtbot.com/blog/input-output-redirection-in-the-shell
    #
    # @examples
    # > _koopa_which_realpath 'bash' 'vim'
    # """
    local cmd
    _koopa_assert_has_args "$#"
    for cmd in "$@"
    do
        cmd="$(_koopa_which "$cmd")"
        [[ -n "$cmd" ]] || return 1
        cmd="$(_koopa_realpath "$cmd")"
        [[ -x "$cmd" ]] || return 1
        _koopa_print "$cmd"
    done
    return 0
}
