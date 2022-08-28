#!/usr/bin/env bash

main() {
    # """
    # Install jemalloc.
    # @note Updated 2022-08-19.
    #
    # @seealso
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/
    #     jemalloc.rb
    # """
    local app conf_args dict
    koopa_assert_has_no_args "$#"
    declare -A app=(
        ['make']="$(koopa_locate_make)"
    )
    [[ -x "${app['make']}" ]] || return 1
    declare -A dict=(
        ['jobs']="$(koopa_cpu_count)"
        ['name']='jemalloc'
        ['prefix']="${INSTALL_PREFIX:?}"
        ['version']="${INSTALL_VERSION:?}"
    )
    dict['file']="${dict['name']}-${dict['version']}.tar.bz2"
    dict['url']="https://github.com/jemalloc/jemalloc/releases/download/\
${dict['version']}/${dict['file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}"
    koopa_cd "${dict['name']}-${dict['version']}"
    conf_args=(
        "--prefix=${dict['prefix']}"
        '--disable-debug'
        '--with-jemalloc-prefix='
    )
    ./configure --help
    ./configure "${conf_args[@]}"
    "${app['make']}" --jobs="${dict['jobs']}"
    # > "${app['make']}" check
    "${app['make']}" install
    return 0
}
