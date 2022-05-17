#!/usr/bin/env bash

koopa_install_dog() {
    koopa_install_app \
        --link-in-bin='bin/dog' \
        --name='dog' \
        --installer='rust-package' \
        "$@"
}
