#!/usr/bin/env bash

install_curl() { # {{{1
    # """
    # Install cURL.
    # @note Updated 2021-04-27.
    # @seealso
    # - https://curl.haxx.se/docs/install.html
    # """
    local file jobs name prefix url version version2
    name="${INSTALL_NAME:?}"
    prefix="${INSTALL_PREFIX:?}"
    version="${INSTALL_VERSION:?}"
    jobs="$(koopa::cpu_count)"
    file="${name}-${version}.tar.xz"
    version2="${version//./_}"
    url="https://github.com/${name}/${name}/releases/download/\
    ${name}-${version2}/${file}"
    koopa::download "$url"
    koopa::extract "$file"
    koopa::cd "${name}-${version}"
    ./configure --prefix="$prefix"
    make --jobs="$jobs"
    # > make test
    make install
    return 0
}

install_curl "$@"
