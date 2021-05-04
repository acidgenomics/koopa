#!/usr/bin/env bash

install_gnu() { # {{{1
    # """
    # Install GNU package.
    # @note Updated 2021-05-04.
    # """
    local file gnu_mirror jobs name prefix suffix url version
    name="${INSTALL_NAME:?}"
    prefix="${INSTALL_PREFIX:?}"
    version="${INSTALL_VERSION:?}"
    gnu_mirror="$(koopa::gnu_mirror_url)"
    jobs="$(koopa::cpu_count)"
    case "$name" in
        gsl|make|ncurses|patch|tar)
            suffix='gz'
            ;;
        parallel)
            suffix='bz2'
            ;;
        *)
            suffix='xz'
            ;;
    esac
    file="${name}-${version}.tar.${suffix}"
    url="${gnu_mirror}/${name}/${file}"
    koopa::download "$url"
    koopa::extract "$file"
    koopa::cd "${name}-${version}"
    ./configure --prefix="$prefix"
    make --jobs="$jobs"
    # > make check
    make install
    return 0
}

install_gnu "$@"
