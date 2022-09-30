#!/usr/bin/env bash

main() {
    # """
    # Install less.
    # @note Updated 2022-09-30.
    #
    # @seealso
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/less.rb
    # """
    local app conf_args dict
    koopa_activate_opt_prefix 'ncurses' 'pcre2'
    declare -A app=(
        ['make']="$(koopa_locate_make)"
    )
    [[ -x "${app['make']}" ]] || return 1
    declare -A dict=(
        ['name']='less'
        ['prefix']="${KOOPA_INSTALL_PREFIX:?}"
        ['version']="${KOOPA_INSTALL_VERSION:?}"
    )
    dict['file']="${dict['name']}-${dict['version']}.tar.gz"
    dict['url']="https://www.greenwoodsoftware.com/\
${dict['name']}/${dict['file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}"
    koopa_cd "${dict['name']}-${dict['version']}"
    koopa_print_env
    conf_args=(
        "--prefix=${dict['prefix']}"
        '--with-regex=pcre2'
    )
    koopa_dl 'configure args' "${conf_args[*]}"
    ./configure "${conf_args[@]}"
    "${app['make']}" install
    return 0
}
