#!/usr/bin/env bash

_koopa_install_shyaml() {
    _koopa_install_app \
        --installer='python-package' \
        --name='shyaml' \
        "$@"
}
