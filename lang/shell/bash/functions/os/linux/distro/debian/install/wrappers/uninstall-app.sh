#!/usr/bin/env bash

koopa::debian_uninstall_docker() { # {{{1
    koopa::uninstall_app \
        --name-fancy='Docker' \
        --name='docker' \
        --platform='debian' \
        --system \
        "$@"
}
