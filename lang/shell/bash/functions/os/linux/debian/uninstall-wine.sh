#!/usr/bin/env bash

koopa_debian_uninstall_wine() {
    koopa_uninstall_app \
        --name-fancy='Wine' \
        --name='wine' \
        --platform='debian' \
        --system \
        "$@"
}
