#!/usr/bin/env bash

main() {
    # """
    # Install Fish shell.
    # @note Updated 2022-09-12.
    #
    # @seealso
    # - https://github.com/fish-shell/fish-shell/#building
    # """
    local app cmake_args dict
    koopa_assert_has_no_args "$#"
    koopa_activate_build_opt_prefix 'cmake'
    koopa_activate_opt_prefix 'ncurses'
    declare -A app=(
        ['cmake']="$(koopa_locate_cmake)"
    )
    [[ -x "${app['cmake']}" ]] || return 1
    declare -A dict=(
        ['bin_prefix']="$(koopa_bin_prefix)"
        ['jobs']="$(koopa_cpu_count)"
        ['name']='fish'
        ['prefix']="${KOOPA_INSTALL_PREFIX:?}"
        ['shared_ext']="$(koopa_shared_ext)"
        ['version']="${KOOPA_INSTALL_VERSION:?}"
    )
    dict['ncurses']="$(koopa_app_prefix 'ncurses')"
    dict['file']="${dict['name']}-${dict['version']}.tar.xz"
    dict['url']="https://github.com/${dict['name']}-shell/\
${dict['name']}-shell/releases/download/${dict['version']}/${dict['file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}"
    koopa_cd "${dict['name']}-${dict['version']}"
    cmake_args=(
        "-DCMAKE_CXX_FLAGS=${CPPFLAGS:-}"
        "-DCMAKE_C_FLAGS=${CFLAGS:-}"
        "-DCMAKE_EXE_LINKER_FLAGS=${LDFLAGS:-}"
        "-DCMAKE_INSTALL_PREFIX=${dict['prefix']}"
        "-DCMAKE_MODULE_LINKER_FLAGS=${LDFLAGS:-}"
        "-DCMAKE_SHARED_LINKER_FLAGS=${LDFLAGS:-}"
        "-DCURSES_INCLUDE_PATH=${dict['ncurses']}/include"
        "-DCURSES_LIBRARY=${dict['ncurses']}/lib/\
libncursesw.${dict['shared_ext']}"
    )
    koopa_print_env
    koopa_dl 'CMake args' "${cmake_args[*]}"
    "${app['cmake']}" -LH \
        -S '.' \
        -B 'build' \
        "${cmake_args[@]}"
    "${app['cmake']}" \
        --build 'build' \
        --parallel "${dict['jobs']}"
    "${app['cmake']}" --install 'build'
    return 0
}
