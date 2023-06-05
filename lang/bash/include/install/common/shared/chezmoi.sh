#!/usr/bin/env bash

main() {
    # """
    # Install chezmoi.
    # @note Updated 2023-06-05.
    #
    # @seealso
    # - https://www.chezmoi.io/
    # - https://github.com/twpayne/chezmoi
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/chezmoi.rb
    # - https://ports.macports.org/port/chezmoi/details/
    # """
    local -A app dict
    koopa_activate_app --build-only 'go'
    app['go']="$(koopa_locate_go)"
    koopa_assert_is_executable "${app[@]}"
    dict['gocache']="$(koopa_init_dir 'gocache')"
    dict['gopath']="$(koopa_init_dir 'go')"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    export GOCACHE="${dict['gocache']}"
    export GOPATH="${dict['gopath']}"
    dict['url']="https://github.com/twpayne/chezmoi/archive/\
refs/tags/v${dict['version']}.tar.gz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    dict['ldflags']="-X main.version=${dict['version']}"
    koopa_print_env
    "${app['go']}" build \
        -ldflags "${dict['ldflags']}" \
        -o "${dict['prefix']}/bin/chezmoi"
    koopa_chmod --recursive 'u+rw' "${dict['gopath']}"
    return 0
}
