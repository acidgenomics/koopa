#!/usr/bin/env bash

_koopa_debian_uninstall_system_rstudio_server() {
    _koopa_uninstall_app \
        --name='rstudio-server' \
        --platform='debian' \
        --system \
        "$@"
}
