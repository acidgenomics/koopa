#!/usr/bin/env bash

koopa_which_realpath() {
    # """
    # Locate the realpath of a program.
    # @note Updated 2021-06-03.
    #
    # This resolves symlinks automatically.
    # For 'which' style return, use 'koopa_which' instead.
    #
    # @seealso
    # - https://stackoverflow.com/questions/7665
    # - https://unix.stackexchange.com/questions/85249
    # - https://stackoverflow.com/questions/7522712
    # - https://thoughtbot.com/blog/input-output-redirection-in-the-shell
    #
    # @examples
    # > koopa_which_realpath 'bash' 'vim'
    # """
    local cmd
    koopa_assert_has_args "$#"
    for cmd in "$@"
    do
        cmd="$(koopa_which "$cmd")"
        [[ -n "$cmd" ]] || return 1
        cmd="$(koopa_realpath "$cmd")"
        [[ -x "$cmd" ]] || return 1
        koopa_print "$cmd"
    done
    return 0
}
