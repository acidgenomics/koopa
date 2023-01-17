#!/usr/bin/env bash

# FIXME Now seeing these build issues with 1.2.0:
#
#  Manually-specified variables were not used by the project:
#    pybind11_DIR

#  IMPORTED_LOCATION not set for imported target "BZip2::BZip2" configuration
#  "Release".

# https://github.com/samtools/htslib/issues/696

main() {
    # """
    # Install micromamba.
    # @note Updated 2023-01-17.
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
    local app build_deps cmake_args deps dict
    build_deps=('ninja')
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
        # > 'pybind11'
        'python'
        'reproc'
        # NOTE Enabling spdlog here currently causes a cryptic linker error.
        # > 'spdlog'
        'termcolor'
        'tl-expected'
        'yaml-cpp'
    )
    koopa_activate_app --build-only "${build_deps[@]}"
    koopa_activate_app "${deps[@]}"
    declare -A app=(
        ['cmake']="$(koopa_locate_cmake)"
        ['python']="$(koopa_locate_python --realpath)"
    )
    [[ -x "${app['cmake']}" ]] || return 1
    [[ -x "${app['python']}" ]] || return 1
    declare -A dict=(
        ['bzip2']="$(koopa_app_prefix 'bzip2')"
        ['curl']="$(koopa_app_prefix 'curl')"
        ['fmt']="$(koopa_app_prefix 'fmt')"
        ['jobs']="$(koopa_cpu_count)"
        ['libarchive']="$(koopa_app_prefix 'libarchive')"
        ['libsolv']="$(koopa_app_prefix 'libsolv')"
        ['name']='mamba'
        ['openssl']="$(koopa_app_prefix 'openssl3')"
        ['prefix']="${KOOPA_INSTALL_PREFIX:?}"
        # > ['pybind11']="$(koopa_app_prefix 'pybind11')"
        ['reproc']="$(koopa_app_prefix 'reproc')"
        ['shared_ext']="$(koopa_shared_ext)"
        ['spdlog']="$(koopa_app_prefix 'spdlog')"
        ['tl_expected']="$(koopa_app_prefix 'tl-expected')"
        ['version']="${KOOPA_INSTALL_VERSION:?}"
        ['yaml_cpp']="$(koopa_app_prefix 'yaml-cpp')"
        ['zstd']="$(koopa_app_prefix 'zstd')"
    )
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
    case "${dict['version']}" in
        '1.2.0')
            dict['date_tag']='2023.01.16'
            ;;
        '1.1.0')
            dict['date_tag']='2022.11.25'
            ;;
        '1.0.0')
            dict['date_tag']='2022.11.01'
            ;;
        '0.27.0')
            dict['date_tag']='2022.10.04'
            ;;
    esac
    dict['file']="${dict['date_tag']}.tar.gz"
    dict['url']="https://github.com/mamba-org/mamba/archive/refs/\
tags/${dict['file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}"
    koopa_cd "${dict['name']}-${dict['date_tag']}"
    cmake_args=(
        # Standard CMake arguments ---------------------------------------------
        '-DCMAKE_BUILD_TYPE=Release'
        "-DCMAKE_CXX_FLAGS=${CPPFLAGS:-}"
        "-DCMAKE_C_FLAGS=${CFLAGS:-}"
        "-DCMAKE_EXE_LINKER_FLAGS=${LDFLAGS:-}"
        "-DCMAKE_INSTALL_PREFIX=${dict['prefix']}"
        "-DCMAKE_INSTALL_RPATH=${dict['prefix']}/lib"
        "-DCMAKE_MODULE_LINKER_FLAGS=${LDFLAGS:-}"
        "-DCMAKE_SHARED_LINKER_FLAGS=${LDFLAGS:-}"
        '-G' 'Ninja'
        # > -Wno-dev
        # Mamba build settings -------------------------------------------------
        '-DBUILD_SHARED=ON'
        '-DBUILD_LIBMAMBA=ON'
        '-DBUILD_LIBMAMBAPY=OFF'
        '-DBUILD_LIBMAMBA_TESTS=OFF'
        '-DBUILD_MAMBA_PACKAGE=OFF'
        '-DBUILD_MICROMAMBA=ON'
        '-DMICROMAMBA_LINKAGE=DYNAMIC'
        # Required dependencies ------------------------------------------------
        "-DCMAKE_PREFIX_PATH=${dict['fmt']}:${dict['reproc']}:${dict['spdlog']}:${dict['tl_expected']}:${dict['yaml_cpp']}:${dict['zstd']}"
        "-DBZIP2_INCLUDE_DIR=${dict['bzip2']}/include"
        "-DBZIP2_LIBRARIES=${dict['bzip2']}/lib/libbz2.${dict['shared_ext']}"
        # This is also needed, otherwise CMake won't detect bzip2 correctly.
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
        # Needed for 'libmamba/CMakeLists.txt'.
        "-DPython3_EXECUTABLE=${app['python']}"
        # Needed for 'libmambapy/CMakeLists.txt'.
        # > "-DPython_EXECUTABLE=${app['python']}"
        # CMake configuration --------------------------------------------------
        "-Dfmt_DIR=${dict['fmt']}/lib/cmake/fmt"
        # > "-Dpybind11_DIR=${dict['pybind11']}/share/cmake/pybind11"
        "-Dreproc++_DIR=${dict['reproc']}/lib/cmake/reproc++"
        "-Dreproc_DIR=${dict['reproc']}/lib/cmake/reproc"
        "-Dspdlog_DIR=${dict['spdlog']}/lib/cmake/spdlog"
        "-Dtl-expected_DIR=${dict['tl_expected']}/share/cmake/tl-expected"
        "-Dyaml-cpp_DIR=${dict['yaml_cpp']}/share/cmake/yaml-cpp"
        "-Dzstd_DIR=${dict['zstd']}/lib/cmake/zstd"
    )
    koopa_print_env
    koopa_dl 'CMake args' "${cmake_args[*]}"
    "${app['cmake']}" -LH \
        -S . \
        -B 'build' \
        "${cmake_args[@]}"
    "${app['cmake']}" \
        --build 'build' \
        --parallel "${dict['jobs']}"
    "${app['cmake']}" --install 'build'
    return 0
}
