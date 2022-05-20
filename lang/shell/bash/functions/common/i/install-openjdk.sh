#!/usr/bin/env bash

koopa_install_openjdk() {
    koopa_install_app \
        --name-fancy='OpenJDK' \
        --name='openjdk' \
        "$@"
}
