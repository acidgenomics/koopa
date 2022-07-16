#!/usr/bin/env bash

koopa_install_ruby() {
    koopa_install_app \
        --link-in-bin='bundle' \
        --link-in-bin='bundler' \
        --link-in-bin='gem' \
        --link-in-bin='ruby' \
        --name='ruby' \
        "$@"
}
