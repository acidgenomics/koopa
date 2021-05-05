#!/usr/bin/env bash

koopa::linux_install_cloudbiolinux() { # {{{1
    koopa::linux_install_app \
        --name='cloudbiolinux' \
        --name-fancy='CloudBioLinux' \
        --version='rolling' \
        --no-link \
        "$@"
}

koopa:::linux_install_cloudbiolinux() { # {{{1
    # """
    # Install CloudBioLinux.
    # @note Updated 2021-05-05.
    # """
    prefix="${INSTALL_PREFIX:?}"
    url='https://github.com/chapmanb/cloudbiolinux.git'
    git clone "$url" "$prefix"
}
