#!/bin/sh

_koopa_export_koopa_cpu_count() {
    # """
    # Export 'KOOPA_CPU_COUNT' variable.
    # @note Updated 2022-07-28.
    # """
    KOOPA_CPU_COUNT="$(_koopa_cpu_count)"
    export KOOPA_CPU_COUNT
    return 0
}
