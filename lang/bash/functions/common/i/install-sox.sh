#!/usr/bin/env bash

# FIXME This isn't linking 'sox.1' into man correctly currently.

koopa_install_sox() {
    koopa_install_app \
        --installer='conda-package' \
        --name='sox' \
        "$@"
}
