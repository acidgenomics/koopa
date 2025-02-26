#!/usr/bin/env bash

main() {
    koopa_install_python_package \
        --pip-name='huggingface_hub[cli]'
    return 0
}
