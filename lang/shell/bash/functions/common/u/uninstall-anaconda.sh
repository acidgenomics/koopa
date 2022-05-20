#!/usr/bin/env bash

koopa_uninstall_anaconda() {
    koopa_uninstall_app \
        --name-fancy='Anaconda' \
        --name='anaconda' \
        "$@"
}
