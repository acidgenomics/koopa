#!/usr/bin/env bash

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
    export CC="${app['cc']}"
    export LIBRARY_PATH="${LIBRARY_PATH:?}"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    koopa_print_env
    "${app['make']}" VERBOSE=1 release
    "${app['make']}" check
    koopa_cp \
        "bin/sambamba-${dict['version']}" \
        "${dict['prefix']}/bin/sambamba"
    return 0
}
