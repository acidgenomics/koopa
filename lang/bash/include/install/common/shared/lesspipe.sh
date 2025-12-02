#!/usr/bin/env bash

main() {
    # """
    # Install lesspipe.
    # @note Updated 2025-12-01.
    #
    # @seealso
    # - https://github.com/wofr06/lesspipe
    # - https://github.com/Homebrew/homebrew-core/blob/master/
    #     Formula/lesspipe.rb
    # """
    local -A app dict
    local -a conf_args
    app['bash']="$(koopa_locate_bash)"
    koopa_assert_is_executable "${app['bash']}"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    conf_args=(
        "--bash-completion-dir=${dict['prefix']}/etc/bash_completion.d"
        "--prefix=${dict['prefix']}"
        "--shell=${app['bash']}"
        "--zsh-completion-dir=${dict['prefix']}/share/zsh/site-functions"
    )
    dict['url']="https://github.com/wofr06/lesspipe/archive/refs/\
tags/v${dict['version']}.tar.gz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    koopa_make_build "${conf_args[@]}"
    return 0
}
