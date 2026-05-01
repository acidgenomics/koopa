#!/usr/bin/env bash

_koopa_is_powerful_machine() {
    # """
    # Is the current machine powerful?
    # @note Updated 2021-11-05.
    # """
    local cores
    _koopa_assert_has_no_args "$#"
    cores="$(_koopa_cpu_count)"
    [[ "$cores" -ge 7 ]] && return 0
    return 1
}
