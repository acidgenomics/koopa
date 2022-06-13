#!/usr/bin/env bash

koopa_install_asdf() {
    koopa_install_app \
        --link-in-bin='bin/asdf' \
        --name='asdf' \
        "$@"
}
