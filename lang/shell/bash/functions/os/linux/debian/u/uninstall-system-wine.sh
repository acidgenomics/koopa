#!/usr/bin/env bash

koopa_debian_uninstall_system_wine() {
    koopa_uninstall_app \
        --name='wine' \
        --platform='debian' \
        --system \
        "$@"
}
