#!/usr/bin/env bash

koopa_fedora_install_system_rstudio_server() {
    koopa_install_app \
        --name='rstudio-server' \
        --platform='fedora' \
        --system \
        "$@"
}
