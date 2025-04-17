#!/usr/bin/env bash

koopa_install_mutagen() {
    koopa_install_app \
        --installer='python-package' \
        --name='mutagen' \
        -D --extra-package='tqdm' \
        "$@"
}
