#!/usr/bin/env bash

main() {
    # """
    # Install micromamba.
    # @note Updated 2022-11-04.
    #
    # Consider setting 'CMAKE_PREFIX_PATH' here to include yaml-cpp.
    #
    # @seealso
    # - https://mamba.readthedocs.io/en/latest/developer_zone/build_locally.html
    # - https://mamba.readthedocs.io/en/latest/installation.html
    # - 'environment-dev.yml' files
    # """
    local app build_deps cmake_args deps dict
    build_deps=('ninja')
    deps=(
        'curl'
        'fmt'
        'libarchive'
        # > 'libsodium'
        'libsolv'
        'openssl3'
        'python'
        'reproc'
        'spdlog'
        'tl-expected'
        'yaml-cpp'
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
        ['fmt']="$(koopa_app_prefix 'fmt')"
        ['jobs']="$(koopa_cpu_count)"
        ['libarchive']="$(koopa_app_prefix 'libarchive')"
        ['libsolv']="$(koopa_app_prefix 'libsolv')"
        ['name']='mamba'
        ['openssl']="$(koopa_app_prefix 'openssl3')"
        ['prefix']="${KOOPA_INSTALL_PREFIX:?}"
        ['reproc']="$(koopa_app_prefix 'reproc')"
        ['shared_ext']="$(koopa_shared_ext)"
        ['tl-expected']="$(koopa_app_prefix 'tl-expected')"
        ['version']="${KOOPA_INSTALL_VERSION:?}"
        ['yaml-cpp']="$(koopa_app_prefix 'yaml-cpp')"
    )
    koopa_assert_is_dir \
        "${dict['fmt']}" \
        "${dict['libarchive']}" \
        "${dict['libsolv']}" \
        "${dict['openssl']}" \
        "${dict['reproc']}" \
        "${dict['tl-expected']}" \
        "${dict['yaml-cpp']}"
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
        "-DLIBSOLVEXT_LIBRARIES=${dict['libsolv']}/lib/\
libsolvext.${dict['shared_ext']}"
        "-DLIBSOLV_LIBRARIES=${dict['libsolv']}/lib/\
libsolv.${dict['shared_ext']}"
        "-DOPENSSL_ROOT_DIR=${dict['openssl']}"
        "-DPython3_EXECUTABLE=${app['python']}"
        "-Dfmt_DIR=${dict['fmt']}/lib/cmake/fmt"
        "-Dreproc_DIR=${dict['reproc']}/lib/cmake/reproc"
        "-Dreproc++_DIR=${dict['reproc']}/lib/cmake/reproc++"
        # FIXME Need to support spdlog
        # > // The directory containing a CMake configuration file for spdlog.
        # > spdlog_DIR:PATH=spdlog_DIR-NOTFOUND
        "-Dtl-expected_DIR=${dict['tl-expected']}/share/cmake/tl-expected"
        "-Dyaml-cpp_DIR=${dict['yaml-cpp']}/share/cmake/yaml-cpp"
    )
    koopa_dl "CMake args" "${cmake_args[*]}"
    "${app['cmake']}" -LH \
        -S .. \
        -B . \
        "${cmake_args[@]}"
    "${app['make']}" VERBOSE=1 --jobs="${dict['jobs']}"
    "${app['make']}" test
    "${app['make']}" install
    # > python3 -m pip install -e ../libmambapy/ --no-deps
    # > pytest ./micromamba/tests/
    return 0
}
