#!/usr/bin/env bash

koopa_install_ruby() {
    koopa_install_app \
        --link-in-bin='bin/bundle' \
        --link-in-bin='bin/bundler' \
        --link-in-bin='bin/gem' \
        --link-in-bin='bin/ruby' \
        --name-fancy='Ruby' \
        --name='ruby' \
        "$@"
}
