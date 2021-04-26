#!/usr/bin/env bash

install_cmake() { # {{{1
    # """
    # Install CMake.
    # @note Updated 2021-04-26.
    #
    # We're enforcing system GCC here to avoid libstdc++ errors.
    #
    # @seealso
    # - https://github.com/Kitware/CMake
    # """
    local file jobs name prefix url version
    jobs="${INSTALL_JOBS:?}"
    name="${INSTALL_NAME:?}"
    prefix="${INSTALL_PREFIX:?}"
    version="${INSTALL_VERSION:?}"
    if koopa::is_linux
    then
        koopa::assert_is_file '/usr/bin/gcc' '/usr/bin/g++'
        export CC='/usr/bin/gcc'
        export CXX='/usr/bin/g++'
    fi
    file="cmake-${version}.tar.gz"
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
