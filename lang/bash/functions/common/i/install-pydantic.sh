#!/usr/bin/env bash

koopa_install_pydantic() {
    koopa_install_app \
        --installer='python-package' \
        --name='pydantic' \
        "$@"
}
