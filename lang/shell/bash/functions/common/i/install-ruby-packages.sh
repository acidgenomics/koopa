#!/usr/bin/env bash

koopa_install_ruby_packages() {
    koopa_install_app_packages \
        --link-in-bin='bin/bashcov' \
        --link-in-bin='bin/bundle' \
        --link-in-bin='bin/bundler' \
        --link-in-bin='bin/colorls' \
        --link-in-bin='bin/ronn' \
        --name-fancy='Ruby' \
        --name='ruby' \
        "$@"
}
