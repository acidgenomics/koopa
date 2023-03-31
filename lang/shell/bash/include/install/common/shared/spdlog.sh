#!/usr/bin/env bash

main() {
    # """
    # Install spdlog.
    # @note Updated 2023-03-31.
    #
    # @seealso
    # - https://github.com/gabime/spdlog/
    # - https://github.com/Homebrew/homebrew-core/blob/HEAD/Formula/spdlog.rb
    # - https://github.com/conda-forge/spdlog-feedstock
    # - https://raw.githubusercontent.com/archlinux/svntogit-community/
    #     packages/spdlog/trunk/PKGBUILD
    # """
    local app cmake_args cmake_dict dict
    declare -A app cmake_dict dict
    koopa_assert_has_no_args "$#"
    koopa_activate_app --build-only 'patch' 'pkg-config'
    koopa_activate_app 'fmt'
    app['cat']="$(koopa_locate_cat --allow-system)"
    app['ctest']="$(koopa_locate_ctest)"
    app['patch']="$(koopa_locate_patch)"
    [[ -x "${app['cat']}" ]] || return 1
    [[ -x "${app['ctest']}" ]] || return 1
    [[ -x "${app['patch']}" ]] || return 1
    dict['fmt']="$(koopa_app_prefix 'fmt')"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    koopa_assert_is_dir "${dict['fmt']}"
    cmake_dict['fmt_dir']="${dict['fmt']}/lib/cmake/fmt"
    koopa_assert_is_dir "${cmake_dict['fmt_dir']}"
    cmake_args=(
        # Build options --------------------------------------------------------
        '-DSPDLOG_BUILD_BENCH=OFF'
        '-DSPDLOG_BUILD_SHARED=ON'
        '-DSPDLOG_BUILD_TESTS=ON'
        '-DSPDLOG_FMT_EXTERNAL=ON'
        # Dependency paths -----------------------------------------------------
        "-Dfmt_DIR=${cmake_dict['fmt_dir']}"
    )
    dict['url']="https://github.com/gabime/spdlog/archive/\
v${dict['version']}.tar.gz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    # Patch diff created with:
    # > diff -u 'tweakme.h' 'tweakme.h-1' > 'patch-tweakme.patch'
    "${app['cat']}" << END > 'patch-tweakme.patch'
--- tweakme.h	2022-12-06 16:50:30
+++ tweakme.h-1	2022-12-06 16:51:32
@@ -80,6 +80,9 @@
 //
 // #define SPDLOG_FMT_EXTERNAL
 ///////////////////////////////////////////////////////////////////////////////
+#ifndef SPDLOG_FMT_EXTERNAL
+#define SPDLOG_FMT_EXTERNAL
+#endif
 
 ///////////////////////////////////////////////////////////////////////////////
 // Uncomment to use C++20 std::format instead of fmt. This removes compile
END
    "${app['patch']}" \
        --unified \
        --verbose \
        'include/spdlog/tweakme.h' \
        'patch-tweakme.patch'
    koopa_cmake_build --prefix="${dict['prefix']}" "${cmake_args[@]}"
    return 0
}
