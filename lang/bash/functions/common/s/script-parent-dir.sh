#!/usr/bin/env bash

koopa_script_parent_dir() {
    # """
    # Parent directory of the invoked bash script.
    # @note Updated 2023-12-05.
    #
    # @seealso
    # - https://stackoverflow.com/questions/20196034/
    # """
    local script
    koopa_assert_has_no_args "$#"
    script="$(koopa_script_source)"
    [[ -f "$script" ]] || return 1
    koopa_parent_dir "$script"
    return 0
}
