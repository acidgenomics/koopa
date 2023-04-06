#!/usr/bin/env bash

main() {
    # """
    # Install GitHub CLI (gh).
    # @note Updated 2023-04-06.
    #
    # @seealso
    # - https://github.com/cli/cli
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/gh.rb
    # """
    local -A app dict
    koopa_assert_has_no_args "$#"
    koopa_activate_app --build-only 'go'
    app['make']="$(koopa_locate_make)"
    [[ -x "${app['make']}" ]] || exit 1
    dict['gocache']="$(koopa_init_dir 'gocache')"
    dict['gopath']="$(koopa_init_dir 'go')"
    dict['jobs']="$(koopa_cpu_count)"
    dict['name']='cli'
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    export GH_VERSION="${dict['version']}"
    export GOCACHE="${dict['gocache']}"
    export GOPATH="${dict['gopath']}"
    export GO_LDFLAGS='-s -w -X main.updaterEnabled=cli/cli'
    dict['file']="v${dict['version']}.tar.gz"
    dict['url']="https://github.com/${dict['name']}/${dict['name']}/archive/\
refs/tags/${dict['file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}"
    koopa_cd "${dict['name']}-${dict['version']}"
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
