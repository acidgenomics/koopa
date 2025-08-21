#!/usr/bin/env bash

main() {
    # """
    # Install duckdb.
    # @note Updated 2024-04-17.
    #
    # @seealso
    # - https://github.com/duckdb/duckdb
    # - https://formulae.brew.sh/formula/duckdb
    # """
    local -A dict
    local -a build_deps cmake_args
    build_deps+=('python')
    koopa_activate_app --build-only "${build_deps[@]}"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['url']="https://github.com/duckdb/duckdb/archive/refs/tags/\
v${dict['version']}.zip"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    cmake_args=(
        '-DBUILD_EXTENSIONS=autocomplete;icu;parquet;json'
        '-DENABLE_EXTENSION_AUTOINSTALL=1'
        '-DENABLE_EXTENSION_AUTOLOADING=1'
    )
    koopa_cmake_build \
        --prefix="${dict['prefix']}" \
        "${cmake_args[@]}"
    return 0
}
