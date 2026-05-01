#!/usr/bin/env bash

_koopa_install_bandit() {
    _koopa_install_app \
        --installer='python-package' \
        --name='bandit' \
        "$@"
}
