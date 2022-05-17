#!/usr/bin/env bash

koopa_uninstall_chemacs() {
    koopa_uninstall_app \
        --name-fancy='Chemacs' \
        --name='chemacs' \
        "$@"
}
