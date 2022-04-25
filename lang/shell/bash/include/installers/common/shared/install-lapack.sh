#!/usr/bin/env bash

main() { # {{{
    # """
    # Install LAPACK.
    # @note Updated 2022-04-25.
    #
    # @seealso
    # - https://www.netlib.org/lapack/
    # - https://github.com/Reference-LAPACK/lapack
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/lapack.rb
    # """
    local app dict
    koopa_assert_has_no_args "$#"
    koopa_activate_opt_prefix 'gcc'
    declare -A app=(
        [cmake]="$(koopa_locate_cmake)"
    )
    declare -A dict=(
        [jobs]="$(koopa_cpu_count)"
        [name]='lapack'
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    dict[file]="v${dict[version]}.tar.gz"
    dict[url]="https://github.com/Reference-LAPACK/${dict[name]}/archive/\
refs/tags/${dict[file]}"
    koopa_download "${dict[url]}" "${dict[file]}"
    koopa_extract "${dict[file]}"
    koopa_cd "${dict[name]}-${dict[version]}"
    cmake_args=(
        "-DCMAKE_INSTALL_PREFIX=${dict[prefix]}"
        '-DBUILD_SHARED_LIBS:BOOL=ON'
        '-DLAPACKE:BOOL=ON'
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
