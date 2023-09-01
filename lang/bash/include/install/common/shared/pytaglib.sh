#!/usr/bin/env bash

main() {
    koopa_activate_app 'taglib'
    koopa_install_python_package \
        --extra-package='tqdm' \
        --no-binary
    return 0
}
