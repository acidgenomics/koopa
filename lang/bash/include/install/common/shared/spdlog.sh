#!/usr/bin/env bash

# FIXME This is failing to build on Ubuntu 22. Need to debug.

main() {
    # """
    # Install spdlog.
    # @note Updated 2024-07-06.
    #
    # @seealso
    # - https://github.com/gabime/spdlog/
    # - https://github.com/Homebrew/homebrew-core/blob/HEAD/Formula/spdlog.rb
    # - https://github.com/conda-forge/spdlog-feedstock
    # - https://raw.githubusercontent.com/archlinux/svntogit-community/
    #     packages/spdlog/trunk/PKGBUILD
    # """
    local -A cmake dict
    local -a build_deps cmake_args deps
    build_deps=('pkg-config')
    koopa_is_linux && build_deps+=('gcc')
    deps=('fmt')
    koopa_activate_app --build-only "${build_deps[@]}"
    koopa_activate_app "${deps[@]}"
    dict['fmt']="$(koopa_app_prefix 'fmt')"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    koopa_assert_is_dir "${dict['fmt']}"
    cmake['fmt_dir']="${dict['fmt']}/lib/cmake/fmt"
    koopa_assert_is_dir "${cmake['fmt_dir']}"
    cmake_args=(
        # Build options --------------------------------------------------------
        '-DSPDLOG_BUILD_BENCH=OFF'
        '-DSPDLOG_BUILD_SHARED=ON'
        '-DSPDLOG_BUILD_TESTS=ON'
        '-DSPDLOG_FMT_EXTERNAL=ON'
        # Dependency paths -----------------------------------------------------
        "-Dfmt_DIR=${cmake['fmt_dir']}"
    )
    dict['url']="https://github.com/gabime/spdlog/archive/\
v${dict['version']}.tar.gz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    koopa_cmake_build --prefix="${dict['prefix']}" "${cmake_args[@]}"
    return 0
}
