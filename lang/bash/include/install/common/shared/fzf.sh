#!/usr/bin/env bash

main() {
    # """
    # Install fzf.
    # @note Updated 2024-07-12.
    #
    # @seealso
    # - https://github.com/junegunn/fzf/blob/master/BUILD.md
    # """
    local -A app dict
    koopa_activate_app --build-only 'go'
    app['make']="$(koopa_locate_make)"
    koopa_assert_is_executable "${app[@]}"
    dict['gocache']="$(koopa_init_dir 'gocache')"
    dict['gopath']="$(koopa_init_dir 'go')"
    dict['jobs']="$(koopa_cpu_count)"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    export FZF_REVISION='tarball'
    export FZF_VERSION="${dict['version']}"
    export GOCACHE="${dict['gocache']}"
    export GOPATH="${dict['gopath']}"
    dict['url']="https://github.com/junegunn/fzf/\
archive/v${dict['version']}.tar.gz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    koopa_print_env
    "${app['make']}" VERBOSE=1 --jobs="${dict['jobs']}"
    # This will copy fzf binary from 'target/' to 'bin/'.
    "${app['make']}" install
    # > ./install --help
    ./install --bin --no-update-rc
    koopa_cp \
        --target-directory="${dict['prefix']}" \
        'bin' 'doc' 'man' 'plugin' 'shell'
    koopa_chmod --recursive 'u+rw' "${dict['gopath']}"
    return 0
}
