#!/usr/bin/env bash

koopa_install_sqlfluff() {
    koopa_install_app \
        --installer='python-package' \
        --name='sqlfluff' \
        "$@"
}
