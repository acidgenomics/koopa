#!/usr/bin/env bash

main() {
    # """
    # Install c-ares.
    # @note Updated 2022-08-19.
    #
    # @seealso
    # - https://c-ares.org/
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/c-ares.rb
    # """
    local app cmake_args dict
    koopa_assert_has_no_args "$#"
    koopa_activate_build_opt_prefix 'cmake'
    declare -A app=(
        ['cmake']="$(koopa_locate_cmake)"
    )
    [[ -x "${app['cmake']}" ]] || return 1
    declare -A dict=(
        ['name']='c-ares'
        ['prefix']="${KOOPA_INSTALL_PREFIX:?}"
        ['version']="${KOOPA_INSTALL_VERSION:?}"
    )
    dict['file']="${dict['name']}-${dict['version']}.tar.gz"
    dict['url']="https://c-ares.org/download/${dict['file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}"
    koopa_cd "${dict['name']}-${dict['version']}"
    cmake_args=(
        "-DCMAKE_INSTALL_PREFIX=${dict['prefix']}"
        "-DCMAKE_INSTALL_RPATH=${dict['prefix']}/lib"
    )
    "${app['cmake']}" -S . -B 'build' "${cmake_args[@]}"
    "${app['cmake']}" --build 'build'
    "${app['cmake']}" --install 'build'
    return 0
}
