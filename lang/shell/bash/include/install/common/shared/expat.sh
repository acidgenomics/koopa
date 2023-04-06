#!/usr/bin/env bash

main() {
    # """
    # Install expat.
    # @note Updated 2023-03-26.
    #
    # @seealso
    # - https://libexpat.github.io/
    # """
    local -A app dict
    local -a conf_args
    koopa_assert_has_no_args "$#"
    koopa_activate_app --build-only 'make' 'pkg-config'
    app['make']="$(koopa_locate_make)"
    koopa_assert_is_executable "${app[@]}"
    dict['jobs']="$(koopa_cpu_count)"
    dict['name']='expat'
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['version2']="$( \
        koopa_gsub \
            --fixed \
            --pattern='.' \
            --replacement='_' \
            "${dict['version']}" \
    )"
    dict['file']="${dict['name']}-${dict['version']}.tar.xz"
    dict['url']="https://github.com/libexpat/libexpat/releases/download/\
R_${dict['version2']}/${dict['file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}"
    koopa_cd "${dict['name']}-${dict['version']}"
    conf_args=("--prefix=${dict['prefix']}")
    koopa_print_env
    koopa_dl 'configure args' "${conf_args[*]}"
    ./configure --help
    ./configure "${conf_args[@]}"
    "${app['make']}" VERBOSE=1 --jobs="${dict['jobs']}"
    "${app['make']}" install
    return 0
}
