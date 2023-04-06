#!/usr/bin/env bash

# FIXME Not currently building on macOS Intel.

main() {
    koopa_install_app_subshell \
        --installer='python-venv' \
        --name='ont-bonito' \
        "$@"
}
