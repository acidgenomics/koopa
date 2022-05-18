#!/usr/bin/env bash

koopa_uninstall_meson() {
    koopa_uninstall_app \
        --name-fancy='Meson' \
        --name='meson' \
        "$@"
}
