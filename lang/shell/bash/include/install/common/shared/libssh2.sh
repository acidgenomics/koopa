#!/usr/bin/env bash

main() {
    # """
    # Install libssh2.
    # @note Updated 2023-03-26.
    #
    # @seealso
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/libssh2.rb
    # """
    local app conf_args dict
    koopa_assert_has_no_args "$#"
    koopa_activate_app --build-only 'make' 'pkg-config'
    koopa_activate_app 'openssl3'
    declare -A app
    app['make']="$(koopa_locate_make)"
    [[ -x "${app['make']}" ]] || return 1
    declare -A dict=(
        ['jobs']="$(koopa_cpu_count)"
        ['name']='libssh2'
        ['prefix']="${KOOPA_INSTALL_PREFIX:?}"
        ['version']="${KOOPA_INSTALL_VERSION:?}"
    )
    dict['openssl']="$(koopa_app_prefix 'openssl3')"
    dict['file']="${dict['name']}-${dict['version']}.tar.gz"
    dict['url']="https://www.libssh2.org/download/${dict['file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}"
    koopa_cd "${dict['name']}-${dict['version']}"
    conf_args=(
        "--prefix=${dict['prefix']}"
        '--disable-silent-rules'
        '--disable-examples-build'
        "--with-libssl-prefix=${dict['openssl']}"
        '--without-libz'
    )
    koopa_print_env
    koopa_dl 'configure args' "${conf_args[*]}"
    ./configure --help
    ./configure "${conf_args[@]}"
    "${app['make']}" VERBOSE=1 --jobs="${dict['jobs']}"
    "${app['make']}" install
    return 0
}
