#!/usr/bin/env bash

koopa_linux_locate_bcbio() {
    koopa_locate_app \
        --app-name='bcbio-nextgen' \
        --bin-name='bcbio-nextgen.py' \
        "$@"
}
