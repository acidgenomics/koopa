#!/usr/bin/env bash

# NOTE Currently hitting ninja-related build error on Ubuntu 20.
# https://github.com/mamba-org/mamba/issues/2410

main() {
    # """
    # Install micromamba.
    # @note Updated 2023-03-31.
    #
    # Consider setting 'CMAKE_PREFIX_PATH' for CMake configuration.
    # bzip2 and zstd requirement added in 1.2.0 release.
    #
    # @seealso
    # - https://mamba.readthedocs.io/en/latest/user_guide/micromamba.html
    # - https://mamba.readthedocs.io/en/latest/developer_zone/build_locally.html
    # - https://mamba.readthedocs.io/en/latest/installation.html
    # - https://github.com/mamba-org/mamba/blob/main/libmamba/CMakeLists.txt
    # - https://github.com/mamba-org/mamba/blob/main/libmamba/
    #     environment-dev.yml
    # - https://man.archlinux.org/man/extra/cmake/cmake-env-variables.7.en
    # - https://github.com/conda-forge/mamba-feedstock/blob/main/
    #     recipe/build_mamba.sh
    # - https://github.com/Homebrew/brew/blob/3.6.14/Library/
    #     Homebrew/formula.rb#L1539
    # """
    local app cmake_args deps dict
    local -A app dict
    deps=(
        'bzip2'
        'zstd'
        'cli11'
        'curl'
        'fmt'
        'libarchive'
        'libsolv'
        'nlohmann-json'
        'openssl3'
        'python3.11'
        'reproc'
        # NOTE Enabling spdlog here currently causes a cryptic linker error.
        # > 'spdlog'
        'termcolor'
        'tl-expected'
        'yaml-cpp'
    )
    koopa_activate_app "${deps[@]}"
    app['python']="$(koopa_locate_python311 --realpath)"
    [[ -x "${app['python']}" ]] || exit 1
    dict['bzip2']="$(koopa_app_prefix 'bzip2')"
    dict['curl']="$(koopa_app_prefix 'curl')"
    dict['fmt']="$(koopa_app_prefix 'fmt')"
    dict['libarchive']="$(koopa_app_prefix 'libarchive')"
    dict['libsolv']="$(koopa_app_prefix 'libsolv')"
    dict['openssl']="$(koopa_app_prefix 'openssl3')"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['reproc']="$(koopa_app_prefix 'reproc')"
    dict['shared_ext']="$(koopa_shared_ext)"
    dict['spdlog']="$(koopa_app_prefix 'spdlog')"
    dict['tl_expected']="$(koopa_app_prefix 'tl-expected')"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['yaml_cpp']="$(koopa_app_prefix 'yaml-cpp')"
    dict['zstd']="$(koopa_app_prefix 'zstd')"
    koopa_assert_is_dir \
        "${dict['bzip2']}" \
        "${dict['curl']}" \
        "${dict['fmt']}" \
        "${dict['libarchive']}" \
        "${dict['libsolv']}" \
        "${dict['openssl']}" \
        "${dict['reproc']}" \
        "${dict['spdlog']}" \
        "${dict['tl_expected']}" \
        "${dict['yaml_cpp']}" \
        "${dict['zstd']}"
    cmake_args=(
        # Build settings -------------------------------------------------------
        '-DBUILD_SHARED=ON'
        '-DBUILD_LIBMAMBA=ON'
        '-DBUILD_LIBMAMBAPY=OFF'
        '-DBUILD_LIBMAMBA_TESTS=OFF'
        '-DBUILD_MAMBA_PACKAGE=OFF'
        '-DBUILD_MICROMAMBA=ON'
        '-DMICROMAMBA_LINKAGE=DYNAMIC'
        # Required dependencies ------------------------------------------------
        "-DBZIP2_INCLUDE_DIR=${dict['bzip2']}/include"
        "-DBZIP2_LIBRARIES=${dict['bzip2']}/lib/libbz2.${dict['shared_ext']}"
        "-DBZIP2_LIBRARY=${dict['bzip2']}/lib/libbz2.${dict['shared_ext']}"
        "-DCURL_INCLUDE_DIR=${dict['curl']}/include"
        "-DCURL_LIBRARY=${dict['curl']}/lib/libcurl.${dict['shared_ext']}"
        "-DLibArchive_INCLUDE_DIR=${dict['libarchive']}/include" \
        "-DLibArchive_LIBRARY=${dict['libarchive']}/lib/\
libarchive.${dict['shared_ext']}"
        "-DLIBSOLVEXT_LIBRARIES=${dict['libsolv']}/lib/\
libsolvext.${dict['shared_ext']}"
        "-DLIBSOLV_LIBRARIES=${dict['libsolv']}/lib/\
libsolv.${dict['shared_ext']}"
        "-DOPENSSL_ROOT_DIR=${dict['openssl']}"
        "-DPython3_EXECUTABLE=${app['python']}"
        # Additional CMake configuration ---------------------------------------
        "-Dfmt_DIR=${dict['fmt']}/lib/cmake/fmt"
        "-Dreproc++_DIR=${dict['reproc']}/lib/cmake/reproc++"
        "-Dreproc_DIR=${dict['reproc']}/lib/cmake/reproc"
        "-Dspdlog_DIR=${dict['spdlog']}/lib/cmake/spdlog"
        "-Dtl-expected_DIR=${dict['tl_expected']}/share/cmake/tl-expected"
        "-Dyaml-cpp_DIR=${dict['yaml_cpp']}/share/cmake/yaml-cpp"
        "-Dzstd_DIR=${dict['zstd']}/lib/cmake/zstd"
    )
    dict['url']="https://github.com/mamba-org/mamba/archive/refs/\
tags/${dict['version']}.tar.gz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    koopa_cmake_build \
        --ninja \
        --prefix="${dict['prefix']}" \
        "${cmake_args[@]}"
    return 0
}
