#!/usr/bin/env bash

main() {
    # """
    # Install miller.
    # @note Updated 2023-04-10.
    #
    # @seealso
    # - https://miller.readthedocs.io/en/latest/
    # - https://github.com/johnkerl/miller/
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/miller.rb
    # """
    local -A dict
    local -a conf_args
    _koopa_activate_app --build-only 'go'
    dict['gocache']="$(_koopa_init_dir 'gocache')"
    dict['gopath']="$(_koopa_init_dir 'go')"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    conf_args=("--prefix=${dict['prefix']}")
    export GOCACHE="${dict['gocache']}"
    export GOPATH="${dict['gopath']}"
    dict['url']="https://github.com/johnkerl/miller/archive/refs/tags/\
v${dict['version']}.tar.gz"
    _koopa_download "${dict['url']}"
    _koopa_extract "$(_koopa_basename "${dict['url']}")" 'src'
    _koopa_cd 'src'
    _koopa_make_build "${conf_args[@]}"
    _koopa_chmod --recursive 'u+rw' "${dict['gopath']}"
    return 0
}
