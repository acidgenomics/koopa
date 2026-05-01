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
    _koopa_activate_app --build-only 'pkg-config'
    dict['gnu_mirror']="$(_koopa_gnu_mirror_url)"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    conf_args=("--prefix=${dict['prefix']}")
    if _koopa_is_alpine
    then
        conf_args+=('--without-bash-malloc')
    elif _koopa_is_macos
    then
        CFLAGS="-DSSH_SOURCE_BASHRC ${CFLAGS:-}"
        export CFLAGS
    fi
    dict['url']="${dict['gnu_mirror']}/bash/bash-${dict['version']}.tar.gz"
    _koopa_download "${dict['url']}"
    _koopa_extract "$(_koopa_basename "${dict['url']}")" 'src'
    _koopa_cd 'src'
    _koopa_make_build "${conf_args[@]}"
    return 0
}
