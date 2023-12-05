#!/usr/bin/env bash

koopa_script_source() {
    # """
    # Get the normalized path (realpath) of the invoked bash script.
    # @note Updated 2023-12-05.
    #
    # @details
    # Usage of '${BASH_SOURCE[0]}' will return our function library script,
    # e.g. '/opt/koopa/lang/bash/functions/common.sh'. Here we are using
    # '${BASH_SOURCE[1]}' instead, which is the source of the caller of the
    # current subroutine.
    #
    # 'BASH_SOURCE' is an array variable which holds the source history, where
    # '${BASH_SOURCE[0]}' is the source of the current subroutine call,
    # '${BASH_SOURCE[1]}' is the source of the caller of current subroutine,
    # and so on. If a script is sourced, '${BASH_SOURCE[0]}' will contain the
    # name of the script itself.
    #
    # @seealso
    # - https://tecadmin.net/how-to-identify-a-bash-script-is-sourced-
    #     or-executed-directly/
    # """
    local script
    koopa_assert_has_no_args "$#"
    script="${BASH_SOURCE[1]}"
    [[ -f "$script" ]] || return 1
    koopa_realpath "$script"
    return 0
}
