#!/usr/bin/env bash

main() {
    # """
    # Install spdlog.
    # @note Updated 2023-03-24.
    #
    # @seealso
    # - https://github.com/gabime/spdlog/
    # - https://github.com/Homebrew/homebrew-core/blob/HEAD/Formula/spdlog.rb
    # - https://github.com/conda-forge/spdlog-feedstock
    # - https://raw.githubusercontent.com/archlinux/svntogit-community/
    #     packages/spdlog/trunk/PKGBUILD
    # """
    local app dict shared_cmake_args
    koopa_assert_has_no_args "$#"
    koopa_activate_app --build-only 'cmake' 'patch' 'pkg-config'
    koopa_activate_app 'fmt'
    declare -A app=(
        ['cat']="$(koopa_locate_cat)"
        ['cmake']="$(koopa_locate_cmake)"
        ['ctest']="$(koopa_locate_ctest)"
        ['patch']="$(koopa_locate_patch)"
    )
    [[ -x "${app['cat']}" ]] || return 1
    [[ -x "${app['cmake']}" ]] || return 1
    [[ -x "${app['ctest']}" ]] || return 1
    [[ -x "${app['patch']}" ]] || return 1
    declare -A dict=(
        ['fmt']="$(koopa_app_prefix 'fmt')"
        ['jobs']="$(koopa_cpu_count)"
        ['name']='spdlog'
        ['prefix']="${KOOPA_INSTALL_PREFIX:?}"
        ['version']="${KOOPA_INSTALL_VERSION:?}"
    )
    koopa_assert_is_dir "${dict['fmt']}"
    dict['file']="v${dict['version']}.tar.gz"
    dict['url']="https://github.com/gabime/${dict['name']}/\
archive/${dict['file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}"
    koopa_cd "${dict['name']}-${dict['version']}"
    shared_cmake_args=(
        # Standard CMake arguments ---------------------------------------------
        # > "-DCMAKE_INSTALL_RPATH=${dict['prefix']}/lib"
        '-DCMAKE_BUILD_TYPE=Release'
        "-DCMAKE_CXX_FLAGS=${CPPFLAGS:-}"
        "-DCMAKE_EXE_LINKER_FLAGS=${LDFLAGS:-}"
        '-DCMAKE_INSTALL_INCLUDEDIR=include'
        '-DCMAKE_INSTALL_LIBDIR=lib'
        "-DCMAKE_INSTALL_PREFIX=${dict['prefix']}"
        "-DCMAKE_MODULE_LINKER_FLAGS=${LDFLAGS:-}"
        "-DCMAKE_SHARED_LINKER_FLAGS=${LDFLAGS:-}"
        '-DCMAKE_VERBOSE_MAKEFILE=ON'
        # Build options --------------------------------------------------------
        '-DSPDLOG_BUILD_BENCH=OFF'
        '-DSPDLOG_BUILD_TESTS=ON'
        '-DSPDLOG_FMT_EXTERNAL=ON'
        # Dependency paths -----------------------------------------------------
        # > '-Dpkg_config_libdir=lib'
        "-Dfmt_DIR=${dict['fmt']}/lib/cmake/fmt"
    )
    koopa_print_env
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
    koopa_dl 'Shared CMake args' "${shared_cmake_args[*]}"
    "${app['cmake']}" -LH \
        -S . \
        -B 'build-shared' \
        "${shared_cmake_args[@]}" \
        -DSPDLOG_BUILD_SHARED='ON'
    "${app['cmake']}" \
        --build 'build-shared' \
        --parallel "${dict['jobs']}"
    "${app['ctest']}" \
        --parallel "${dict['jobs']}" \
        --stop-on-failure \
        --test-dir 'build-shared' \
        --verbose
    "${app['cmake']}" --install 'build-shared'
    # Static build isn't necessary, and can have build issues on Linux ARM.
    # > "${app['cmake']}" -LH \
    # >     -S . \
    # >     -B 'build-static' \
    # >     "${shared_cmake_args[@]}" \
    # >     -DSPDLOG_BUILD_SHARED='OFF'
    # > "${app['cmake']}" \
    # >     --build 'build-static' \
    # >     --parallel "${dict['jobs']}"
    # > "${app['ctest']}" \
    # >     --parallel "${dict['jobs']}" \
    # >     --stop-on-failure \
    # >     --test-dir 'build-static' \
    # >     --verbose
    # > "${app['cmake']}" --install 'build-static'
    # > koopa_assert_is_file "${dict['prefix']}/lib/libspdlog.a"
    return 0
}
