#!/usr/bin/env bash

koopa_update_tex_packages() {
    koopa_update_app \
        --name-fancy='TeX packages' \
        --name='tex-packages' \
        --system \
        "$@"
}
