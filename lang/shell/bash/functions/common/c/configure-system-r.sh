#!/usr/bin/env bash

koopa_configure_system_r() {
    local app
    declare -A app
    app['r']="$(koopa_locate_system_r)"
    [[ -x "${app['r']}" ]] || return 1
    koopa_configure_r "${app['r']}"
    return 0
}
