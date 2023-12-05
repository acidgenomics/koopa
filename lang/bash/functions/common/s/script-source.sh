#!/usr/bin/env bash

koopa_script_source() {
    # """
    # Get the normalized path (realpath) of the invoked bash script.
    # @note Updated 2023-12-05.
    # """
    local script
    koopa_assert_has_no_args "$#"
    script="${BASH_SOURCE[0]}"
    [[ -f "$script" ]] || return 1
    koopa_realpath "$script"
    return 0
}
