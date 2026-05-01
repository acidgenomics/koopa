#!/usr/bin/env bash

_koopa_install_mutagen() {
    _koopa_install_app \
        --installer='python-package' \
        --name='mutagen' \
        -D --extra-package='tqdm' \
        "$@"
}
