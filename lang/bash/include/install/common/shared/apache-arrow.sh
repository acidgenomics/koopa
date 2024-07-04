#!/usr/bin/env bash

main() {
    # """
    # Install Apache Arrow.
    # @note Updated 2024-06-26.
    #
    # @seealso
    # - https://arrow.apache.org/install/
    # - https://arrow.apache.org/docs/developers/cpp/building.html
    # - https://formulae.brew.sh/formula/apache-arrow
    # - https://github.com/conda-forge/arrow-cpp-feedstock
    # - https://arrow.apache.org/docs/python/install.html
    # - https://arrow.apache.org/docs/python/parquet.html
    # """
    local -A dict
    local -a build_deps cmake_args deps
    build_deps+=(
        'curl'
        'pkg-config'
        'python3.11'
    )
    deps+=(
        # > 'llvm'
        'openssl3'
    )
    koopa_activate_app --build-only "${build_deps[@]}"
    koopa_activate_app "${deps[@]}"
    # > dict['llvm_root']="$(koopa_app_prefix 'llvm')"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    cmake_args=(
        '-DARROW_ACERO=ON'
        '-DARROW_COMPUTE=ON'
        '-DARROW_CSV=ON'
        '-DARROW_DATASET=ON'
        '-DARROW_DEPENDENCY_SOURCE=BUNDLED'
        '-DARROW_FILESYSTEM=ON'
        '-DARROW_FLIGHT=ON'
        '-DARROW_FLIGHT_SQL=ON'
        # Building gandiva requires LLVM.
        # Currently hitting libgandiva LLVM linker errors on macOS.
        '-DARROW_GANDIVA=OFF'
        '-DARROW_HDFS=ON'
        '-DARROW_JSON=ON'
        '-DARROW_ORC=ON'
        '-DARROW_PARQUET=ON'
        # AWS related code is failing to build on Ubuntu 22, so disabling.
        '-DARROW_S3=OFF'
        '-DPARQUET_BUILD_EXECUTABLES=ON'
        # Build dependencies ---------------------------------------------------
        # > "-DLLVM_ROOT=${dict['llvm_root']}"
    )
    if ! koopa_is_aarch64
    then
        cmake_args+=('-DARROW_MIMALLOC=ON')
    fi
    dict['url']="https://www.apache.org/dyn/closer.lua?action=download&\
filename=arrow/arrow-${dict['version']}/apache-arrow-${dict['version']}.tar.gz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src/cpp'
    koopa_cmake_build \
        --ninja \
        --prefix="${dict['prefix']}" \
        "${cmake_args[@]}"
    return 0
}
