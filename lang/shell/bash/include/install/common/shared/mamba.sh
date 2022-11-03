#!/usr/bin/env bash

# FIXME Need to provide support for yaml-cpp.
# CMake Error at libmamba/CMakeLists.txt:428 (find_package):
#  Could not find a package configuration file provided by "yaml-cpp" with any
#  of the following names:
#
#    yaml-cppConfig.cmake
#    yaml-cpp-config.cmake
#
#  Add the installation prefix of "yaml-cpp" to CMAKE_PREFIX_PATH or set
#  "yaml-cpp_DIR" to a directory containing one of the above files.  If
#  "yaml-cpp" provides a separate development package or SDK, be sure it has
#  been installed.

# FIXME Need to address libsolv path issues.
# // Path to a library.
# LIBSOLVEXT_LIBRARIES:FILEPATH=LIBSOLVEXT_LIBRARIES-NOTFOUND
#
# // Path to a library.
# LIBSOLV_LIBRARIES:FILEPATH=LIBSOLV_LIBRARIES-NOTFOUND
#
# // The directory containing a CMake configuration file for yaml-cpp.
# yaml-cpp_DIR:PATH=yaml-cpp_DIR-NOTFOUND

main() {
    # """
    # Install micromamba.
    # @note Updated 2022-11-03.
    #
    # @seealso
    # - https://mamba.readthedocs.io/en/latest/developer_zone/build_locally.html
    # - https://mamba.readthedocs.io/en/latest/installation.html
    # - 'environment-dev.yml' files
    # """
    local app build_deps cmake_args deps dict
    build_deps=(
        'ninja'
    )
    deps=(
        'curl'
        'libarchive'
        # > 'libsodium' # FIXME
        'libsolv'
        'openssl3'
        'python'
    )
    koopa_activate_app --build-only "${build_deps[@]}"
    koopa_activate_app "${deps[@]}"
    declare -A app=(
        ['cmake']="$(koopa_locate_cmake)"
        ['make']="$(koopa_locate_make)"
        ['python']="$(koopa_locate_python --realpath)"
    )
    [[ -x "${app['cmake']}" ]] || return 1
    [[ -x "${app['make']}" ]] || return 1
    [[ -x "${app['python']}" ]] || return 1
    declare -A dict=(
        ['libarchive']="$(koopa_app_prefix 'libarchive')"
        ['name']='mamba'
        ['openssl']="$(koopa_app_prefix 'openssl3')"
        ['prefix']="${KOOPA_INSTALL_PREFIX:?}"
        ['version']="${KOOPA_INSTALL_VERSION:?}"
    )
    koopa_assert_is_dir \
        "${dict['libarchive']}" \
        "${dict['openssl']}"
    dict['file']="${dict['version']}.tar.gz"
    dict['url']="https://github.com/mamba-org/mamba/archive/refs/\
tags/${dict['file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}"
    koopa_cd "${dict['name']}-${dict['version']}"
    koopa_mkdir 'build'
    koopa_cd 'build'
    cmake_args=(
        "-DCMAKE_INSTALL_PREFIX=${dict['prefix']}"
        '-DBUILD_LIBMAMBA=ON'
        '-DBUILD_LIBMAMBAPY=ON'
        '-DBUILD_LIBMAMBA_TESTS=ON'
        '-DBUILD_MICROMAMBA=ON'
        '-DBUILD_SHARED=ON'
        '-DMICROMAMBA_LINKAGE=DYNAMIC'
        "-DLibArchive_INCLUDE_DIR=${dict['libarchive']}/include"
        "-DOPENSSL_ROOT_DIR=${dict['openssl']}"
        "-DPython3_EXECUTABLE=${app['python']}"
    )
    koopa_dl "CMake args" "${cmake_args[*]}"
    "${app['cmake']}" -LH -S .. "${cmake_args[@]}"
    "${app['make']}"
    "${app['make']}" test
    "${app['make']}" install
    # > python3 -m pip install -e ../libmambapy/ --no-deps
    # > pytest ./micromamba/tests/
    return 0
}
