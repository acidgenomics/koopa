#!/usr/bin/env bash

main() {
    # """
    # Install bedtools.
    # @note Updated 2023-05-01.
    #
    # @seealso
    # - https://bedtools.readthedocs.io/en/latest/content/faq.html
    # - https://github.com/arq5x/bedtools2
    # - https://github.com/bioconda/bioconda-recipes/tree/master/
    #     recipes/bedtools
    # - https://github.com/arq5x/bedtools2/issues/494
    # - https://github.com/arq5x/bedtools2/tree/master/src/utils/htslib
    # """
    local -A app dict
    koopa_activate_app --build-only 'autoconf' 'automake' 'make'
    koopa_activate_app 'bzip2' 'xz' 'zlib'
    app['autoreconf']="$(koopa_locate_autoreconf)"
    app['make']="$(koopa_locate_make)"
    koopa_assert_is_executable "${app[@]}"
    dict['jobs']="$(koopa_cpu_count)"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['shared_ext']="$(koopa_shared_ext)"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['zlib']="$(koopa_app_prefix 'zlib')"
    dict['url']="https://github.com/arq5x/bedtools2/releases/download/\
v${dict['version']}/bedtools-${dict['version']}.tar.gz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src/bedtools2'
    koopa_print_env
    (
        koopa_cd 'src/utils/htslib'
        koopa_warn 'FIXME AAA'
        "${app['autoreconf']}" -fiv
        koopa_warn 'FIXME BBB'
        # FIXME Need to ensure bundled htslib can locate zlib.
    )
    "${app['make']}" \
        --jobs="${dict['jobs']}" \
        LIBS="${dict['zlib']}/lib/libz.${dict['shared_ext']}" \
        VERBOSE=1 \
        install prefix="${dict['prefix']}"
    return 0
}
