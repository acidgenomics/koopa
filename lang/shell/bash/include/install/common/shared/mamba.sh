#!/usr/bin/env bash

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
        'libarchive' # FIXME
        'libsodium' # FIXME
        'libsolv' # FIXME
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
        ['name']='mamba'
        ['prefix']="${KOOPA_INSTALL_PREFIX:?}"
        ['version']="${KOOPA_INSTALL_VERSION:?}"
    )
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
        "-DPython3_EXECUTABLE=${app['python']}"
    )
    "${app['cmake']}" -S .. "${cmake_args[@]}"
    "${app['make']}"
    "${app['make']}" test
    "${app['make']}" install
    # > python3 -m pip install -e ../libmambapy/ --no-deps
    # > pytest ./micromamba/tests/
    return 0
}
