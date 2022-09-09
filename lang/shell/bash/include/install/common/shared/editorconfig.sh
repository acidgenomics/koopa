#!/usr/bin/env bash

main() {
    # """
    # Install EditorConfig.
    # @note Updated 2022-08-18.
    #
    # @seealso
    # - https://facebook.github.io/zstd/
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/zstd.rb
    # - https://github.com/Homebrew/homebrew-core/blob/HEAD/Formula/
    #     editorconfig.rb
    # - https://github.com/editorconfig/editorconfig-core-c/blob/master/
    #     INSTALL.md
    # - https://github.com/editorconfig/editorconfig-core-c/blob/master/
    #     CMake_Modules/FindPCRE2.cmake
    # - https://git.alpinelinux.org/aports/tree/community/editorconfig/APKBUILD
    # """
    local app cmake_args dict
    koopa_assert_has_no_args "$#"
    koopa_activate_build_opt_prefix 'cmake'
    koopa_activate_opt_prefix 'pcre2'
    declare -A app=(
        ['cmake']="$(koopa_locate_cmake)"
        ['make']="$(koopa_locate_make)"
    )
    [[ -x "${app['cmake']}" ]] || return 1
    [[ -x "${app['make']}" ]] || return 1
    declare -A dict=(
        ['name']='editorconfig-core-c'
        ['pcre2']="$(koopa_app_prefix 'pcre2')"
        ['prefix']="${KOOPA_INSTALL_PREFIX:?}"
        ['shared_ext']="$(koopa_shared_ext)"
        ['version']="${KOOPA_INSTALL_VERSION:?}"
    )
    dict['file']="v${dict['version']}.tar.gz"
    dict['url']="https://github.com/editorconfig/${dict['name']}/\
archive/${dict['file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}"
    koopa_cd "${dict['name']}-${dict['version']}"
    koopa_mkdir 'build'
    koopa_cd 'build'
    dict['pcre2_include_dir']="${dict['pcre2']}/include"
    dict['pcre2_library']="${dict['pcre2']}/lib/libpcre2-8.${dict['shared_ext']}"
    koopa_assert_is_dir "${dict['pcre2_include_dir']}"
    koopa_assert_is_file "${dict['pcre2_library']}"
    cmake_args=(
        '-DCMAKE_INSTALL_LIBDIR=lib'
        "-DCMAKE_INSTALL_PREFIX=${dict['prefix']}"
        "-DCMAKE_INSTALL_RPATH=${dict['prefix']}/lib"
        "-DCMAKE_LIBRARY_PATH=${dict['pcre2']}/lib"
        "-DPCRE2_INCLUDE_DIR=${dict['pcre2_include_dir']}"
        "-DPCRE2_LIBRARY=${dict['pcre2_library']}"
    )
    koopa_print "${cmake_args[@]}"
    "${app['cmake']}" .. "${cmake_args[@]}"
    "${app['make']}" install
    return 0
}
