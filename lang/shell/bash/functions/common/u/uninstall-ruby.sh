#!/usr/bin/env bash

koopa_uninstall_ruby() {
    koopa_uninstall_app \
        --name='ruby' \
        --unlink-in-bin='bundle' \
        --unlink-in-bin='bundler' \
        --unlink-in-bin='gem' \
        --unlink-in-bin='ruby' \
        "$@"
}
