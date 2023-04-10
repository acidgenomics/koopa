#!/usr/bin/env bash

main() {
    # """
    # Install CMake.
    # @note Updated 2023-04-10.
    #
    # @seealso
    # - https://github.com/Kitware/CMake
    # - https://github.com/conda-forge/cmake-feedstock
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/cmake.rb
    # """
    local -A app dict
    local -a bootstrap_args cmake_args
    koopa_assert_has_no_args "$#"
    koopa_activate_app --build-only 'make'
    app['make']="$(koopa_locate_make)"
    koopa_assert_is_executable "${app[@]}"
    dict['jobs']="$(koopa_cpu_count)"
    dict['mem_gb']="$(koopa_mem_gb)"
    dict['mem_gb_cutoff']=7
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    readarray -t cmake_args <<< "$(koopa_cmake_std_args "${dict['prefix']}")"
    bootstrap_args=(
        '--no-system-libs'
        "--parallel=${dict['jobs']}"
        "--prefix=${dict['prefix']}"
        '--'
        "${cmake_args[@]}"
    )
    if [[ "${dict['mem_gb']}" -lt "${dict['mem_gb_cutoff']}" ]]
    then
        koopa_stop "${dict['mem_gb_cutoff']} GB of RAM is required."
    fi
    dict['url']="https://github.com/Kitware/CMake/releases/download/\
v${dict['version']}/cmake-${dict['version']}.tar.gz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    ./bootstrap --help || true
    ./bootstrap "${bootstrap_args[@]}"
    koopa_print_env
    "${app['make']}" VERBOSE=1 --jobs="${dict['jobs']}"
    "${app['make']}" install
    return 0
}
