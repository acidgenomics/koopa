#!/usr/bin/env bash

_koopa_install_system_tex_packages() {
    _koopa_install_app \
        --name='tex-packages' \
        --system \
        "$@"
}
