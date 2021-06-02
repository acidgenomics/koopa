#!/usr/bin/env bash

koopa::linux_install_cloudbiolinux() { # {{{1
    koopa::install_app \
        --name='cloudbiolinux' \
        --name-fancy='CloudBioLinux' \
        --no-link \
        --platform='linux' \
        --version='rolling' \
        "$@"
}

koopa:::linux_install_cloudbiolinux() { # {{{1
    # """
    # Install CloudBioLinux.
    # @note Updated 2021-06-02.
    # """
    prefix="${INSTALL_PREFIX:?}"
    url='https://github.com/chapmanb/cloudbiolinux.git'
    koopa::git_clone "$url" "$prefix"
}
