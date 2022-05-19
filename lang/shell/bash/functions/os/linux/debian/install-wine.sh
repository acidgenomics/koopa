#!/usr/bin/env bash

koopa_debian_install_wine() {
    koopa_install_app \
        --name-fancy='Wine' \
        --name='wine' \
        --platform='debian' \
        --system \
        "$@"
}
