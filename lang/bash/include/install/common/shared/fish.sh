#!/usr/bin/env bash

# FIXME Need to locate libpcre2-32.so.0:
# fish: error while loading shared libraries: libpcre2-32.so.0: cannot open shared object file: No such file or directory

main() {
    # """
    # Install Fish shell.
    # @note Updated 2023-10-17.
    #
    # @seealso
    # - https://github.com/fish-shell/fish-shell/#building
    # - https://github.com/conda-forge/fish-feedstock/blob/main/recipe/build.sh
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/fish.rb
    # - https://github.com/fish-shell/fish-shell/blob/master/cmake/PCRE2.cmake
    # """
    local -A app cmake dict
    local -a cmake_args
    koopa_activate_app --build-only 'pkg-config'
    # FIXME This is causing linkage issues on Linux, but we may need to burn
    # these in manually instead.
    koopa_activate_app 'gettext' 'ncurses' 'pcre2'
    app['cc']="$(koopa_locate_cc --only-system)"
    app['cxx']="$(koopa_locate_cxx --only-system)"
    app['msgfmt']="$(koopa_locate_msgfmt --realpath)"
    app['msgmerge']="$(koopa_locate_msgmerge --realpath)"
    koopa_assert_is_executable "${app[@]}"
    dict['gettext']="$(koopa_app_prefix 'gettext')"
    dict['ncurses']="$(koopa_app_prefix 'ncurses')"
    dict['pcre2']="$(koopa_app_prefix 'pcre2')"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['shared_ext']="$(koopa_shared_ext)"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    cmake['curses_include_path']="${dict['ncurses']}/include"
    cmake['curses_library']="${dict['ncurses']}/lib/\
libncursesw.${dict['shared_ext']}"
    cmake['curses_tinfo']="${dict['ncurses']}/lib/\
libtinfo.${dict['shared_ext']}"
    cmake['gettext_msgfmt_executable']="${app['msgfmt']}"
    cmake['gettext_msgmerge_executable']="${app['msgmerge']}"
    cmake['intl_include_dir']="${dict['gettext']}/include"
    cmake['intl_libraries']="${dict['gettext']}/lib/\
libintl.${dict['shared_ext']}"
    cmake['sys_pcre2_include_dir']="${dict['pcre2']}/include"
    cmake['sys_pcre2_lib']="${dict['pcre2']}/lib/\
libpcre2-32.${dict['shared_ext']}"
    koopa_assert_is_dir \
        "${cmake['curses_include_path']}" \
        "${cmake['intl_include_dir']}" \
        "${cmake['sys_pcre2_include_dir']}"
    koopa_assert_is_file \
        "${cmake['curses_library']}" \
        "${cmake['curses_tinfo']}" \
        "${cmake['intl_libraries']}" \
        "${cmake['sys_pcre2_lib']}"
    cmake_args=(
        # Build options --------------------------------------------------------
        '-DBUILD_DOCS=OFF'
        '-DFISH_USE_SYSTEM_PCRE2=ON'
        '-DPCRE2_BUILD_PCRE2GREP=OFF'
        '-DPCRE2_BUILD_PCRE2_32=OFF'
        '-DPCRE2_BUILD_PCRE2_8=OFF'
        '-DPCRE2_BUILD_TESTS=OFF'
        '-DPCRE2_SHOW_REPORT=ON'
        '-DWITH_GETTEXT=ON'
        # Dependency paths -----------------------------------------------------
        "-DCURSES_INCLUDE_PATH=${cmake['curses_include_path']}"
        "-DCURSES_LIBRARY=${cmake['curses_library']}"
        "-DCURSES_TINFO=${cmake['curses_tinfo']}"
        "-DGETTEXT_MSGFMT_EXECUTABLE=${cmake['gettext_msgfmt_executable']}"
        "-DGETTEXT_MSGMERGE_EXECUTABLE=${cmake['gettext_msgmerge_executable']}"
        "-DIntl_INCLUDE_DIR=${cmake['intl_include_dir']}"
        "-DIntl_LIBRARIES=${cmake['intl_libraries']}"
        "-DSYS_PCRE2_INCLUDE_DIR=${cmake['sys_pcre2_include_dir']}"
        "-DSYS_PCRE2_LIB=${cmake['sys_pcre2_lib']}"
    )
    if koopa_is_macos
    then
        cmake_args+=('-DMAC_CODESIGN_ID=OFF')
    fi
    export CC="${app['cc']}"
    export CXX="${app['cxx']}"
    dict['url']="https://github.com/fish-shell/fish-shell/releases/download/\
${dict['version']}/fish-${dict['version']}.tar.xz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    koopa_cmake_build --prefix="${dict['prefix']}" "${cmake_args[@]}"
    return 0
}
