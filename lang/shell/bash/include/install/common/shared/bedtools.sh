#!/usr/bin/env bash

main() {
    # """
    # Install bedtools.
    # @note Updated 2023-05-01.
    #
    # @seealso
    # - https://github.com/arq5x/bedtools2
    # - https://github.com/bioconda/bioconda-recipes/tree/master/
    #     recipes/bedtools
    # """
    local -A app dict
    koopa_activate_app --build-only 'make'
    app['make']="$(koopa_locate_make)"
    koopa_assert_is_executable "${app[@]}"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['url']="https://github.com/arq5x/bedtools2/releases/download/\
v${dict['version']}/bedtools-${dict['version']}.tar.gz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src/bedtools2'
    koopa_print_env
    "${app['make']}" install prefix="${dict['prefix']}"
    return 0
}
