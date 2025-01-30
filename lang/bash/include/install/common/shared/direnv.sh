#!/usr/bin/env bash

main() {
    # """
    # Install direnv.
    # @note Updated 2025-01-30.
    #
    # @seealso
    # - https://github.com/direnv/direnv/
    # - https://formulae.brew.sh/formula/direnv
    # """
    local -A app dict
    local -a install_args
    koopa_activate_app --build-only 'go'
    koopa_activate_app 'bash'
    app['bash']="$(koopa_locate_bash)"
    app['make']="$(koopa_locate_make)"
    koopa_assert_is_executable "${app[@]}"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"

    dict['url']="https://github.com/direnv/direnv/archive/refs/tags/\
v${dict['version']}.tar.gz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    install_args+=(
        "BASH_PATH=${app['bash']}"
        "PREFIX=${dict['prefix']}"
    )
    "${app['make']}" install "${install_args[@]}"
    return 0
}
