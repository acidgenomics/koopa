#!/usr/bin/env bash

main() {
    # """
    # Install Fish shell.
    # @note Updated 2023-04-04.
    #
    # @seealso
    # - https://github.com/fish-shell/fish-shell/#building
    # - https://github.com/conda-forge/fish-feedstock/blob/main/recipe/build.sh
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/fish.rb
    # - https://github.com/fish-shell/fish-shell/blob/master/cmake/PCRE2.cmake
    # """
    local -A cmake dict
    local -a cmake_args
    koopa_activate_app --build-only 'pkg-config'
    koopa_activate_app 'gettext' 'ncurses' 'pcre2'
    dict['gettext']="$(koopa_app_prefix 'gettext')"
    dict['ncurses']="$(koopa_app_prefix 'ncurses')"
    dict['pcre2']="$(koopa_app_prefix 'pcre2')"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['shared_ext']="$(koopa_shared_ext)"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    cmake['curses_include_dirs']="${dict['ncurses']}/include"
    cmake['curses_libraries']="${dict['ncurses']}/lib/\
libncursesw.${dict['shared_ext']}"
    cmake['intl_include_dir']="${dict['gettext']}/include"
    cmake['intl_libraries']="${dict['gettext']}/lib/\
libintl.${dict['shared_ext']}"
    cmake['sys_pcre2_include_dir']="${dict['pcre2']}/include"
    cmake['sys_pcre2_lib']="${dict['pcre2']}/lib/\
libpcre2-32.${dict['shared_ext']}"
    koopa_assert_is_dir \
        "${cmake['curses_include_dirs']}" \
        "${cmake['intl_include_dir']}" \
        "${cmake['sys_pcre2_include_dir']}"
    koopa_assert_is_file \
        "${cmake['curses_libraries']}" \
        "${cmake['intl_libraries']}" \
        "${cmake['sys_pcre2_lib']}"
    cmake_args=(
        # Build options --------------------------------------------------------
        '-DBUILD_DOCS=OFF'
        '-DFISH_USE_SYSTEM_PCRE2=ON'
        '-DWITH_GETTEXT=ON'
        # Dependency paths -----------------------------------------------------
        "-DCURSES_INCLUDE_DIRS=${cmake['curses_include_dirs']}"
        "-DCURSES_LIBRARIES=${cmake['curses_libraries']}"
        "-DIntl_INCLUDE_DIR=${cmake['intl_include_dir']}"
        "-DIntl_LIBRARIES=${cmake['intl_libraries']}"
        "-DSYS_PCRE2_INCLUDE_DIR=${cmake['sys_pcre2_include_dir']}"
        "-DSYS_PCRE2_LIB=${cmake['sys_pcre2_lib']}"
    )
    if koopa_is_macos
    then
        cmake_args+=('-DMAC_CODESIGN_ID=OFF')
    fi
    dict['url']="https://github.com/fish-shell/fish-shell/releases/download/\
${dict['version']}/fish-${dict['version']}.tar.xz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    koopa_cmake_build --jobs=1 --prefix="${dict['prefix']}" "${cmake_args[@]}"
    return 0
}
