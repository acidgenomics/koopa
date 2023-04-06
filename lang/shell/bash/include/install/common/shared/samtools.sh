#!/usr/bin/env bash

main() {
    # """
    # Install samtools.
    # @note Updated 2023-04-04.
    #
    # @seealso
    # - https://github.com/samtools/samtools/
    # """
    local -A app dict
    local -a conf_args
    koopa_activate_app --build-only 'make'
    deps=(
        'xz'
        'zlib'
        'ncurses'
        'htslib'
    )
    koopa_activate_app "${deps[@]}"
    app['make']="$(koopa_locate_make)"
    koopa_assert_is_executable "${app[@]}"
    dict['jobs']="$(koopa_cpu_count)"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['url']="https://github.com/samtools/samtools/releases/download/\
${dict['version']}/samtools-${dict['version']}.tar.bz2"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    conf_args=(
        "--prefix=${dict['prefix']}"
        '--with-htslib=system'
        # > 'CURSES_LIB=-ltinfow -lncursesw'
    )
    koopa_print_env
    koopa_dl 'configure args' "${conf_args[@]}"
    ./configure --help
    ./configure "${conf_args[@]}"
    "${app['make']}" VERBOSE=1 --jobs="${dict['jobs']}" all
    "${app['make']}" install
    return 0
}
