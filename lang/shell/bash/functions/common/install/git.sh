#!/usr/bin/env bash

# [2021-05-27] macOS success.

koopa::install_git() { # {{{1
    koopa::install_app \
        --name-fancy='Git' \
        --name='git' \
        "$@"
}

koopa:::install_git() { # {{{1
    # """
    # Install Git.
    # @note Updated 2021-05-26.
    #
    # If system doesn't have gettext (msgfmt) installed:
    # Note that this doesn't work on Ubuntu 18 LTS.
    # NO_GETTEXT=YesPlease
    #
    # Git source code releases on GitHub:
    # > file="v${version}.tar.gz"
    # > url="https://github.com/git/${name}/archive/${file}"
    # """
    local file jobs make mirror name openssl prefix url version
    if koopa::is_macos
    then
        koopa::activate_opt_prefix 'autoconf'
    fi
    prefix="${INSTALL_PREFIX:?}"
    version="${INSTALL_VERSION:?}"
    jobs="$(koopa::cpu_count)"
    make="$(koopa::locate_make)"
    openssl="$(koopa::locate_openssl)"
    name='git'
    file="${name}-${version}.tar.gz"
    mirror='https://mirrors.edge.kernel.org/pub/software/scm/'
    url="${mirror}/${name}/${file}"
    koopa::download "$url"
    koopa::extract "$file"
    koopa::cd "${name}-${version}"
    "$make" configure
    ./configure \
        --prefix="$prefix" \
        --with-openssl="$openssl"
    "$make" --jobs="$jobs" V=1
    "$make" install
    return 0
}

koopa::uninstall_git() { # {{{1
    koopa::uninstall_app \
        --name-fancy='Git' \
        --name='git' \
        "$@"
}
