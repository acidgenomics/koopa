#!/usr/bin/env bash

koopa_install_gperf() {
    koopa_install_app \
        --installer='gnu-app' \
        --name='gperf' \
        "$@"
}
