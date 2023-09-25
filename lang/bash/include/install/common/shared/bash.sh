#!/usr/bin/env bash

main() {
    # """
    # Install Bash.
    # @note Updated 2023-09-25.
    #
    # @seealso
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/bash.rb
    # """
    local -A dict
    local -a conf_args
    koopa_activate_app --build-only 'pkg-config'
    dict['gnu_mirror']="$(koopa_gnu_mirror_url)"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    conf_args=("--prefix=${dict['prefix']}")
    if koopa_is_alpine
    then
        conf_args+=('--without-bash-malloc')
    elif koopa_is_macos
    then
        CFLAGS="-DSSH_SOURCE_BASHRC ${CFLAGS:-}"
        export CFLAGS
    fi
    dict['url']="${dict['gnu_mirror']}/bash/bash-${dict['version']}.tar.gz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    koopa_make_build "${conf_args[@]}"
    return 0
}
