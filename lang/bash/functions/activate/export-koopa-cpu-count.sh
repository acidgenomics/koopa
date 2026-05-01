#!/usr/bin/env bash

_koopa_export_koopa_cpu_count() {
    KOOPA_CPU_COUNT="$(_koopa_cpu_count)"
    export KOOPA_CPU_COUNT
    return 0
}
