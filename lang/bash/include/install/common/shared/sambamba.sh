#!/usr/bin/env bash

# NOTE conda build issue with macOS:
# https://github.com/bioconda/bioconda-recipes/pull/42509

# FIXME Likely need to install ldc to get this to compile correctly.
# https://formulae.brew.sh/formula/ldc

# LDC error:
# python3 ./gen_ldc_version_info.py  > utils/ldc_version_info_.d
# gmake: *** [Makefile:73: utils/ldc_version_info_.d] Error 1

main() {
    # """
    # Install sambamba.
    # @note Updated 2023-08-17.
    #
    # @seealso
    # - https://github.com/biod/sambamba/blob/master/INSTALL.md
    # - https://github.com/biod/sambamba#compiling-sambamba
    # """
    local -A app dict
    local -a build_deps
    build_deps=('ldc' 'python3.11')
    koopa_activate_app --build-only "${build_deps[@]}"
    app['make']="$(koopa_locate_make)"
    koopa_assert_is_executable "${app[@]}"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['url']="https://github.com/biod/sambamba/archive/refs/tags/\
v${dict['version']}.tar.gz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    "${app['make']}" prefix="${dict['prefix']}" release
    "${app['make']}" check
    "${app['make']}" install prefix="${dict['prefix']}"
    return 0
}
