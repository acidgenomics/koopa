#!/usr/bin/env bash

# FIXME Not currently working unless we clone git repo and use submodules
#
# -- Building htslib
# CMake Error at /opt/koopa/app/cmake/3.25.2/share/cmake-3.25/Modules/ExternalProject.cmake:3115 (message):
#   No download info given for 'htslib_project' and its source directory:

main() {
    # """
    # Install ONT dorado basecaller.
    # @note Updated 2023-04-04.
    # """
    local app build_deps deps dict
    declare -A app dict
    koopa_assert_has_no_args "$#"
    build_deps=('autoconf' 'automake' 'git')
    deps=('hdf5' 'openssl3' 'zstd')
    koopa_activate_app --build-only "${build_deps[@]}"
    koopa_activate_app "${deps[@]}"
    app['git']="$(koopa_locate_git)"
    [[ -x "${app['git']}" ]] || return 1
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['openssl']="$(koopa_app_prefix 'openssl3')"
    cmake_args=(
        # Build options --------------------------------------------------------
        '-DBUILD_KOI_FROM_SOURCE=OFF'
        '-DGIT_SUBMODULE=ON'
        # Dependency paths -----------------------------------------------------
        # > "-DCUDAToolkit_NVCC_EXECUTABLE=FIXME"
        # > "-DCUDAToolkit_SENTINEL_FILE=FIXME"
        # > "-DMKLDNN_DIR=FIXME"
        # > "-DMKL_DIR=FIXME"
        # > "-Dkineto_LIBRARY=FIXME"
        "-DOPENSSL_ROOT_DIR=${dict['openssl']}"
    )
    "${app['git']}" clone \
        --depth 1 \
        --branch "v${dict['version']}" \
        'https://github.com/nanoporetech/dorado.git' \
        'src'
    koopa_cd 'src'
    koopa_cmake_build --prefix="${dict['prefix']}" "${cmake_args[@]}"
    return 0
}
