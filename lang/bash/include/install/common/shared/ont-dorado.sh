#!/usr/bin/env bash

# FIXME Need to require to libaec now.
# // Path to a library.
# AEC_DLL:FILEPATH=AEC_DLL-NOTFOUND
# https://github.com/MathisRosenhauer/libaec

# NOTE Alternatively, can install using prebuilt binaries:
# - https://cdn.oxfordnanoportal.com/software/analysis/dorado-0.3.1-linux-arm64.tar.gz
# - https://cdn.oxfordnanoportal.com/software/analysis/dorado-0.3.1-linux-x64.tar.gz
# - https://cdn.oxfordnanoportal.com/software/analysis/dorado-0.3.1-osx-arm64.tar.gz

main() {
    # """
    # Install ONT dorado basecaller.
    # @note Updated 2023-06-27.
    # """
    local -A app cmake dict
    local -a build_deps deps
    build_deps=('autoconf' 'automake' 'git')
    deps=('hdf5' 'openssl3' 'zstd')
    koopa_activate_app --build-only "${build_deps[@]}"
    koopa_activate_app "${deps[@]}"
    app['git']="$(koopa_locate_git)"
    koopa_assert_is_executable "${app[@]}"
    dict['openssl']="$(koopa_app_prefix 'openssl3')"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['shared_ext']="$(koopa_shared_ext)"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['zstd']="$(koopa_app_prefix 'zstd')"
    cmake['openssl_crypto_library']="${dict['openssl']}/lib/\
libcrypto.${dict['shared_ext']}"
    cmake['openssl_include_dir']="${dict['openssl']}/include"
    cmake['openssl_root_dir']="${dict['openssl']}"
    cmake['openssl_ssl_library']="${dict['openssl']}/lib/\
libssl.${dict['shared_ext']}"
    cmake['zstd_include_dir']="${dict['zstd']}/include"
    cmake['zstd_library']="${dict['zstd']}/lib/\
libzstd.${dict['shared_ext']}"
    koopa_assert_is_dir \
        "${cmake['openssl_include_dir']}" \
        "${cmake['openssl_root_dir']}" \
        "${cmake['zstd_include_dir']}"
    koopa_assert_is_file \
        "${cmake['openssl_crypto_library']}" \
        "${cmake['openssl_ssl_library']}" \
        "${cmake['zstd_library']}"
    cmake_args=(
        # Build options --------------------------------------------------------
        '-DGIT_SUBMODULE=ON'
        # Dependency paths -----------------------------------------------------
        # > "-DMKLDNN_DIR=PATH"
        # > "-DMKL_DIR=PATH"
        # > "-Dkineto_LIBRARY=PATH"
        "-DOPENSSL_CRYPTO_LIBRARY=${cmake['openssl_crypto_library']}"
        "-DOPENSSL_INCLUDE_DIR=${cmake['openssl_include_dir']}"
        "-DOPENSSL_ROOT_DIR=${cmake['openssl_root_dir']}"
        "-DOPENSSL_SSL_LIBRARY=${cmake['openssl_ssl_library']}"
        "-DZSTD_INCLUDE_DIR=${cmake['zstd_include_dir']}"
        "-DZSTD_LIBRARY_RELEASE=${cmake['zstd_library']}"
    )
    # How to build with CUDA toolkit on Linux.
    # > if koopa_is_linux
    # > then
    # >     cmake_args+=(
    # >         "-DCUDAToolkit_NVCC_EXECUTABLE=PATH"
    # >         "-DCUDAToolkit_SENTINEL_FILE=PATH"
    # >     )
    # > fi
    "${app['git']}" clone \
        --depth 1 \
        --branch "v${dict['version']}" \
        'https://github.com/nanoporetech/dorado.git' \
        'src'
    koopa_cd 'src'
    koopa_cmake_build --prefix="${dict['prefix']}" "${cmake_args[@]}"
    return 0
}
