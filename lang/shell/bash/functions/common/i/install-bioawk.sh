#!/usr/bin/env bash

koopa_install_bioawk() {
    koopa_install_app \
        --link-in-bin='bioawk' \
        --name='bioawk' \
        "$@"
}
