#!/usr/bin/env bash

koopa::install_libevent() { # {{{1
    koopa::install_app \
        --name='libevent' \
        "$@"
}

koopa:::install_libevent() { # {{{1
    # """
    # Install libevent.
    # @note Updated 2021-05-05.
    # """
    local file jobs name prefix url version
    prefix="${INSTALL_PREFIX:?}"
    version="${INSTALL_VERSION:?}"
    name='libevent'
    jobs="$(koopa::cpu_count)"
    koopa::is_macos && koopa::activate_homebrew_pkg_config 'openssl@1.1'
    file="${name}-${version}-stable.tar.gz"
    url="https://github.com/${name}/${name}/releases/download/\
release-${version}-stable/${file}"
    koopa::download "$url"
    koopa::extract "$file"
    koopa::cd "${name}-${version}-stable"
    ./configure --prefix="$prefix"
    make --jobs="$jobs"
    # > make check
    make install
    return 0
}
