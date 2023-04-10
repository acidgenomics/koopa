#!/usr/bin/env bash

main() {
    # """
    # Install lesspipe.
    # @note Updated 2023-04-10.
    #
    # @seealso
    # - https://github.com/wofr06/lesspipe
    # - https://github.com/Homebrew/homebrew-core/blob/master/
    #     Formula/lesspipe.rb
    # """
    local -A dict
    local -a conf_args
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    conf_args=("--prefix=${dict['prefix']}")
    dict['url']="https://github.com/wofr06/lesspipe/archive/refs/\
tags/v${dict['version']}.tar.gz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    # shellcheck disable=SC2016
    koopa_find_and_replace_in_file \
        --fixed \
        --pattern='\$(DESTDIR)/etc/bash_completion.d' \
        --replacement='\$(DESTDIR)\$(PREFIX)/etc/bash_completion.d' \
        'configure'
    koopa_make_build "${conf_args[@]}"
    return 0
}
