#!/usr/bin/env bash

koopa_linux_configure_system_rstudio_server() {
    koopa_configure_app \
        --name='rstudio-server' \
        --platform='linux' \
        --system \
        "$@"
}
