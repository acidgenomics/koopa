#!/usr/bin/env bash

koopa::install_taglib() { # {{{1
    koopa::install_app \
        --name-fancy='TagLib' \
        --name='taglib' \
        "$@"
}

koopa:::install_taglib() { # {{{1
    # """
    # Install TagLib.
    # @note Updated 2021-05-27.
    #
    # To build a static library, set the following two options with CMake:
    # -DBUILD_SHARED_LIBS=OFF -DENABLE_STATIC_RUNTIME=ON
    #
    # How to set '-fPIC' compiler flags?
    # -DCMAKE_CXX_FLAGS='-fpic'
    #
    # Enable for unit tests with 'make check':
    # -DBUILD_TESTS='on'
    #
    # @seealso
    # - https://stackoverflow.com/questions/29200461
    # - https://stackoverflow.com/questions/38296756
    # - https://github.com/taglib/taglib/blob/master/INSTALL.md
    # - https://github.com/eplightning/audiothumbs-frameworks/issues/2
    # - https://cmake.org/pipermail/cmake/2012-June/050792.html
    # - https://github.com/gabime/spdlog/issues/1190
    # """
    local cmake file jobs name prefix url version
    prefix="${INSTALL_PREFIX:?}"
    version="${INSTALL_VERSION:?}"
    cmake="$(koopa::locate_cmake)"
    jobs="$(koopa::cpu_count)"
    name='taglib'
    file="${name}-${version}.tar.gz"
    url="https://github.com/${name}/${name}/releases/download/\
v${version}/${file}"
    koopa::download "$url" "$file"
    koopa::extract "$file"
    koopa::cd "${name}-${version}"
    "$cmake" \
        -S . \
        -B 'build' \
        -DCMAKE_BUILD_TYPE='Release' \
        -DCMAKE_CXX_FLAGS='-fpic' \
        -DCMAKE_INSTALL_PREFIX="${prefix}"
    "$cmake" \
        --build 'build' \
        --parallel "$jobs"
    "$cmake" --install 'build'
    return 0
}

koopa::uninstall_taglib() { # {{{1
    koopa::uninstall_app \
        --name-fancy='TagLib' \
        --name='taglib' \
        "$@"
}
