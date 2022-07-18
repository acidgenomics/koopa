#!/usr/bin/env bash

koopa_install_lame() {
    koopa_install_app \
        --link-in-bin='lame' \
        --name='lame' \
        "$@"
}
