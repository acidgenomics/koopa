#!/usr/bin/env bash

koopa_uninstall_lame() {
    koopa_uninstall_app \
        --name-fancy='LAME' \
        --name='lame' \
        --unlink-in-bin='lame' \
        "$@"
}
