#!/usr/bin/env bash

install_wget() { # {{{1
    # """
    # Install wget.
    # @note Updated 2021-04-26.
    # """
    local file gnu_mirror jobs name openssl_pkgconfig prefix url version
    gnu_mirror="${INSTALL_GNU_MIRROR:?}"
    jobs="${INSTALL_JOBS:?}"
    name="${INSTALL_NAME:?}"
    prefix="${INSTALL_PREFIX:?}"
    version="${INSTALL_VERSION:?}"
    if koopa::is_macos
    then
        koopa::assert_is_installed brew
        openssl_pkgconfig="$(brew --prefix)/opt/openssl@1.1/lib/pkgconfig"
        koopa::assert_is_dir "$openssl_pkgconfig"
        koopa::add_to_pkg_config_path_start "$openssl_pkgconfig"
    fi
    file="${name}-${version}.tar.gz"
    url="${gnu_mirror}/${name}/${file}"
    koopa::download "$url"
    koopa::extract "$file"
    koopa::cd "${name}-${version}"
    ./configure \
        --prefix="$prefix" \
        --with-ssl='openssl'
    make --jobs="$jobs"
    make install
    return 0
}

install_wget "$@"
