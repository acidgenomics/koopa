#!/usr/bin/env bash

main() {
    # """
    # Install less.
    # @note Updated 2024-11-04.
    #
    # Need to include autoconf and groff when building from GitHub.
    #
    # @seealso
    # - https://www.greenwoodsoftware.com/less/
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/less.rb
    # """
    local -A app dict
    local -a conf_args
    _koopa_activate_app --build-only 'autoconf' 'groff'
    _koopa_activate_app 'ncurses' 'pcre2'
    app['make']="$(_koopa_locate_make)"
    _koopa_assert_is_executable "${app[@]}"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    conf_args+=(
        "--prefix=${dict['prefix']}"
        '--with-regex=pcre2'
    )
# >     dict['url']="https://www.greenwoodsoftware.com/less/\
# > less-${dict['version']}.tar.gz"
    dict['url']="https://github.com/gwsw/less/archive/refs/tags/\
v${dict['version']}-rel.tar.gz"
    _koopa_download "${dict['url']}"
    _koopa_extract "$(_koopa_basename "${dict['url']}")" 'src'
    _koopa_cd 'src'
    "${app['make']}" -f 'Makefile.aut' 'distfiles'
    _koopa_make_build "${conf_args[@]}"
    return 0
}
