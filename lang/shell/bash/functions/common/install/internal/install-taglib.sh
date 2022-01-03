#!/usr/bin/env bash

koopa:::install_taglib() { # {{{1
    # """
    # Install TagLib.
    # @note Updated 2022-01-03.
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
    local app dict
    koopa::assert_has_no_args "$#"
    declare -A app=(
        [cmake]="$(koopa::locate_cmake)"
    )
    declare -A dict=(
        [jobs]="$(koopa::cpu_count)"
        [name]='taglib'
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    dict[file]="v${dict[version]}.tar.gz"
    dict[url]="https://github.com/${dict[name]}/${dict[name]}/archive/refs/\
tags/${dict[file]}"
    koopa::download "${dict[url]}" "${dict[file]}"
    koopa::extract "${dict[file]}"
    koopa::cd "${dict[name]}-${dict[version]}"
    "${app[cmake]}" \
        -S . \
        -B 'build' \
        -DCMAKE_BUILD_TYPE='Release' \
        -DCMAKE_CXX_FLAGS='-fpic' \
        -DCMAKE_INSTALL_PREFIX="${dict[prefix]}"
    "${app[cmake]}" \
        --build 'build' \
        --parallel "${dict[jobs]}"
    "${app[cmake]}" --install 'build'
    return 0
}
