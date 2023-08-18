#!/usr/bin/env bash

# NOTE conda build issue with macOS:
# https://github.com/bioconda/bioconda-recipes/pull/42509

# FIXME Seeing this error with ldc:
# ld: unknown option: -flto=full

main() {
    # """
    # Install sambamba.
    # @note Updated 2023-08-17.
    #
    # @seealso
    # - https://github.com/biod/sambamba/blob/master/INSTALL.md
    # - https://github.com/biod/sambamba#compiling-sambamba
    # - https://bioconda.github.io/recipes/sambamba/README.html
    # - https://formulae.brew.sh/formula/sambamba
    # """
    local -A app dict
    local -a build_deps deps
    build_deps=('gcc' 'ldc' 'make' 'python3.11')
    deps=('bzip2' 'lz4' 'xz' 'zlib')
    koopa_activate_app --build-only "${build_deps[@]}"
    koopa_activate_app "${deps[@]}"
    app['cc']="$(koopa_locate_gcc)"
    app['make']="$(koopa_locate_make)"
    koopa_assert_is_executable "${app[@]}"
    dict['ldc']="$(koopa_app_prefix 'ldc')"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['url']="https://github.com/biod/sambamba/archive/refs/tags/\
v${dict['version']}.tar.gz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    koopa_print_env
    "${app['make']}" \
        CC="${app['cc']}" \
        LIBRARY_PATH="${LIBRARY_PATH:?}" \
        VERBOSE=1 \
        prefix="${dict['prefix']}" \
        release
    "${app['make']}" check
    "${app['make']}" \
        prefix="${dict['prefix']}" \
        install
    return 0
}
