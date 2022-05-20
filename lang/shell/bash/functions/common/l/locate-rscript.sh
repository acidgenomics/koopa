#!/usr/bin/env bash

koopa_locate_rscript() {
    local app
    declare -A app=(
        [r]="$(koopa_locate_r)"
    )
    app[rscript]="${app[r]}script"
    koopa_locate_app "${app[rscript]}"
}
