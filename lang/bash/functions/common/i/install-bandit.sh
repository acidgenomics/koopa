#!/usr/bin/env bash

koopa_install_bandit() {
    koopa_install_app \
        --installer='python-package' \
        --name='bandit' \
        "$@"
}
