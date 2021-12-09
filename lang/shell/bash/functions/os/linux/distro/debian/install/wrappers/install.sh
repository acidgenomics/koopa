#!/usr/bin/env bash

koopa::debian_install_docker() { # {{{1
    koopa::install_app \
        --name-fancy='Docker' \
        --name='docker' \
        --platform='debian' \
        --system \
        "$@"
}
