#!/usr/bin/env bash

main() {
    # """
    # Install libedit.
    # @note Updated 2023-04-06.
    #
    # @seealso
    # - https://thrysoee.dk/editline/
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/libedit.rb
    # """
    local -A app dict
    local -a conf_args
    koopa_assert_has_no_args "$#"
    koopa_activate_app --build-only 'make' 'pkg-config'
    koopa_activate_app 'ncurses'
    app['make']="$(koopa_locate_make)"
    koopa_assert_is_executable "${app[@]}"
    dict['name']='libedit'
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['file']="${dict['name']}-${dict['version']}.tar.gz"
    dict['url']="https://thrysoee.dk/editline/${dict['file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}"
    koopa_cd "${dict['name']}-${dict['version']}"
    conf_args=(
        "--prefix=${dict['prefix']}"
        '--disable-dependency-tracking'
        '--disable-silent-rules'
    )
    koopa_print_env
    koopa_dl 'configure args' "${conf_args[*]}"
    ./configure --help
    ./configure "${conf_args[@]}"
    "${app['make']}" install
    return 0
}
