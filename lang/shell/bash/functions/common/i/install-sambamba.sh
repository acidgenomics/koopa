#!/usr/bin/env bash

koopa_install_sambamba() {
    koopa_install_app \
        --installer='conda-env' \
        --link-in-bin='sambamba' \
        --name='sambamba' \
        "$@"
}
