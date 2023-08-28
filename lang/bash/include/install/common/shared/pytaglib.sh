#!/usr/bin/env bash

main() {
    koopa_activate_app 'taglib'
    koopa_install_app_subshell \
        --installer='python-package' \
        --name='pytaglib' \
        -D '--no-binary' \
        -D 'tqdm'
}
