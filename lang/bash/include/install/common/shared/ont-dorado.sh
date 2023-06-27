#!/usr/bin/env bash

# FIXME We may be running into build issues here that require us to rebuild
# HDF5 using CMake instead of Make. In that case, set HDF5_DIR to the
# hdf5 cmake directory.

# NOTE Alternatively, can install using prebuilt binaries:
# - https://cdn.oxfordnanoportal.com/software/analysis/dorado-0.3.1-linux-arm64.tar.gz
# - https://cdn.oxfordnanoportal.com/software/analysis/dorado-0.3.1-linux-x64.tar.gz
# - https://cdn.oxfordnanoportal.com/software/analysis/dorado-0.3.1-osx-arm64.tar.gz

main() {
    # """
    # Install ONT dorado basecaller.
    # @note Updated 2023-06-27.
    #
    # @seealso
    # - https://github.com/nanoporetech/dorado/blob/master/CMakeLists.txt
    # - https://github.com/nanoporetech/dorado/blob/master/cmake/HDF5.cmake
    # """
    local -A app cmake dict
    local -a build_deps deps
    build_deps=('autoconf' 'automake' 'git')
    deps=(
        'curl'
        'hdf5'
        'libaec'
        'openssl3'
        'zlib'
        'zstd'
    )
    koopa_activate_app --build-only "${build_deps[@]}"
    koopa_activate_app "${deps[@]}"
    app['git']="$(koopa_locate_git)"
    koopa_assert_is_executable "${app[@]}"
    dict['curl']="$(koopa_app_prefix 'curl')"
    dict['hdf5']="$(koopa_app_prefix 'hdf5')"
    dict['libaec']="$(koopa_app_prefix 'libaec')"
    dict['openssl']="$(koopa_app_prefix 'openssl3')"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['shared_ext']="$(koopa_shared_ext)"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['zlib']="$(koopa_app_prefix 'zlib')"
    dict['zstd']="$(koopa_app_prefix 'zstd')"
    cmake['aec_dll']="${dict['libaec']}/lib/libaec.${dict['shared_ext']}"
    cmake['curl_include_dir']="${dict['curl']}/include"
    cmake['curl_library']="${dict['curl']}/lib/libcurl.${dict['shared_ext']}"
    cmake['hdf5_root']="${dict['hdf5']}"
    cmake['openssl_crypto_library']="${dict['openssl']}/lib/\
libcrypto.${dict['shared_ext']}"
    cmake['openssl_include_dir']="${dict['openssl']}/include"
    cmake['openssl_root_dir']="${dict['openssl']}"
    cmake['openssl_ssl_library']="${dict['openssl']}/lib/\
libssl.${dict['shared_ext']}"
    cmake['sz_dll']="${dict['libaec']}/lib/libsz.${dict['shared_ext']}"
    cmake['zlib_include_dir']="${dict['zlib']}/include"
    cmake['zlib_library']="${dict['zlib']}/lib/libz.${dict['shared_ext']}"
    cmake['zstd_include_dir']="${dict['zstd']}/include"
    cmake['zstd_library']="${dict['zstd']}/lib/\
libzstd.${dict['shared_ext']}"
    koopa_assert_is_dir \
        "${cmake['curl_include_dir']}" \
        "${cmake['hdf5_root']}" \
        "${cmake['openssl_include_dir']}" \
        "${cmake['openssl_root_dir']}" \
        "${cmake['zlib_include_dir']}" \
        "${cmake['zstd_include_dir']}"
    koopa_assert_is_file \
        "${cmake['aec_dll']}" \
        "${cmake['curl_library']}" \
        "${cmake['openssl_crypto_library']}" \
        "${cmake['openssl_ssl_library']}" \
        "${cmake['sz_dll']}" \
        "${cmake['zlib_library']}" \
        "${cmake['zstd_library']}"
    cmake_args=(
        # Build options --------------------------------------------------------
        # > '-DBUILD_TZ_LIB=ON'
        # > '-DMZ_FETCH_LIBS=ON'
        # > '-DMZ_FORCE_FETCH_LIBS=ON'
        # > '-DBUILD_SHARED_LIBS=ON'
        # > '-DGIT_SUBMODULE=ON'
        # Dependency paths -----------------------------------------------------
        # > "-DMKLDNN_DIR=PATH"
        # > "-DMKL_DIR=PATH"
        # > "-Dkineto_LIBRARY=PATH"
        "-DAEC_DLL=${cmake['aec_dll']}"
        "-DCURL_INCLUDE_DIR=${cmake['curl_include_dir']}"
        "-DCURL_LIBRARY=${cmake['curl_library']}"
        # > "-DHDF5_ROOT=${cmake['hdf5_root']}" # FIXME
        "-DHDF5_INCLUDE_DIRS=${dict['hdf5']}/include"
        "-DHDF5_LIBRARIES=${dict['hdf5']}/lib/libhdf5.${dict['shared_ext']}"
        "-DOPENSSL_CRYPTO_LIBRARY=${cmake['openssl_crypto_library']}"
        "-DOPENSSL_INCLUDE_DIR=${cmake['openssl_include_dir']}"
        "-DOPENSSL_ROOT_DIR=${cmake['openssl_root_dir']}"
        "-DOPENSSL_SSL_LIBRARY=${cmake['openssl_ssl_library']}"
        "-DSZ_DLL=${cmake['sz_dll']}"
        "-DZLIB_INCLUDE_DIR=${cmake['zlib_include_dir']}"
        "-DZLIB_LIBRARY=${cmake['zlib_library']}"
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
