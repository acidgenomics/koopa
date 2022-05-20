#!/usr/bin/env bash

koopa_debian_install_rstudio_server() {
    koopa_install_app \
        --name-fancy='RStudio Server' \
        --name='rstudio-server' \
        --platform='debian' \
        --system \
        "$@"
}
