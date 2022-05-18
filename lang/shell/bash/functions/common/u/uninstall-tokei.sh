#!/usr/bin/env bash

koopa_uninstall_tokei() {
    koopa_uninstall_app \
        --unlink-in-bin='tokei' \
        --name='tokei' \
        "$@"
}
