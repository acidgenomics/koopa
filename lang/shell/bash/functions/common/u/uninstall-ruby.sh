#!/usr/bin/env bash

koopa_uninstall_ruby() {
    koopa_uninstall_app \
        --name-fancy='Ruby' \
        --name='ruby' \
        --unlink-in-bin='gem' \
        --unlink-in-bin='ruby' \
        "$@"
}
