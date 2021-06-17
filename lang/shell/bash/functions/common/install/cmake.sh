#!/usr/bin/env bash

# [2021-05-27] macOS success.

koopa::install_cmake() { # {{{1
    koopa::install_app \
        --name='cmake' \
        --name-fancy='CMake' \
        "$@"
}

koopa:::install_cmake() { # {{{1
    # """
    # Install CMake.
    # @note Updated 2021-05-04.
    #
    # @seealso
    # - https://github.com/Kitware/CMake
    # """
    local cc cxx file jobs make prefix url version
    jobs="$(koopa::cpu_count)"
    make="$(koopa::locate_make)"
    prefix="${INSTALL_PREFIX:?}"
    version="${INSTALL_VERSION:?}"
    if koopa::is_linux
    then
        cc='/usr/bin/gcc'
        cxx='/usr/bin/g++'
        koopa::assert_is_file "$cc" "$cxx"
        export CC="$cc"
        export CXX="$cxx"
    fi
    name='cmake'
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
    "$make" --jobs="$jobs"
    "$make" install
    return 0
}

koopa::uninstall_cmake() { # {{{1
    koopa::uninstall_app \
        --name-fancy='CMake' \
        --name='cmake' \
        "$@"
    return 0
}
