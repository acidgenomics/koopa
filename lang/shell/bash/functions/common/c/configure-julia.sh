#!/usr/bin/env bash

# FIXME Rework to not configure at '/opt/koopa/opt/julia-packages'.

koopa_configure_julia() {
    koopa_configure_app_packages \
        --name='julia' \
        "$@"
}
