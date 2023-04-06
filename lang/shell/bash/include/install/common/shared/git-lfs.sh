#!/usr/bin/env bash

# NOTE Consider requiring ronn, ruby here.

main() {
    # """
    # Install Git LFS.
    # @note Updated 2023-04-06.
    #
    # @seealso
    # - https://github.com/Homebrew/homebrew-core/blob/HEAD/Formula/git-lfs.rb
    # - https://github.com/git-lfs/git-lfs/wiki/Installation
    # """
    local -A app dict
    koopa_assert_has_no_args "$#"
    koopa_activate_app --build-only 'go' 'make'
    app['make']="$(koopa_locate_make)"
    [[ -x "${app['make']}" ]] || exit 1
    dict['gocache']="$(koopa_init_dir 'gocache')"
    dict['gopath']="$(koopa_init_dir 'go')"
    dict['jobs']="$(koopa_cpu_count)"
    dict['name']='git-lfs'
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    export GOCACHE="${dict['gocache']}"
    export GOPATH="${dict['gopath']}"
    dict['file']="${dict['name']}-v${dict['version']}.tar.gz"
    dict['url']="https://github.com/${dict['name']}/${dict['name']}/releases/\
download/v${dict['version']}/${dict['file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}"
    koopa_cd "${dict['name']}-${dict['version']}"
    koopa_print_env
    "${app['make']}" VERBOSE=1 --jobs="${dict['jobs']}"
    koopa_cp --target-directory="${dict['prefix']}" 'bin'
    koopa_chmod --recursive 'u+rw' "${dict['gopath']}"
    return 0
}
