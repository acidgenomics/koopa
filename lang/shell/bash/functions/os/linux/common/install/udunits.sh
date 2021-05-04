#!/usr/bin/env bash

koopa::linux_install_udunits() { # {{{1
    koopa::linux_install_app \
        --name='udunits' \
        "$@"
}

koopa:::linux_install_udunits() { # {{{1
    # """
    # Install udunits.
    # @note Updated 2021-05-04.
    # """
    local file jobs name prefix url version
    koopa::assert_is_linux
    prefix="${INSTALL_PREFIX:?}"
    version="${INSTALL_VERSION:?}"
    name='udunits'
    jobs="$(koopa::cpu_count)"
    file="${name}-${version}.tar.gz"
    # HTTP alternative:
    # > url="https://www.unidata.ucar.edu/downloads/udunits/${file}"
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
