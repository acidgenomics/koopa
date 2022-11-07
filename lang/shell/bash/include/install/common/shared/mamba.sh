#!/usr/bin/env bash

# FIXME Need to define the architecture for macOS?
# [100%] Linking CXX shared library libmamba.dylib
# Undefined symbols for architecture x86_64:

main() {
    # """
    # Install micromamba.
    # @note Updated 2022-11-07.
    #
    # Consider setting 'CMAKE_PREFIX_PATH' here to include yaml-cpp.
    #
    # @seealso
    # - https://mamba.readthedocs.io/en/latest/installation.html
    # - https://mamba.readthedocs.io/en/latest/developer_zone/build_locally.html
    # - https://github.com/mamba-org/mamba/blob/main/libmamba/CMakeLists.txt
    # - https://github.com/mamba-org/mamba/blob/main/libmamba/
    #     environment-dev.yml
    # - https://man.archlinux.org/man/extra/cmake/cmake-env-variables.7.en
    # - https://github.com/conda-forge/libmamba-feedstock/
    # - https://github.com/conda-forge/conda-libmamba-solver-feedstock/
    # """
    local app build_deps cmake_args deps dict
    build_deps=('ninja')
    deps=(
        'curl'
        'fmt'
        'googletest'
        'libarchive'
        # > 'libsodium' # FIXME Need to include?
        'libsolv'
        'nlohmann-json'
        'openssl3'
        'pybind11'
        'python'
        'reproc'
        'spdlog'
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
        ['curl']="$(koopa_app_prefix 'curl')"
        ['fmt']="$(koopa_app_prefix 'fmt')"
        ['googletest']="$(koopa_app_prefix 'googletest')"
        ['jobs']="$(koopa_cpu_count)"
        ['libarchive']="$(koopa_app_prefix 'libarchive')"
        ['libsolv']="$(koopa_app_prefix 'libsolv')"
        ['name']='mamba'
        ['openssl']="$(koopa_app_prefix 'openssl3')"
        ['prefix']="${KOOPA_INSTALL_PREFIX:?}"
        ['pybind11']="$(koopa_app_prefix 'pybind11')"
        ['reproc']="$(koopa_app_prefix 'reproc')"
        ['shared_ext']="$(koopa_shared_ext)"
        ['spdlog']="$(koopa_app_prefix 'spdlog')"
        ['tl-expected']="$(koopa_app_prefix 'tl-expected')"
        ['version']="${KOOPA_INSTALL_VERSION:?}"
        ['yaml-cpp']="$(koopa_app_prefix 'yaml-cpp')"
    )
    koopa_assert_is_dir \
        "${dict['curl']}" \
        "${dict['fmt']}" \
        "${dict['googletest']}" \
        "${dict['libarchive']}" \
        "${dict['libsolv']}" \
        "${dict['openssl']}" \
        "${dict['pybind11']}" \
        "${dict['reproc']}" \
        "${dict['spdlog']}" \
        "${dict['tl-expected']}" \
        "${dict['yaml-cpp']}"
    dict['file']="${dict['version']}.tar.gz"
    dict['url']="https://github.com/mamba-org/mamba/archive/refs/\
tags/${dict['file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}"
    koopa_cd "${dict['name']}-${dict['version']}"
    cmake_args=(
        "-DCMAKE_INSTALL_PREFIX=${dict['prefix']}"
        '-DCMAKE_BUILD_TYPE=Release'
        "-DCMAKE_CXX_FLAGS=${CPPFLAGS:-}"
        "-DCMAKE_C_FLAGS=${CFLAGS:-}"
        "-DCMAKE_EXE_LINKER_FLAGS=${LDFLAGS:-}"
        "-DCMAKE_MODULE_LINKER_FLAGS=${LDFLAGS:-}"
        "-DCMAKE_SHARED_LINKER_FLAGS=${LDFLAGS:-}"
        # > FIXME -G "Ninja"
        # Mamba build settings -------------------------------------------------
        '-DBUILD_BINDINGS=OFF'
        '-DBUILD_SHARED=ON'
        # > '-DBUILD_STATIC=OFF'
        # > '-DBUILD_STATIC_DEPS=OFF'
        '-DBUILD_LIBMAMBA=ON'
        # > '-DBUILD_LIBMAMBAPY=ON'
        # > '-DBUILD_LIBMAMBA_TESTS=ON'
        # > '-DBUILD_MAMBA_PACKAGE=ON'
        # > '-DBUILD_MICROMAMBA=ON'
        # > '-DMICROMAMBA_LINKAGE=DYNAMIC'
        # Required dependencies ------------------------------------------------
        "-DCURL_INCLUDE_DIR=${dict['curl']}/include"
        "-DCURL_LIBRARY=${dict['curl']}/lib/libcurl.${dict['shared_ext']}"
        "-DGTest_DIR=${dict['googletest']}/lib/cmake/GTest"
        "-DLibArchive_INCLUDE_DIR=${dict['libarchive']}/include"
        "-DLibArchive_LIBRARY=${dict['libarchive']}/lib/\
libarchive.${dict['shared_ext']}"
        "-DLIBSOLVEXT_LIBRARIES=${dict['libsolv']}/lib/\
libsolvext.${dict['shared_ext']}"
        "-DLIBSOLV_LIBRARIES=${dict['libsolv']}/lib/\
libsolv.${dict['shared_ext']}"
        "-DOPENSSL_ROOT_DIR=${dict['openssl']}"
        "-DPython3_EXECUTABLE=${app['python']}"
        "-Dfmt_DIR=${dict['fmt']}/lib/cmake/fmt"
        "-Dpybind11_DIR=${dict['pybind11']}/share/cmake/pybind11"
        "-Dreproc++_DIR=${dict['reproc']}/lib/cmake/reproc++"
        "-Dreproc_DIR=${dict['reproc']}/lib/cmake/reproc"
        "-Dspdlog_DIR=${dict['spdlog']}/lib/cmake/spdlog"
        "-Dtl-expected_DIR=${dict['tl-expected']}/share/cmake/tl-expected"
        "-Dyaml-cpp_DIR=${dict['yaml-cpp']}/share/cmake/yaml-cpp"
        # FIXME "-Dlibmamba_DIR=FIXME"
    )
    koopa_print_env
    koopa_dl "CMake args" "${cmake_args[*]}"
    "${app['cmake']}" -LH \
        -S . \
        -B 'build' \
        "${cmake_args[@]}"
    "${app['cmake']}" \
        --build 'build' \
        --parallel "${dict['jobs']}"
    "${app['cmake']}" --install 'build'
    # FIXME Use this?
    # > ninja install $NJOBS
    return 0
}
