#!/usr/bin/env bash

main() {
    # """
    # Install miller.
    # @note Updated 2023-04-06.
    #
    # @seealso
    # - https://miller.readthedocs.io/en/latest/
    # - https://github.com/johnkerl/miller/
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/miller.rb
    # """
    local -A app dict
    koopa_assert_has_no_args "$#"
    koopa_activate_app --build-only 'go'
    app['make']="$(koopa_locate_make)"
    [[ -x "${app['make']}" ]] || exit 1
    dict['gocache']="$(koopa_init_dir 'gocache')"
    dict['gopath']="$(koopa_init_dir 'go')"
    dict['jobs']="$(koopa_cpu_count)"
    dict['name']="${KOOPA_INSTALL_NAME:?}"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    export GOCACHE="${dict['gocache']}"
    export GOPATH="${dict['gopath']}"
    dict['file']="v${dict['version']}.tar.gz"
    dict['url']="https://github.com/johnkerl/${dict['name']}/archive/\
refs/tags/${dict['file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}"
    koopa_cd "${dict['name']}-${dict['version']}"
    conf_args=("--prefix=${dict['prefix']}")
    koopa_print_env
    koopa_dl 'configure args' "${conf_args[*]}"
    # The '--help' flag is not currently supported.
    # > ./configure --help
    ./configure "${conf_args[@]}"
    "${app['make']}" VERBOSE=1 --jobs="${dict['jobs']}"
    "${app['make']}" install
    koopa_chmod --recursive 'u+rw' "${dict['gopath']}"
    return 0
}
