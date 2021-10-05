#!/usr/bin/env bash

koopa::configure_nim() { # {{{1
    # """
    # Configure Nim.
    # @note Updated 2021-09-29.
    # """
    local nim
    nim="$(koopa::locate_nim)"
    koopa:::configure_app_packages \
        --name='nim' \
        --name-fancy='Nim' \
        --which-app="$nim"
    return 0
}

# FIXME Need to be able to install nim from source.
# FIXME Need to work out how to configure nimble and nim packages.
# FIXME Need to add support inside of koopa for this -- 'nim-packages'.
# FIXME Need to add uninstall support.

koopa:::install_nim() { # {{{1
    # """
    # Install Nim.
    # @note Updated 2021-10-05.
    # """
    local file prefix url version
    prefix="${INSTALL_PREFIX:?}"
    version="${INSTALL_VERSION:?}"
    file='nim-1.4.8.tar.xz'
    url="https://nim-lang.org/download/${file}"
    koopa::download "$url"
    koopa::extract "$file"
    (
        koopa::cd 'FIXME'
        sh build.sh
        bin/nim c koch
        ./koch boot -d:release
        ./koch tools
        koopa::cp --target="$prefix" 'bin'
    )
    # FIXME Need to copy the 'bin/' to target.
    return 0
}
