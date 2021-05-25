#!/usr/bin/env bash

koopa::install_go() { # {{{1
    koopa::install_app \
        --name='go' \
        --name-fancy='Go' \
        "$@"
}

koopa:::install_go() { # {{{1
    # """
    # Install Go.
    # @note Updated 2021-05-25.
    # """
    local arch file gopath name os_id prefix url version
    prefix="${INSTALL_PREFIX:?}"
    version="${INSTALL_VERSION:?}"
    name='go'
    # e.g. 'amd64' for x86.
    arch="$(koopa::arch2)"
    if koopa::is_macos
    then
        os_id='darwin'
    else
        os_id='linux'
    fi
    file="${name}${version}.${os_id}-${arch}.tar.gz"
    url="https://dl.google.com/${name}/${file}"
    koopa::download "$url"
    koopa::extract "$file"
    koopa::cp -t "$prefix" "${name}/"*
    # FIXME Consider putting this code on 'koopa::configure_go'.
    gopath="$(koopa::go_packages_prefix)"
    koopa::sys_mkdir "$gopath"
    (
        koopa::sys_set_permissions "$(koopa::dirname "$gopath")"
        koopa::cd "$(koopa::dirname "$gopath")"
        koopa::sys_ln "$(koopa::basename "$gopath")" 'latest'
    )
    return 0
}
