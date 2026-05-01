#!/usr/bin/env bash

# NOTE Consider requiring ronn, ruby here.

main() {
    # """
    # Install Git LFS.
    # @note Updated 2023-06-01.
    #
    # @seealso
    # - https://github.com/Homebrew/homebrew-core/blob/HEAD/Formula/git-lfs.rb
    # - https://github.com/git-lfs/git-lfs/wiki/Installation
    # """
    local -A app dict
    _koopa_activate_app --build-only 'go' 'make'
    app['make']="$(_koopa_locate_make)"
    _koopa_assert_is_executable "${app[@]}"
    dict['gocache']="$(_koopa_init_dir 'gocache')"
    dict['gopath']="$(_koopa_init_dir 'go')"
    dict['jobs']="$(_koopa_cpu_count)"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    export GOCACHE="${dict['gocache']}"
    export GOPATH="${dict['gopath']}"
    dict['url']="https://github.com/git-lfs/git-lfs/releases/download/\
v${dict['version']}/git-lfs-v${dict['version']}.tar.gz"
    _koopa_download "${dict['url']}"
    _koopa_extract "$(_koopa_basename "${dict['url']}")" 'src'
    _koopa_cd 'src'
    _koopa_print_env
    "${app['make']}" VERBOSE=1 --jobs="${dict['jobs']}"
    _koopa_cp --target-directory="${dict['prefix']}" 'bin'
    _koopa_chmod --recursive 'u+rw' "${dict['gopath']}"
    return 0
}
