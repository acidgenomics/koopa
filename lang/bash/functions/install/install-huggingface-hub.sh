#!/usr/bin/env bash

_koopa_install_huggingface_hub() {
    _koopa_install_app \
        --installer='python-package' \
        --name='huggingface-hub' \
        -D --egg-name='huggingface_hub' \
        -D --pip-name='huggingface_hub[cli]' \
        "$@"
}
