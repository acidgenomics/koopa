#!/usr/bin/env bash

koopa::install_shellcheck() { # {{{1
    koopa:::install_app \
        --name-fancy='ShellCheck' \
        --name='shellcheck' \
        "$@"
}

koopa:::install_shellcheck() { # {{{1
    # """
    # Install ShellCheck.
    # @note Updated 2021-04-27.
    # """
    local arch file name os_id prefix url version
    prefix="${INSTALL_PREFIX:?}"
    version="${INSTALL_VERSION:?}"
    name='shellcheck'
    if koopa::is_macos
    then
        os_id='darwin'
    else
        os_id='linux'
    fi
    arch="$(koopa::arch)"
    file="${name}-v${version}.${os_id}.${arch}.tar.xz"
    url="https://github.com/koalaman/${name}/releases/download/\
v${version}/${file}"
    koopa::download "$url"
    koopa::extract "$file"
    koopa::cp -t "${prefix}/bin" "${name}-v${version}/${name}"
    return 0
}

koopa::uninstall_shellcheck() { # {{{1
    koopa:::uninstall_app \
        --name-fancy='ShellCheck' \
        --name='shellcheck' \
        "$@"
}
