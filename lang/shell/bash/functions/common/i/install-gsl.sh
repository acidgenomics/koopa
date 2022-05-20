#!/usr/bin/env bash

koopa_install_gsl() {
    koopa_install_app \
        --installer='gnu-app' \
        --name='gsl' \
        --name-fancy='GSL' \
        "$@"
}
