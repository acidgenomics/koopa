#!/usr/bin/env bash

# NOTE Add support for NASM compiler, to improve performance.

main() {
    # """
    # Install libjpeg-turbo.
    # @note Updated 2023-03-24.
    #
    # @seealso
    # - https://libjpeg-turbo.org/
    # - https://github.com/libjpeg-turbo/libjpeg-turbo/blob/main/BUILDING.md
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/
    #     jpeg-turbo.rb
    # """
    local app cmake_args dict
    koopa_assert_has_no_args "$#"
    koopa_activate_app --build-only 'cmake' 'make' 'pkg-config'
    declare -A app=(
        ['cmake']="$(koopa_locate_cmake)"
        ['make']="$(koopa_locate_make)"
    )
    [[ -x "${app['cmake']}" ]] || return 1
    [[ -x "${app['make']}" ]] || return 1
    declare -A dict=(
        ['jobs']="$(koopa_cpu_count)"
        ['name']='libjpeg-turbo'
        ['prefix']="${KOOPA_INSTALL_PREFIX:?}"
        ['version']="${KOOPA_INSTALL_VERSION:?}"
    )
    dict['file']="${dict['name']}-${dict['version']}.tar.gz"
    dict['url']="https://downloads.sourceforge.net/project/${dict['name']}/\
${dict['version']}/${dict['name']}-${dict['version']}.tar.gz"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}"
    koopa_cd "${dict['name']}-${dict['version']}"
    cmake_args=(
        # Standard CMake arguments ---------------------------------------------
        '-DCMAKE_BUILD_TYPE=Release'
        "-DCMAKE_INSTALL_PREFIX=${dict['prefix']}"
        '-DCMAKE_VERBOSE_MAKEFILE=ON'
        # Build options --------------------------------------------------------
        '-DWITH_JPEG8=1'
    )
    koopa_print_env
    koopa_dl 'CMake args' "${cmake_args[*]}"
    "${app['cmake']}" -LH -S '.' "${cmake_args[@]}"
    "${app['make']}" VERBOSE=1 --jobs="${dict['jobs']}"
    # > "${app['make']}" test
    "${app['make']}" install
    return 0
}
