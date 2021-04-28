#!/usr/bin/env bash

install_udunits() { # {{{1
    # """
    # Install udunits.
    # @note Updated 2021-04-28.
    # """
    local file jobs name prefix url version
    koopa::assert_is_linux
    name="${INSTALL_NAME:?}"
    prefix="${INSTALL_PREFIX:?}"
    version="${INSTALL_VERSION:?}"
    jobs="$(koopa::cpu_count)"
    file="${name}-${version}.tar.gz"
    # HTTP alternative:
    # > url="https://www.unidata.ucar.edu/downloads/${name}/${file}"
    url="ftp://ftp.unidata.ucar.edu/pub/${name}/${file}"
    koopa::download "$url"
    koopa::extract "$file"
    koopa::cd "${name}-${version}"
    ./configure --prefix="$prefix"
    make --jobs="$jobs"
    # > make check
    make install
    return 0
}

install_udunits "$@"
