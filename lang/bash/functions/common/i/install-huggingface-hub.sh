#!/usr/bin/env bash

koopa_install_huggingface_hub() {
    koopa_install_app \
        --installer='python-package' \
        --name='huggingface-hub' \
        -D --egg-name='huggingface_hub' \
        -D --pip-name='huggingface_hub[cli]' \
        "$@"
}
