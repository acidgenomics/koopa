#!/usr/bin/env bash

# FIXME Need to downgrade this to Python 3.10.8, due to numpy==1.21.3 pinning.

main() {
    koopa_install_app_subshell \
        --installer='python-venv' \
        --name='latch' \
        "$@"
}
