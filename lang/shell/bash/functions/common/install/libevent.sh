#!/usr/bin/env bash

koopa::install_libevent() { # {{{1
    koopa::install_app \
        --name='libevent' \
        "$@"
}

koopa:::install_libevent() { # {{{1
    # """
    # Install libevent.
    # @note Updated 2021-05-04.
    # """
    local file jobs name openssl_pkgconfig prefix url version
    prefix="${INSTALL_PREFIX:?}"
    version="${INSTALL_VERSION:?}"
    name='libevent'
    jobs="$(koopa::cpu_count)"
    # FIXME Need to make this a shared function.
    if koopa::is_macos
    then
        koopa::assert_is_installed brew
        openssl_pkgconfig="$(koopa::homebrew_prefix)/opt/\
openssl@1.1/lib/pkgconfig"
        koopa::assert_is_dir "$openssl_pkgconfig"
        koopa::add_to_pkg_config_path_start "$openssl_pkgconfig"
    fi
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
