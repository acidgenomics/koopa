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
    koopa_activate_app 'gettext' 'tmux'
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    conf_args=(
        "--prefix=${dict['prefix']}"
    )
    dict['url']="https://launchpad.net/byobu/trunk/${dict['version']}/\
+download/byobu_${dict['version']}.orig.tar.gz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    koopa_make_build "${conf_args[@]}"
    return 0
}
