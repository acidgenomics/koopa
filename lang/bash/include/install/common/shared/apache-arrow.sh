#!/usr/bin/env bash

main() {
    # """
    # Install Apache Arrow.
    # @note Updated 2026-02-02.
    #
    # @seealso
    # - https://arrow.apache.org/install/
    # - https://arrow.apache.org/docs/developers/cpp/building.html
    # - https://formulae.brew.sh/formula/apache-arrow
    # - https://github.com/conda-forge/arrow-cpp-feedstock
    # - https://arrow.apache.org/docs/python/install.html
    # - https://arrow.apache.org/docs/python/parquet.html
    # """
    local -A dict
    local -a build_deps cmake_args deps
    build_deps+=(
        'curl'
        'pkg-config'
        'python'
    )
    deps+=(
        # > 'llvm'
        'openssl'
    )
    _koopa_activate_app --build-only "${build_deps[@]}"
    _koopa_activate_app "${deps[@]}"
    # > dict['llvm_root']="$(_koopa_app_prefix 'llvm')"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    cmake_args=(
        '-DARROW_CSV=ON'
        '-DARROW_DEPENDENCY_SOURCE=BUNDLED'
        '-DARROW_PARQUET=ON'
    )
    if ! _koopa_is_arm64
    then
        cmake_args+=('-DARROW_MIMALLOC=ON')
    fi
    dict['url']="https://www.apache.org/dyn/closer.lua?action=download&\
filename=arrow/arrow-${dict['version']}/apache-arrow-${dict['version']}.tar.gz"
    _koopa_download "${dict['url']}"
    _koopa_extract "$(_koopa_basename "${dict['url']}")" 'src'
    _koopa_cd 'src/cpp'
    _koopa_cmake_build \
        --ninja \
        --prefix="${dict['prefix']}" \
        "${cmake_args[@]}"
    return 0
}
