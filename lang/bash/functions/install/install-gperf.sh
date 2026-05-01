#!/usr/bin/env bash

_koopa_install_gperf() {
    _koopa_install_app \
        --installer='gnu-app' \
        --name='gperf' \
        "$@"
}
