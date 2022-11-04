#!/usr/bin/env bash

# FIXME Need to address this on macOS:
# error: /Library/Developer/CommandLineTools/usr/bin/install_name_tool: no LC_RPATH load command with path: /private/var/folders/l1/8y8sjzmn15v49jgrqglghcfr0000gn/T/koopa-501-20221103-153829-LndyWgfZNQ/libsolv-0.7.22/build/src found in: /opt/koopa/app/libsolv/0.7.22/bin/testsolv (for architecture x86_64), required for specified option "-delete_rpath /private/var/folders/l1/8y8sjzmn15v49jgrqglghcfr0000gn/T/koopa-501-20221103-153829-LndyWgfZNQ/libsolv-0.7.22/build/src"

main() {
    # """
    # Install libsolv.
    # @note Updated 2022-11-03.
    #
    # @seealso
    # - https://github.com/openSUSE/libsolv
    # """
    local app cmake_args dict
    koopa_assert_has_no_args "$#"
    koopa_activate_app --build-only 'pkg-config'
    declare -A app=(
        ['cmake']="$(koopa_locate_cmake)"
    )
    [[ -x "${app['cmake']}" ]] || return 1
    declare -A dict=(
        ['jobs']="$(koopa_cpu_count)"
        ['name']='libsolv'
        ['prefix']="${KOOPA_INSTALL_PREFIX:?}"
        ['version']="${KOOPA_INSTALL_VERSION:?}"
    )
    dict['file']="${dict['version']}.tar.gz"
    dict['url']="https://github.com/openSUSE/${dict['name']}/archive/refs/\
tags/${dict['file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}"
    koopa_cd "${dict['name']}-${dict['version']}"
    koopa_print_env
    cmake_args=(
        "-DCMAKE_INSTALL_PREFIX=${dict['prefix']}"
    )
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
