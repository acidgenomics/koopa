#!/usr/bin/env bash

koopa::install_taglib() { # {{{1
    koopa::install_app \
        --name='taglib' \
        --name-fancy='TagLib' \
        "$@"
}

koopa:::install_taglib() {
    # """
    # Install TagLib.
    # @note Updated 2021-05-05.
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
    local file jobs name prefix url version
    prefix="${INSTALL_PREFIX:?}"
    version="${INSTALL_VERSION:?}"
    name='taglib'
    jobs="$(koopa::cpu_count)"
    file="${name}-${version}.tar.gz"
    url="https://github.com/${name}/${name}/releases/download/\
v${version}/${file}"
    koopa::download "$url"
    koopa::extract "$file"
    koopa::cd "${name}-${version}"
    cmake \
        -DCMAKE_BUILD_TYPE='Release' \
        -DCMAKE_CXX_FLAGS='-fpic' \
        -DCMAKE_INSTALL_PREFIX="${prefix}"
    make --jobs="$jobs"
    # > make check
    make install
    return 0
}
