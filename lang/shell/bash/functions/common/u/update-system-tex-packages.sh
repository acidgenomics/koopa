#!/usr/bin/env bash

koopa_update_system_tex_packages() {
    koopa_update_app \
        --name='tex-packages' \
        --system \
        "$@"
}
