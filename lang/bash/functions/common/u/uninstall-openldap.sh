#!/usr/bin/env bash

koopa_uninstall_openldap() {
    koopa_uninstall_app \
        --name='openldap' \
        "$@"
}
