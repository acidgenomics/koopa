#!/usr/bin/env bash

koopa_configure_system_r() {
    local -A app
    app['r']="$(koopa_locate_system_r)"
    [[ -x "${app['r']}" ]] || exit 1
    koopa_configure_r "${app['r']}"
    return 0
}
