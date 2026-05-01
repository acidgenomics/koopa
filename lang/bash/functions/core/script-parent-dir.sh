#!/usr/bin/env bash

_koopa_script_parent_dir() {
    # """
    # Parent directory of the invoked bash script.
    # @note Updated 2023-12-05.
    #
    # @seealso
    # - _koopa_script_source
    # - https://stackoverflow.com/questions/20196034/
    # """
    local script
    _koopa_assert_has_no_args "$#"
    script="${BASH_SOURCE[1]}"
    [[ -f "$script" ]] || return 1
    script="$(_koopa_realpath "$script")"
    _koopa_parent_dir "$script"
    return 0
}
