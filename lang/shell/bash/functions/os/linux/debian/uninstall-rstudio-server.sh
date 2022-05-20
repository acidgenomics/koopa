#!/usr/bin/env bash

koopa_debian_uninstall_rstudio_server() {
    koopa_uninstall_app \
        --name-fancy='RStudio Server' \
        --name='rstudio-server' \
        --platform='debian' \
        --system \
        "$@"
}
