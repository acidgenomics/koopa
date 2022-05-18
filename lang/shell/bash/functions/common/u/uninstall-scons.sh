#!/usr/bin/env bash

koopa_uninstall_scons() {
    koopa_uninstall_app \
        --name-fancy='SCONS' \
        --name='scons' \
        "$@"
}
