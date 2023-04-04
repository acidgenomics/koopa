#!/usr/bin/env bash

main() {
    # """
    # Install EditorConfig.
    # @note Updated 2023-04-04.
    #
    # @seealso
    # - https://github.com/Homebrew/homebrew-core/blob/HEAD/Formula/
    #     editorconfig.rb
    # - https://github.com/editorconfig/editorconfig-core-c/blob/master/
    #     INSTALL.md
    # - https://github.com/editorconfig/editorconfig-core-c/blob/master/
    #     CMake_Modules/FindPCRE2.cmake
    # - https://git.alpinelinux.org/aports/tree/community/editorconfig/APKBUILD
    # """
    local cmake cmake_args dict
    declare -A cmake dict
    koopa_assert_has_no_args "$#"
    koopa_activate_app --build-only 'pkg-config'
    koopa_activate_app 'pcre2'
    dict['pcre2']="$(koopa_app_prefix 'pcre2')"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['shared_ext']="$(koopa_shared_ext)"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    cmake['cmake_library_path']="${dict['pcre2']}/lib"
    cmake['pcre2_include_dir']="${dict['pcre2']}/include"
    cmake['pcre2_library']="${dict['pcre2']}/lib/\
libpcre2-8.${dict['shared_ext']}"
    koopa_assert_is_dir "${cmake['pcre2_include_dir']}"
    koopa_assert_is_file "${cmake['pcre2_library']}"
    cmake_args=(
        # Standard CMake arguments ---------------------------------------------
        "-DCMAKE_LIBRARY_PATH=${cmake['cmake_library_path']}"
        # Dependency paths -----------------------------------------------------
        "-DPCRE2_INCLUDE_DIR=${cmake['pcre2_include_dir']}"
        "-DPCRE2_LIBRARY=${cmake['pcre2_library']}"
    )
    dict['url']="https://github.com/editorconfig/editorconfig-core-c/\
archive/v${dict['version']}.tar.gz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    koopa_cmake_build --prefix="${dict['prefix']}" "${cmake_args[@]}"
    return 0
}
