#!/usr/bin/env bash

# Consider adding LLVM requirement:
# -- Could NOT find ClangTools (missing: CLANG_FORMAT_BIN CLANG_TIDY_BIN)

main() {
    # """
    # Install Apache Arrow.
    # @note Updated 2023-05-31.
    #
    # @seealso
    # - https://arrow.apache.org/install/
    # - https://arrow.apache.org/docs/developers/cpp/building.html
    # - https://formulae.brew.sh/formula/apache-arrow
    # - https://github.com/conda-forge/arrow-cpp-feedstock
    # """
    local -A dict
    local -a cmake_args
    #local -a deps
    #deps=(
    #    'boost'
    #    'brotli'
    #    'bzip2'
    #    'lz4'
    #    'utf8proc'
    #    'zlib'
    #    'zstd'
    #)
    koopa_activate_app --build-only 'pkg-config'
    #koopa_activate_app "${deps[@]}"
    #dict['boost']="$(koopa_app_prefix 'boost')"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    cmake_args=(
        '-DARROW_DEPENDENCY_SOURCE=BUNDLED'
        #-DCMAKE_INSTALL_RPATH=#{rpath}
        # Build options --------------------------------------------------------
        # > '-DARROW_INSTALL_NAME_RPATH=OFF'
        #'-DARROW_BUILD_STATIC=OFF'
        #'-DARROW_BUILD_UTILITIES=ON'
        #'-DARROW_COMPUTE=ON'
        #'-DARROW_CSV=ON'
        #'-DARROW_CUDA=OFF'
        #'-DARROW_DATASET=ON'
        #'-DARROW_EXTRA_ERROR_CONTEXT=ON'
        #'-DARROW_FILESYSTEM=ON'
        #'-DARROW_FLIGHT=ON'
        #'-DARROW_FLIGHT_SQL=ON'
        #'-DARROW_GANDIVA=ON'
        #'-DARROW_GANDIVA_JAVA=OFF'
        #'-DARROW_GCS=OFF'
        #'-DARROW_HDFS=OFF'
        #'-DARROW_JEMALLOC=ON'
        #'-DARROW_JSON=ON'
        #'-DARROW_ORC=ON'
        #'-DARROW_PARQUET=ON'
        #'-DARROW_S3=ON'
        #'-DARROW_TENSORFLOW=OFF'
        #'-DARROW_WITH_BROTLI=ON'
        #'-DARROW_WITH_BZ2=ON'
        #'-DARROW_WITH_LZ4=ON'
        #'-DARROW_WITH_RE2=ON'
        #'-DARROW_WITH_SNAPPY=OFF'
        #'-DARROW_WITH_UTF8PROC=ON'
        #'-DARROW_WITH_ZLIB=ON'
        #'-DARROW_WITH_ZSTD=ON'
        # Dependency paths -----------------------------------------------------
        #"-DBOOST_ROOT=${dict['boost']}"
    )
    #if ! koopa_is_aarch64
    #then
    #    cmake_args+=('-DARROW_MIMALLOC=ON')
    #fi
    # Homebrew configuration:
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
