#!/usr/bin/env bash

main() {
    # """
    # Install libgit2.
    # @note Updated 2022-08-03.
    #
    # @seealso
    # - https://libgit2.org/docs/guides/build-and-link/
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/libgit2.rb
    # - https://github.com/libgit2/libgit2/blob/main/CMakeLists.txt
    # - https://github.com/libgit2/libgit2/issues/5079
    # """
    local app cmake_args dict
    koopa_assert_has_no_args "$#"
    koopa_activate_build_opt_prefix \
        'cmake' \
        'pkg-config'
    koopa_activate_opt_prefix \
        'zlib' \
        'pcre' \
        'openssl3' \
        'libssh2'
    declare -A app=(
        [cmake]="$(koopa_locate_cmake)"
    )
    [[ -x "${app[cmake]}" ]] || return 1
    declare -A dict=(
        [jobs]="$(koopa_cpu_count)"
        [name]='libgit2'
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    dict[file]="v${dict[version]}.tar.gz"
    dict[url]="https://github.com/${dict[name]}/${dict[name]}/\
archive/${dict[file]}"
    koopa_download "${dict[url]}" "${dict[file]}"
    koopa_extract "${dict[file]}"
    koopa_cd "${dict[name]}-${dict[version]}"
    dict[openssl]="$(koopa_app_prefix 'openssl3')"
    dict[pcre]="$(koopa_app_prefix 'pcre')"
    dict[zlib]="$(koopa_app_prefix 'zlib')"
    koopa_add_rpath_to_ldflags "${dict[openssl]}/lib"
    cmake_args=(
        "-DCMAKE_INSTALL_PREFIX=${dict[prefix]}"
        '-DCMAKE_BUILD_TYPE=Release'
        '-DBUILD_TESTS=OFF'
        "-DZLIB_INCLUDE_DIR=${dict[zlib]}/include"
        "-DZLIB_LIBRARY=${dict[zlib]}/lib"
        "-DPCRE_INCLUDE_DIR=${dict[pcre]}/include"
        "-DPCRE_LIBRARY=${dict[pcre]}/lib"
        '-DUSE_BUNDLED_ZLIB=OFF'
        '-DUSE_SSH=YES'
    )
    "${app[cmake]}" \
        -S '.' \
        -B 'build' \
        "${cmake_args[@]}"
    "${app[cmake]}" \
        --build 'build' \
        --parallel "${dict[jobs]}"
    "${app[cmake]}" --install 'build'
    return 0
}
