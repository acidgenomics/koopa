#!/usr/bin/env bash

koopa_is_powerful_machine() {
    # """
    # Is the current machine powerful?
    # @note Updated 2021-11-05.
    # """
    local cores
    koopa_assert_has_no_args "$#"
    cores="$(koopa_cpu_count)"
    [[ "$cores" -ge 7 ]] && return 0
    return 1
}
