#!/usr/bin/env bash

koopa_fedora_uninstall_system_rstudio_server() {
    koopa_uninstall_app \
        --name='rstudio-server' \
        --platform='fedora' \
        --system \
        "$@"
}
