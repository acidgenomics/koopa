#!/usr/bin/env bash

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
    local -a cmake_args deps
    deps=('boost')
    koopa_activate_app --build-only 'pkg-config'
    koopa_activate_app "${deps[@]}"
    dict['boost']="$(koopa_app_prefix 'boost')"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    cmake_args=(
        # Build options --------------------------------------------------------
        '-DARROW_BUILD_STATIC=OFF'
        '-DARROW_DEPENDENCY_SOURCE=SYSTEM'
        '-DARROW_EXTRA_ERROR_CONTEXT=ON'
        # Optional components --------------------------------------------------
        #-DARROW_BUILD_UTILITIES=ON : Build Arrow commandline utilities
        #-DARROW_COMPUTE=ON: Build all computational kernel functions
        #-DARROW_CSV=ON: CSV reader module
        #-DARROW_CUDA=ON: CUDA integration for GPU development. Depends on NVIDIA CUDA toolkit. The CUDA toolchain used to build the library can be customized by using the $CUDA_HOME environment variable.
        #-DARROW_DATASET=ON: Dataset API, implies the Filesystem API
        #-DARROW_FILESYSTEM=ON: Filesystem API for accessing local and remote filesystems
        #-DARROW_FLIGHT=ON: Arrow Flight RPC system, which depends at least on gRPC
        #-DARROW_FLIGHT_SQL=ON: Arrow Flight SQL
        #-DARROW_GANDIVA=ON: Gandiva expression compiler, depends on LLVM, Protocol Buffers, and re2
        #-DARROW_GANDIVA_JAVA=ON: Gandiva JNI bindings for Java
        #-DARROW_GCS=ON: Build Arrow with GCS support (requires the GCloud SDK for C++)
        #-DARROW_HDFS=ON: Arrow integration with libhdfs for accessing the Hadoop Filesystem
        #-DARROW_JEMALLOC=ON: Build the Arrow jemalloc-based allocator, on by default
        #-DARROW_JSON=ON: JSON reader module
        #-DARROW_MIMALLOC=ON: Build the Arrow mimalloc-based allocator
        #-DARROW_ORC=ON: Arrow integration with Apache ORC
        #-DARROW_PARQUET=ON: Apache Parquet libraries and Arrow integration
        #-DPARQUET_REQUIRE_ENCRYPTION=ON: Parquet Modular Encryption
        #-DARROW_S3=ON: Support for Amazon S3-compatible filesystems
        #-DARROW_WITH_RE2=ON Build with support for regular expressions using the re2 library, on by default and used when ARROW_COMPUTE or ARROW_GANDIVA is ON
        #-DARROW_WITH_UTF8PROC=ON: Build with support for Unicode properties using the utf8proc library, on by default and used when ARROW_COMPUTE or ARROW_GANDIVA is ON
        #-DARROW_TENSORFLOW=ON: Build Arrow with TensorFlow support enabled
        # Compression options --------------------------------------------------
        #-DARROW_WITH_BROTLI=ON: Build support for Brotli compression
        #-DARROW_WITH_BZ2=ON: Build support for BZ2 compression
        #-DARROW_WITH_LZ4=ON: Build support for lz4 compression
        #-DARROW_WITH_SNAPPY=ON: Build support for Snappy compression
        #-DARROW_WITH_ZLIB=ON: Build support for zlib (gzip) compression
        #-DARROW_WITH_ZSTD=ON: Build support for ZSTD compression
        # Optional targets -----------------------------------------------------
        #-DARROW_BUILD_BENCHMARKS=ON: Build executable benchmarks.
        #-DARROW_BUILD_EXAMPLES=ON: Build examples of using the Arrow C++ API.
        #-DARROW_BUILD_INTEGRATION=ON: Build additional executables that are used to exercise protocol interoperability between the different Arrow implementations.
        #-DARROW_BUILD_UTILITIES=ON: Build executable utilities.
        #-DARROW_BUILD_TESTS=ON: Build executable unit tests.
        #-DARROW_ENABLE_TIMING_TESTS=ON: If building unit tests, enable those unit tests that rely on wall-clock timing (this flag is disabled on CI because it can make test results flaky).
        #-DARROW_FUZZING=ON: Build fuzz targets and related executables.
        # Optional checks ------------------------------------------------------
        #-DARROW_USE_ASAN=ON: Enable Address Sanitizer to check for memory leaks, buffer overflows or other kinds of memory management issues.
        #-DARROW_USE_TSAN=ON: Enable Thread Sanitizer to check for races in multi-threaded code.
        #-DARROW_USE_UBSAN=ON: Enable Undefined Behavior Sanitizer to check for situations which trigger C++ undefined behavior.
        # Dependency paths -----------------------------------------------------
        "-DBOOST_ROOT=${dict['boost']}"
    )

# Homebrew configuration:
#-DCMAKE_INSTALL_RPATH=#{rpath}
#-DARROW_ACERO=ON
#-DARROW_COMPUTE=ON
#-DARROW_CSV=ON
#-DARROW_DATASET=ON
#-DARROW_FILESYSTEM=ON
#-DARROW_FLIGHT=ON
#-DARROW_FLIGHT_SQL=ON
#-DARROW_GANDIVA=ON
#-DARROW_HDFS=ON
#-DARROW_INSTALL_NAME_RPATH=OFF
#-DARROW_JSON=ON
#-DARROW_ORC=ON
#-DARROW_PARQUET=ON
#-DARROW_PROTOBUF_USE_SHARED=ON
#-DARROW_S3=ON
#-DARROW_WITH_BROTLI=ON
#-DARROW_WITH_BZ2=ON
#-DARROW_WITH_LZ4=ON
#-DARROW_WITH_SNAPPY=ON
#-DARROW_WITH_UTF8PROC=ON
#-DARROW_WITH_ZLIB=ON
#-DARROW_WITH_ZSTD=ON

    if ! koopa_is_aarch64
    then
        cmake_args+=('-DARROW_MIMALLOC=ON')
    fi
    dict['url']="https://www.apache.org/dyn/closer.lua?action=download&\
filename=arrow/arrow-${dict['version']}/apache-arrow-${dict['version']}.tar.gz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    koopa_cmake_build --prefix="${dict['prefix']}" "${cmake_args[@]}"
    return 0
}
