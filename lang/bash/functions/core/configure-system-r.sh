#!/usr/bin/env bash

_koopa_configure_system_r() {
    local -A app
    app['r']="$(_koopa_locate_system_r)"
    _koopa_assert_is_executable "${app[@]}"
    _koopa_configure_r "${app['r']}"
    return 0
}
