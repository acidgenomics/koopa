#!/usr/bin/env bash

main() {
    koopa_install_app_subshell \
        --installer='python-venv' \
        --name='mutagen' \
        -D 'tqdm'
}
