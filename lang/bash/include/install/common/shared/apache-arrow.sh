#!/usr/bin/env bash

main() {
    # """
    # Install Apache Arrow.
    # @note Updated 2024-05-17.
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
    local -a cmake_args deps
    deps=('llvm' 'openssl3')
    koopa_activate_app --build-only 'pkg-config'
    koopa_activate_app "${deps[@]}"
    dict['llvm_root']="$(koopa_app_prefix 'llvm')"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    cmake_args=(
        # > '-DARROW_INSTALL_NAME_RPATH=OFF'
        # > '-DARROW_PROTOBUF_USE_SHARED=ON'
        # > '-DARROW_WITH_BROTLI=ON'
        # > '-DARROW_WITH_BZ2=ON'
        # > '-DARROW_WITH_LZ4=ON'
        # > '-DARROW_WITH_SNAPPY=ON'
        # > '-DARROW_WITH_UTF8PROC=ON'
        # > '-DARROW_WITH_ZLIB=ON'
        # > '-DARROW_WITH_ZSTD=ON'
        '-DARROW_ACERO=ON'
        '-DARROW_COMPUTE=ON'
        '-DARROW_CSV=ON'
        '-DARROW_DATASET=ON'
        '-DARROW_DEPENDENCY_SOURCE=BUNDLED'
        '-DARROW_FILESYSTEM=ON'
        '-DARROW_FLIGHT=ON'
        '-DARROW_FLIGHT_SQL=ON'
        '-DARROW_GANDIVA=ON'
        '-DARROW_HDFS=ON'
        '-DARROW_JSON=ON'
        '-DARROW_ORC=ON'
        '-DARROW_PARQUET=ON'
        '-DARROW_S3=ON'
        '-DPARQUET_BUILD_EXECUTABLES=ON'
        # Build dependencies ---------------------------------------------------
        "-DLLVM_ROOT=${dict['llvm_root']}"
    )
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
