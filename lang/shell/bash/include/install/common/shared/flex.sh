#!/usr/bin/env bash

# NOTE Consider adding support for help2man during build.

main() {
    # """
    # Install flex.
    # @note Updated 2023-04-06.
    #
    # @seealso
    # - https://github.com/westes/flex/
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/flex.rb
    # """
    local -A app dict
    local -a conf_args
    koopa_activate_app --build-only 'bison' 'make'
    koopa_activate_app 'gettext' 'm4'
    app['make']="$(koopa_locate_make)"
    [[ -x "${app['make']}" ]] || exit 1
    dict['jobs']="$(koopa_cpu_count)"
    dict['name']='flex'
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['file']="flex-2.6.4.tar.gz"
    dict['url']="https://github.com/westes/${dict['name']}/releases/download/\
v${dict['version']}/${dict['file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}"
    koopa_cd "${dict['name']}-${dict['version']}"
    conf_args=(
        "--prefix=${dict['prefix']}"
        '--disable-dependency-tracking'
        '--disable-silent-rules'
        '--enable-shared'
    )
    koopa_print_env
    koopa_dl 'configure args' "${conf_args[*]}"
    ./configure --help
    ./configure "${conf_args[@]}"
    "${app['make']}" VERBOSE=1 --jobs="${dict['jobs']}"
    "${app['make']}" install
    return 0
}
