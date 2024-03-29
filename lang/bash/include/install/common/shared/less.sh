#!/usr/bin/env bash

main() {
    # """
    # Install less.
    # @note Updated 2023-04-10.
    #
    # Need to include autoconf and groff when building from GitHub.
    #
    # @seealso
    # - https://www.greenwoodsoftware.com/less/
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/less.rb
    # """
    local -A dict
    local -a conf_args
    koopa_activate_app 'ncurses' 'pcre2'
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    conf_args=(
        "--prefix=${dict['prefix']}"
        '--with-regex=pcre2'
    )
    dict['url']="https://www.greenwoodsoftware.com/less/less-608.tar.gz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    koopa_make_build "${conf_args[@]}"
    return 0
}
