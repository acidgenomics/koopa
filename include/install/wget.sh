#!/usr/bin/env bash

# FIXME WE SHOULD CALL THE GNU INSTALLER AFTER DEFINING OPENSSL HERE.
install_wget() { # {{{1
    # """
    # Install wget.
    # @note Updated 2021-04-28.
    # """
    local file gnu_mirror jobs name openssl_pkgconfig prefix url version
    prefix="${INSTALL_PREFIX:?}"
    version="${INSTALL_VERSION:?}"
    name='wget'
    gnu_mirror="$(koopa::gnu_mirror_url)"
    jobs="$(koopa::cpu_count)"
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
