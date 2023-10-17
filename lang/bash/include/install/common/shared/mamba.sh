#!/usr/bin/env bash

# NOTE Currently hitting ninja-related build error on Ubuntu 20.
# https://github.com/mamba-org/mamba/issues/2410

main() {
    # """
    # Install micromamba.
    # @note Updated 2023-10-17.
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
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/
    #     micromamba.rb
    # - https://github.com/Homebrew/brew/blob/3.6.14/Library/
    #     Homebrew/formula.rb#L1539
    # """
    local -A app cmake dict
    local -a cmake_args deps
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
        'python3.12'
        'reproc'
        # NOTE Enabling spdlog here currently causes the install to fail.
        # > 'spdlog'
        'termcolor'
        'tl-expected'
        'yaml-cpp'
    )
    koopa_activate_app "${deps[@]}"
    app['python']="$(koopa_locate_python312 --realpath)"
    koopa_assert_is_executable "${app[@]}"
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
    cmake['bzip2_include_dir']="${dict['bzip2']}/include"
    cmake['bzip2_libraries']="${dict['bzip2']}/lib/libbz2.${dict['shared_ext']}"
    cmake['bzip2_library']="${dict['bzip2']}/lib/libbz2.${dict['shared_ext']}"
    cmake['curl_include_dir']="${dict['curl']}/include"
    cmake['curl_library']="${dict['curl']}/lib/libcurl.${dict['shared_ext']}"
    cmake['fmt_dir']="${dict['fmt']}/lib/cmake/fmt"
    cmake['libarchive_include_dir']="${dict['libarchive']}/include"
    cmake['libarchive_library']="${dict['libarchive']}/lib/\
libarchive.${dict['shared_ext']}"
    cmake['libsolv_libraries']="${dict['libsolv']}/lib/\
libsolv.${dict['shared_ext']}"
    cmake['libsolvext_libraries']="${dict['libsolv']}/lib/\
libsolvext.${dict['shared_ext']}"
    cmake['openssl_root_dir']="${dict['openssl']}"
    cmake['python3_executable']="${app['python']}"
    cmake['reproc_dir']="${dict['reproc']}/lib/cmake/reproc"
    cmake['reprocxx_dir']="${dict['reproc']}/lib/cmake/reproc++"
    cmake['spdlog_dir']="${dict['spdlog']}/lib/cmake/spdlog"
    cmake['tl_expected_dir']="${dict['tl_expected']}/share/cmake/tl-expected"
    cmake['yaml_cpp_dir']="${dict['yaml_cpp']}/lib/cmake/yaml-cpp"
    cmake['zstd_dir']="${dict['zstd']}/lib/cmake/zstd"
    koopa_assert_is_dir \
        "${cmake['bzip2_include_dir']}" \
        "${cmake['curl_include_dir']}" \
        "${cmake['fmt_dir']}" \
        "${cmake['libarchive_include_dir']}" \
        "${cmake['openssl_root_dir']}" \
        "${cmake['reproc_dir']}" \
        "${cmake['reprocxx_dir']}" \
        "${cmake['spdlog_dir']}" \
        "${cmake['tl_expected_dir']}" \
        "${cmake['yaml_cpp_dir']}" \
        "${cmake['zstd_dir']}"
    koopa_assert_is_file \
        "${cmake['bzip2_libraries']}" \
        "${cmake['bzip2_library']}" \
        "${cmake['curl_library']}" \
        "${cmake['libarchive_library']}" \
        "${cmake['libsolv_libraries']}" \
        "${cmake['libsolvext_libraries']}" \
        "${cmake['python3_executable']}"
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
        "-DBZIP2_INCLUDE_DIR=${cmake['bzip2_include_dir']}"
        "-DBZIP2_LIBRARIES=${cmake['bzip2_libraries']}"
        "-DBZIP2_LIBRARY=${cmake['bzip2_library']}"
        "-DCURL_INCLUDE_DIR=${cmake['curl_include_dir']}"
        "-DCURL_LIBRARY=${cmake['curl_library']}"
        "-DLibArchive_INCLUDE_DIR=${cmake['libarchive_include_dir']}"
        "-DLibArchive_LIBRARY=${cmake['libarchive_library']}"
        "-DLIBSOLV_LIBRARIES=${cmake['libsolv_libraries']}"
        "-DLIBSOLVEXT_LIBRARIES=${cmake['libsolvext_libraries']}"
        "-DOPENSSL_ROOT_DIR=${cmake['openssl_root_dir']}"
        "-DPython3_EXECUTABLE=${cmake['python3_executable']}"
        # Additional CMake configuration ---------------------------------------
        "-Dfmt_DIR=${cmake['fmt_dir']}"
        "-Dreproc++_DIR=${cmake['reprocxx_dir']}"
        "-Dreproc_DIR=${cmake['reproc_dir']}"
        "-Dspdlog_DIR=${cmake['spdlog_dir']}"
        "-Dtl-expected_DIR=${cmake['tl_expected_dir']}"
        "-Dyaml-cpp_DIR=${cmake['yaml_cpp_dir']}"
        "-Dzstd_DIR=${cmake['zstd_dir']}"
    )
    dict['url']="https://github.com/mamba-org/mamba/archive/refs/tags/\
micromamba-${dict['version']}.tar.gz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    koopa_cmake_build \
        --ninja \
        --prefix="${dict['prefix']}" \
        "${cmake_args[@]}"
    return 0
}
