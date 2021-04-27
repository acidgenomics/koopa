#!/usr/bin/env bash

install_git() { # {{{1
    # """
    # Install Git.
    # @note Updated 2021-04-27.
    #
    # If system doesn't have gettext (msgfmt) installed:
    # Note that this doesn't work on Ubuntu 18 LTS.
    # NO_GETTEXT=YesPlease
    #
    # Git source code releases on GitHub:
    # > file="v${version}.tar.gz"
    # > url="https://github.com/git/${name}/archive/${file}"
    # """
    local file jobs name openssl prefix url version
    name="${INSTALL_NAME:?}"
    prefix="${INSTALL_PREFIX:?}"
    version="${INSTALL_VERSION:?}"
    jobs="$(koopa::cpu_count)"
    file="${name}-${version}.tar.gz"
    url="https://mirrors.edge.kernel.org/pub/software/scm/${name}/${file}"
    openssl='/bin/openssl'
    koopa::assert_is_installed "$openssl"
    koopa::download "$url"
    koopa::extract "$file"
    koopa::cd "git-${version}"
    make configure
    ./configure \
        --prefix="$prefix" \
        --with-openssl="$openssl"
    make --jobs="$jobs" V=1
    make install
    return 0
}

install_git "$@"
