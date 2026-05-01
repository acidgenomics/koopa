#!/usr/bin/env bash

_koopa_install_sqlfluff() {
    _koopa_install_app \
        --installer='python-package' \
        --name='sqlfluff' \
        "$@"
}
