#!/usr/bin/env bash

install_udunits() { # {{{1
    # """
    # Install udunits.
    # @note Updated 2021-04-29.
    # """
    local file jobs prefix url version
    koopa::assert_is_linux
    prefix="${INSTALL_PREFIX:?}"
    version="${INSTALL_VERSION:?}"
    jobs="$(koopa::cpu_count)"
    file="udunits-${version}.tar.gz"
    # HTTP alternative:
    # > url="https://www.unidata.ucar.edu/downloads/udunits/${file}"
    url="ftp://ftp.unidata.ucar.edu/pub/udunits/${file}"
    koopa::download "$url"
    koopa::extract "$file"
    koopa::cd "udunits-${version}"
    ./configure --prefix="$prefix"
    make --jobs="$jobs"
    # > make check
    make install
    return 0
}

install_udunits "$@"
