#!/usr/bin/env bash

koopa_uninstall_ruby_packages() {
    koopa_uninstall_app \
        --name-fancy='Ruby packages' \
        --name='ruby-packages' \
        --unlink-in-bin='bashcov' \
        --unlink-in-bin='bundle' \
        --unlink-in-bin='bundler' \
        --unlink-in-bin='colorls' \
        --unlink-in-bin='ronn' \
        "$@"
}
