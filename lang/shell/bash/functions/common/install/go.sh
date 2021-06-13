#!/usr/bin/env bash

# [2021-05-27] macOS success.

koopa::configure_go() { # {{{1
    # """
    # Configure Go.
    # @note Updated 2021-06-11.
    # """
    local name_fancy prefix version
    koopa::activate_go
    koopa::assert_is_installed 'go'
    name_fancy='Go'
    version="$(koopa::get_version 'go')"
    prefix="$(koopa::go_packages_prefix "$version")"
    koopa::configure_start "$name_fancy" "$prefix"
    if [[ ! -d "$prefix" ]]
    then
        koopa::sys_mkdir "$prefix"
        koopa::sys_set_permissions "$(koopa::dirname "$prefix")"
        koopa::link_into_opt "$prefix" 'go-packages'
    fi
    koopa::activate_go
    koopa::configure_success "$name_fancy" "$prefix"
    return 0
}

koopa::install_go() { # {{{1
    koopa::install_app \
        --name-fancy='Go' \
        --name='go' \
        --no-link \
        "$@"
    koopa::configure_go
    return 0
}

koopa:::install_go() { # {{{1
    # """
    # Install Go.
    # @note Updated 2021-05-27.
    # """
    local arch file name os_id prefix url version
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
    return 0
}

koopa::uninstall_go() { # {{{1
    koopa::uninstall_app \
        --name-fancy='Go' \
        --name='go' \
        --no-link \
        "$@"
}
