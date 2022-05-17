#!/usr/bin/env bash

koopa_install_cpufetch() {
    koopa_install_app \
        --link-in-bin='bin/cpufetch' \
        --name='cpufetch' \
        "$@"
}
