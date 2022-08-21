#!/usr/bin/env bash

koopa_locate_rscript() {
    local app
    declare -A app=(
        [r]="$(koopa_locate_r)"
    )
    [[ -x "${app['r']}" ]] || return 1
    app[rscript]="${app['r']}script"
    koopa_locate_app "${app['rscript']}"
}
