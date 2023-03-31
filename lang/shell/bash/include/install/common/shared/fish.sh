#!/usr/bin/env bash

main() {
    # """
    # Install Fish shell.
    # @note Updated 2023-03-31.
    #
    # @seealso
    # - https://github.com/fish-shell/fish-shell/#building
    # - https://github.com/conda-forge/fish-feedstock/blob/main/recipe/build.sh
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/fish.rb
    # - https://github.com/fish-shell/fish-shell/blob/master/cmake/PCRE2.cmake
    # """
    local cmake_args cmake_dict dict
    declare -A cmake_dict dict
    koopa_assert_has_no_args "$#"
    koopa_activate_app --build-only 'pkg-config'
    koopa_activate_app 'gettext' 'ncurses' 'pcre2'
    dict['gettext']="$(koopa_app_prefix 'gettext')"
    dict['ncurses']="$(koopa_app_prefix 'ncurses')"
    dict['pcre2']="$(koopa_app_prefix 'pcre2')"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['shared_ext']="$(koopa_shared_ext)"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    cmake_dict['curses_include_dirs']="${dict['ncurses']}/include"
    cmake_dict['curses_libraries']="${dict['ncurses']}/lib/\
libncursesw.${dict['shared_ext']}"
    cmake_dict['intl_include_dir']="${dict['gettext']}/include"
    cmake_dict['intl_libraries']="${dict['gettext']}/lib/\
libintl.${dict['shared_ext']}"
    cmake_dict['sys_pcre2_include_dir']="${dict['pcre2']}/include"
    cmake_dict['sys_pcre2_lib']="${dict['pcre2']}/lib/\
libpcre2-32.${dict['shared_ext']}"
    koopa_assert_is_dir \
        "${cmake_dict['curses_include_dirs']}" \
        "${cmake_dict['intl_include_dir']}" \
        "${cmake_dict['sys_pcre2_include_dir']}"
    koopa_assert_is_file \
        "${cmake_dict['curses_libraries']}" \
        "${cmake_dict['intl_libraries']}" \
        "${cmake_dict['sys_pcre2_lib']}"
    cmake_args=(
        # Build options --------------------------------------------------------
        '-DBUILD_DOCS=OFF'
        '-DFISH_USE_SYSTEM_PCRE2=ON'
        '-DMAC_CODESIGN_ID=OFF'
        '-DWITH_GETTEXT=ON'
        # Dependency paths -----------------------------------------------------
        "-DCURSES_INCLUDE_DIRS=${cmake_dict['curses_include_dirs']}"
        "-DCURSES_LIBRARIES=${cmake_dict['curses_libraries']}"
        "-DIntl_INCLUDE_DIR=${cmake_dict['intl_include_dir']}"
        "-DIntl_LIBRARIES=${cmake_dict['intl_libraries']}"
        "-DSYS_PCRE2_INCLUDE_DIR=${cmake_dict['sys_pcre2_include_dir']}"
        "-DSYS_PCRE2_LIB=${cmake_dict['sys_pcre2_lib']}"
    )
    dict['url']="https://github.com/fish-shell/fish-shell/releases/download/\
${dict['version']}/fish-${dict['version']}.tar.xz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    koopa_cmake_build --prefix="${dict['prefix']}" "${cmake_args[@]}"
    return 0
}
