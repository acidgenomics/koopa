#!/usr/bin/env bash

main() {
    # """
    # Install libevent.
    # @note Updated 2022-06-01.
    #
    # @seealso
    # - https://github.com/Homebrew/homebrew-core/blob/master/
    #       Formula/libevent.rb
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
        ['name']='libevent'
        ['prefix']="${KOOPA_INSTALL_PREFIX:?}"
        ['version']="${KOOPA_INSTALL_VERSION:?}"
    )
    dict['file']="${dict['name']}-${dict['version']}-stable.tar.gz"
    dict['url']="https://github.com/${dict['name']}/${dict['name']}/releases/\
download/release-${dict['version']}-stable/${dict['file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}"
    koopa_cd "${dict['name']}-${dict['version']}-stable"
    conf_args=(
        "--prefix=${dict['prefix']}"
        '--disable-debug-mode'
        '--disable-dependency-tracking'
    )
    koopa_print_env
    koopa_dl 'configure args' "${conf_args[*]}"
    ./configure --help
    ./configure "${conf_args[@]}"
    "${app['make']}" VERBOSE=1 --jobs="${dict['jobs']}"
    # > "${app['make']}" check
    "${app['make']}" install
    return 0
}
