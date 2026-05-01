#!/usr/bin/env bash

# NOTE Consider requiring coreutils on macOS.

main() {
    # """
    # Install byobu.
    # @note Updated 2023-05-23.
    #
    # @seealso
    # - https://formulae.brew.sh/formula/byobu
    # """
    local -A dict
    local -a conf_args
    _koopa_activate_app 'gettext' 'tmux'
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    conf_args=(
        "--prefix=${dict['prefix']}"
    )
    dict['url']="https://launchpad.net/byobu/trunk/${dict['version']}/\
+download/byobu_${dict['version']}.orig.tar.gz"
    _koopa_download "${dict['url']}"
    _koopa_extract "$(_koopa_basename "${dict['url']}")" 'src'
    _koopa_cd 'src'
    _koopa_make_build "${conf_args[@]}"
    return 0
}
