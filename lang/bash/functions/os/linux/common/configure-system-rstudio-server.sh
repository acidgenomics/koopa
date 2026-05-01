#!/usr/bin/env bash

_koopa_linux_configure_system_rstudio_server() {
    _koopa_configure_app \
        --name='rstudio-server' \
        --platform='linux' \
        --system \
        "$@"
}
