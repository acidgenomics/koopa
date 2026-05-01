#!/usr/bin/env bash

main() {
    # """
    # Install CMake.
    # @note Updated 2023-08-31.
    #
    # @seealso
    # - https://github.com/Kitware/CMake
    # - https://github.com/conda-forge/cmake-feedstock
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/cmake.rb
    # """
    local -A app dict
    local -a bootstrap_args cmake_args
    _koopa_activate_app --build-only 'make'
    _koopa_activate_app 'zlib' 'zstd' 'openssl' 'libssh2' 'curl'
    app['make']="$(_koopa_locate_make)"
    _koopa_assert_is_executable "${app[@]}"
    dict['jobs']="$(_koopa_cpu_count)"
    _koopa_is_linux && dict['jobs']=1
    dict['mem_gb']="$(_koopa_mem_gb)"
    dict['mem_gb_cutoff']=7
    dict['openssl']="$(_koopa_app_prefix 'openssl')"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    readarray -t cmake_args <<< "$( \
        _koopa_cmake_std_args --prefix="${dict['prefix']}" \
    )"
    cmake_args+=(
        '-DCMake_BUILD_LTO=ON'
        "-DOPENSSL_ROOT_DIR=${dict['openssl']}"
    )
    bootstrap_args=(
        '--no-system-libs'
        '--system-curl'
        '--system-zlib'
        "--parallel=${dict['jobs']}"
        "--prefix=${dict['prefix']}"
    )
    bootstrap_args+=('--' "${cmake_args[@]}")
    if [[ "${dict['mem_gb']}" -lt "${dict['mem_gb_cutoff']}" ]]
    then
        _koopa_stop "${dict['mem_gb_cutoff']} GB of RAM is required."
    fi
    dict['url']="https://github.com/Kitware/CMake/releases/download/\
v${dict['version']}/cmake-${dict['version']}.tar.gz"
    _koopa_download "${dict['url']}"
    _koopa_extract "$(_koopa_basename "${dict['url']}")" 'src'
    _koopa_cd 'src'
    ./bootstrap --help || true
    ./bootstrap "${bootstrap_args[@]}"
    _koopa_print_env
    "${app['make']}" VERBOSE=1 --jobs="${dict['jobs']}"
    "${app['make']}" install
    app['cmake']="${dict['prefix']}/bin/cmake"
    if ! "${app['cmake']}" -E capabilities | grep -q '"tls":true\|"tls": true'
    then
        _koopa_stop 'CMake was built without TLS support.'
    fi
    return 0
}
