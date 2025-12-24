#!/usr/bin/env bash

install_from_conda() {
    koopa_install_conda_package
    return 0
}

install_from_source() {
    # """
    # Install GitHub CLI (gh).
    # @note Updated 2023-06-01.
    #
    # @seealso
    # - https://github.com/cli/cli
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/gh.rb
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
    export GH_VERSION="${dict['version']}"
    export GOCACHE="${dict['gocache']}"
    export GOPATH="${dict['gopath']}"
    export GO_LDFLAGS='-s -w -X main.updaterEnabled=cli/cli'
    dict['url']="https://github.com/cli/cli/archive/\
refs/tags/v${dict['version']}.tar.gz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    koopa_print_env
    "${app['make']}" \
        VERBOSE=1 \
        --jobs="${dict['jobs']}" \
        'bin/gh' 'manpages'
    koopa_cp \
        --target-directory="${dict['prefix']}" \
        'bin' 'share'
    koopa_chmod --recursive 'u+rw' "${dict['gopath']}"
    return 0
}

main() {
    local -A app dict
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    app['gh']="${dict['prefix']}/bin/gh"
    if koopa_is_macos && koopa_is_amd64
    then
        install_from_source
    else
        install_from_conda
    fi
    koopa_assert_is_executable "${app['gh']}"
    dict['bc']="${dict['prefix']}/share/bash-completion/completions/gh"
    koopa_alert "Adding bash completion at '${dict['bc']}'."
    koopa_touch "${dict['bc']}"
    "${app['gh']}" completion -s bash > "${dict['bc']}"
    return 0
}
