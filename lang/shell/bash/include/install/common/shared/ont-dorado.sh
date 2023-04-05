#!/usr/bin/env bash

main() {
    # """
    # Install ONT dorado basecaller.
    # @note Updated 2023-04-04.
    # """
    local app build_deps cmake deps dict
    declare -A app cmake dict
    koopa_assert_has_no_args "$#"
    build_deps=('autoconf' 'automake' 'git')
    deps=('hdf5' 'openssl3' 'zstd')
    koopa_activate_app --build-only "${build_deps[@]}"
    koopa_activate_app "${deps[@]}"
    app['git']="$(koopa_locate_git)"
    [[ -x "${app['git']}" ]] || exit 1
    dict['openssl']="$(koopa_app_prefix 'openssl3')"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['shared_ext']="$(koopa_shared_ext)"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['zstd']="$(koopa_app_prefix 'zstd')"
    cmake['openssl_root_dir']="${dict['openssl']}"
    cmake['zstd_include_dir']="${dict['zstd']}/include"
    cmake['zstd_library']="${dict['zstd']}/lib/\
libzstd.${dict['shared_ext']}"
    cmake_args=(
        # Build options --------------------------------------------------------
        '-DGIT_SUBMODULE=ON'
        # Dependency paths -----------------------------------------------------
        # > "-DMKLDNN_DIR=FIXME"
        # > "-DMKL_DIR=FIXME"
        # > "-Dkineto_LIBRARY=FIXME"
        "-DOPENSSL_ROOT_DIR=${cmake['openssl_root_dir']}"
        "-DZSTD_INCLUDE_DIR=${cmake['zstd_include_dir']}"
        "-DZSTD_LIBRARY_RELEASE=${cmake['zstd_library']}"
    )
# How to build with CUDA toolkit on Linux.
# >     if koopa_is_linux
# >     then
# >         cmake_args+=(
# >             "-DCUDAToolkit_NVCC_EXECUTABLE=FIXME"
# >             "-DCUDAToolkit_SENTINEL_FILE=FIXME"
# >         )
# >     fi
    "${app['git']}" clone \
        --depth 1 \
        --branch "v${dict['version']}" \
        'https://github.com/nanoporetech/dorado.git' \
        'src'
    koopa_cd 'src'
    koopa_cmake_build --prefix="${dict['prefix']}" "${cmake_args[@]}"
    return 0
}
