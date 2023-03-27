#!/usr/bin/env bash

main() {
    # """
    # Install Fish shell.
    # @note Updated 2023-03-26.
    #
    # @seealso
    # - https://github.com/fish-shell/fish-shell/#building
    # - https://github.com/conda-forge/fish-feedstock/blob/main/recipe/build.sh
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/fish.rb
    # - https://github.com/fish-shell/fish-shell/blob/master/cmake/PCRE2.cmake
    # """
    local app cmake_args dict
    koopa_assert_has_no_args "$#"
    koopa_activate_app --build-only 'cmake' 'pkg-config'
    koopa_activate_app 'ncurses' 'pcre2'
    declare -A app
    app['cmake']="$(koopa_locate_cmake)"
    [[ -x "${app['cmake']}" ]] || return 1
    declare -A dict=(
        ['bin_prefix']="$(koopa_bin_prefix)"
        ['jobs']="$(koopa_cpu_count)"
        ['name']='fish'
        ['ncurses']="$(koopa_app_prefix 'ncurses')"
        ['pcre2']="$(koopa_app_prefix 'pcre2')"
        ['prefix']="${KOOPA_INSTALL_PREFIX:?}"
        ['shared_ext']="$(koopa_shared_ext)"
        ['version']="${KOOPA_INSTALL_VERSION:?}"
    )
    koopa_assert_is_dir \
        "${dict['ncurses']}" \
        "${dict['pcre2']}"
    dict['curses_include_path']="${dict['ncurses']}/include"
    dict['curses_library']="${dict['ncurses']}/lib/\
libncursesw.${dict['shared_ext']}"
    dict['sys_pcre2_include_dir']="${dict['pcre2']}/include"
    dict['sys_pcre2_lib']="${dict['pcre2']}/lib/\
libpcre2-32.${dict['shared_ext']}"
    koopa_assert_is_dir \
        "${dict['curses_include_path']}" \
        "${dict['sys_pcre2_include_dir']}"
    koopa_assert_is_file \
        "${dict['curses_library']}" \
        "${dict['sys_pcre2_lib']}"
    dict['file']="${dict['name']}-${dict['version']}.tar.xz"
    dict['url']="https://github.com/${dict['name']}-shell/\
${dict['name']}-shell/releases/download/${dict['version']}/${dict['file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}"
    koopa_cd "${dict['name']}-${dict['version']}"
    cmake_args=(
        # Standard CMake arguments ---------------------------------------------
        '-DCMAKE_BUILD_TYPE=Release'
        "-DCMAKE_CXX_FLAGS=${CPPFLAGS:-}"
        "-DCMAKE_C_FLAGS=${CFLAGS:-}"
        "-DCMAKE_EXE_LINKER_FLAGS=${LDFLAGS:-}"
        "-DCMAKE_INSTALL_PREFIX=${dict['prefix']}"
        "-DCMAKE_MODULE_LINKER_FLAGS=${LDFLAGS:-}"
        "-DCMAKE_SHARED_LINKER_FLAGS=${LDFLAGS:-}"
        '-DCMAKE_VERBOSE_MAKEFILE=ON'
        # Build options --------------------------------------------------------
        '-DFISH_USE_SYSTEM_PCRE2=ON'
        # Dependency paths -----------------------------------------------------
        "-DCURSES_INCLUDE_PATH=${dict['curses_include_path']}"
        "-DCURSES_LIBRARY=${dict['curses_library']}"
        "-DSYS_PCRE2_INCLUDE_DIR=${dict['sys_pcre2_include_dir']}"
        "-DSYS_PCRE2_LIB=${dict['sys_pcre2_lib']}"
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
