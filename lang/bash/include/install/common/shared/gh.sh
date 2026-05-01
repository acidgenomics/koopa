#!/usr/bin/env bash

install_from_conda() {
    _koopa_install_conda_package
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
    _koopa_activate_app --build-only 'go'
    app['make']="$(_koopa_locate_make)"
    _koopa_assert_is_executable "${app[@]}"
    dict['gocache']="$(_koopa_init_dir 'gocache')"
    dict['gopath']="$(_koopa_init_dir 'go')"
    dict['jobs']="$(_koopa_cpu_count)"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    export GH_VERSION="${dict['version']}"
    export GOCACHE="${dict['gocache']}"
    export GOPATH="${dict['gopath']}"
    export GO_LDFLAGS='-s -w -X main.updaterEnabled=cli/cli'
    dict['url']="https://github.com/cli/cli/archive/\
refs/tags/v${dict['version']}.tar.gz"
    _koopa_download "${dict['url']}"
    _koopa_extract "$(_koopa_basename "${dict['url']}")" 'src'
    _koopa_cd 'src'
    _koopa_print_env
    "${app['make']}" \
        VERBOSE=1 \
        --jobs="${dict['jobs']}" \
        'bin/gh' 'manpages'
    _koopa_cp \
        --target-directory="${dict['prefix']}" \
        'bin' 'share'
    _koopa_chmod --recursive 'u+rw' "${dict['gopath']}"
    return 0
}

main() {
    local -A app dict
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    app['gh']="${dict['prefix']}/bin/gh"
    if _koopa_is_macos && _koopa_is_amd64
    then
        install_from_source
    else
        install_from_conda
    fi
    _koopa_assert_is_executable "${app['gh']}"
    dict['bc']="${dict['prefix']}/share/bash-completion/completions/gh"
    _koopa_alert "Adding bash completion at '${dict['bc']}'."
    _koopa_touch "${dict['bc']}"
    "${app['gh']}" completion -s bash > "${dict['bc']}"
    return 0
}
