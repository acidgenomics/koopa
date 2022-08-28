#!/usr/bin/env bash

koopa_locate_rscript() {
    koopa_locate_app \
        --app-name='r' \
        --bin-name='Rscript' \
        "$@"
}
