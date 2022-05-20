#!/usr/bin/env bash

koopa_uninstall_ranger_fm() {
    koopa_uninstall_app \
        --name='ranger-fm' \
        --unlink-in-bin='ranger' \
        "$@"
}
