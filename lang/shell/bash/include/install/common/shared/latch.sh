#!/usr/bin/env bash

main() {
    koopa_install_app_subshell \
        --installer='python-venv' \
        --name='latch' \
        -D --python="$(koopa_locate_python310)" \
        "$@"
}
