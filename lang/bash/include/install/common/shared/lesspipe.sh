#!/usr/bin/env bash

main() {
    # """
    # Install lesspipe.
    # @note Updated 2026-04-15.
    #
    # @seealso
    # - https://github.com/wofr06/lesspipe
    # - https://github.com/Homebrew/homebrew-core/blob/master/
    #     Formula/lesspipe.rb
    # """
    local -A app dict
    local -a conf_args
    _koopa_activate_app --build-only 'bash'
    app['bash']="$(_koopa_locate_bash)"
    _koopa_assert_is_executable "${app['bash']}"
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
    _koopa_download "${dict['url']}"
    _koopa_extract "$(_koopa_basename "${dict['url']}")" 'src'
    _koopa_cd 'src'
    _koopa_make_build "${conf_args[@]}"
    return 0
}
