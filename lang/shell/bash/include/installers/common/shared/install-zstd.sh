#!/usr/bin/env bash

main() { # {{{
    # """
    # Install zstd.
    # @note Updated 2022-04-25.
    #
    # @seealso
    # - https://facebook.github.io/zstd/
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/zstd.rb
    # """
    local app cmake_args dict
    koopa_assert_has_no_args "$#"
    koopa_activate_build_opt_prefix 'cmake'
    koopa_activate_opt_prefix 'zlib'
    declare -A app=(
        [cmake]="$(koopa_locate_cmake)"
    )
    declare -A dict=(
        [name]='zstd'
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    dict[file]="v${dict[version]}.tar.gz"
    dict[url]="https://github.com/facebook/${dict[name]}/archive/${dict[file]}"
    koopa_download "${dict[url]}" "${dict[file]}"
    koopa_extract "${dict[file]}"
    koopa_cd "${dict[name]}-${dict[version]}"
    cmake_args=(
        '-S' 'build/cmake'
        '-B' 'builddir'
        "-DCMAKE_INSTALL_PREFIX=${dict[prefix]}"
        "-DCMAKE_INSTALL_RPATH=${dict[prefix]}/lib"
        '-DZSTD_BUILD_CONTRIB=ON'
        '-DZSTD_LEGACY_SUPPORT=ON'
    )
    "${app[cmake]}" "${cmake_args[@]}"
    "${app[cmake]}" --build 'builddir'
    "${app[cmake]}" --install 'builddir'
    return 0
}
