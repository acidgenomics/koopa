#!/usr/bin/env bash

koopa_uninstall_julia() {
    koopa_uninstall_app \
        --name='julia' \
        --unlink-in-bin='julia' \
        "$@"
}
