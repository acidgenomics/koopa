#!/usr/bin/env bash

koopa_install_shyaml() {
    koopa_install_app \
        --installer='python-package' \
        --name='shyaml' \
        "$@"
}
