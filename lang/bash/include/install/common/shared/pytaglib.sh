#!/usr/bin/env bash

main() {
    _koopa_activate_app 'taglib'
    _koopa_install_python_package \
        --extra-package='tqdm' \
        --no-binary
    return 0
}
