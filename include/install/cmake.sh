#!/usr/bin/env bash

install_cmake() { # {{{1
    # """
    # Install CMake.
    # @note Updated 2021-05-04.
    #
    # @seealso
    # - https://github.com/Kitware/CMake
    # """
    local cc cxx file jobs prefix url version
    prefix="${INSTALL_PREFIX:?}"
    version="${INSTALL_VERSION:?}"
    name='cmake'
    jobs="$(koopa::cpu_count)"
    if koopa::is_linux
    then
        cc='/usr/bin/gcc'
        cxx='/usr/bin/g++'
        koopa::assert_is_file "$cc" "$cxx"
        export CC="$cc"
        export CXX="$cxx"
    fi
    file="${name}-${version}.tar.gz"
    url="https://github.com/Kitware/CMake/releases/download/v${version}/${file}"
    koopa::download "$url"
    koopa::extract "$file"
    koopa::cd "${name}-${version}"
    # Note that the './configure' script is just a wrapper for './bootstrap'.
    # > ./bootstrap --help
    ./bootstrap \
        --parallel="$jobs" \
        --prefix="$prefix"
    make --jobs="$jobs"
    make install
    return 0
}

install_cmake "$@"
