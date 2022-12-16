#!/usr/bin/env bash

main() {
    # """
    # Install less.
    # @note Updated 2022-12-16.
    #
    # Need to include autoconf and groff when building from GitHub.
    #
    # @seealso
    # - https://www.greenwoodsoftware.com/less/
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/less.rb
    # """
    local app conf_args dict
    koopa_activate_app --build-only 'autoconf' 'groff'
    koopa_activate_app 'ncurses' 'pcre2'
    declare -A app=(
        ['make']="$(koopa_locate_make)"
    )
    [[ -x "${app['make']}" ]] || return 1
    declare -A dict=(
        ['name']='less'
        ['prefix']="${KOOPA_INSTALL_PREFIX:?}"
        ['version']="${KOOPA_INSTALL_VERSION:?}"
    )
    dict['file']="v${dict['version']}.tar.gz"
    dict['url']="https://github.com/gwsw/${dict['name']}/archive/refs/\
tags/${dict['file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}"
    koopa_cd "${dict['name']}-${dict['version']}"
    koopa_print_env
    conf_args=(
        "--prefix=${dict['prefix']}"
        '--with-regex=pcre2'
    )
    koopa_dl 'configure args' "${conf_args[*]}"
    "${app['make']}" -f 'Makefile.aut' 'distfiles'
    ./configure "${conf_args[@]}"
    "${app['make']}" install
    return 0
}
