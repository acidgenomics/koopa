#!/usr/bin/env bash

koopa_install_chemacs() {
    koopa_install_app \
        --name='chemacs' \
        --version-is-git-commit \
        "$@"
}
