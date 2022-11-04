#!/usr/bin/env bash

main() {
    # """
    # Install googletest.
    # @note Updated 2022-11-04.
    #
    # @seealso
    # - https://github.com/Homebrew/homebrew-core/blob/HEAD/Formula/
    #     googletest.rb
    # """
    local app cmake_args dict
    koopa_assert_has_no_args "$#"
    koopa_activate_app --build-only 'cmake'
    declare -A app=(
        ['cmake']="$(koopa_locate_cmake)"
    )
    [[ -x "${app['cmake']}" ]] || return 1
    declare -A dict=(
        ['jobs']="$(koopa_cpu_count)"
        ['name']='googletest'
        ['prefix']="${KOOPA_INSTALL_PREFIX:?}"
        ['version']="${KOOPA_INSTALL_VERSION:?}"
    )
    dict['file']="release-${dict['version']}.tar.gz"
    dict['url']="https://github.com/google/googletest/archive/${dict['file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}"
    koopa_cd "${dict['name']}-release-${dict['version']}"
    cmake_args=(
        "-DCMAKE_INSTALL_PREFIX=${dict['prefix']}"
        '-DBUILD_GMOCK=ON'
        '-DBUILD_SHARED_LIBS=ON'
        '-DCMAKE_BUILD_TYPE=Release'
    )
    koopa_print_env
    koopa_dl 'CMake args' "${cmake_args[*]}"
    "${app['cmake']}" -LH \
        -S . \
        -B 'build' \
        "${cmake_args[@]}"
    "${app['cmake']}" \
        --build 'build' \
        --parallel "${dict['jobs']}"
    "${app['cmake']}" --install 'build'
    return 0
}
