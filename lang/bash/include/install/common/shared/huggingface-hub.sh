#!/usr/bin/env bash

main() {
    koopa_install_python_package \
        --egg-name='huggingface_hub' \
        --pip-name='huggingface_hub[cli]'
    return 0
}
