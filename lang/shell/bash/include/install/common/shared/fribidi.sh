#!/usr/bin/env bash

main() {
    # """
    # Install fribidi.
    # @note Updated 2023-03-26.
    #
    # @seealso
    # - https://github.com/fribidi/fribidi
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/fribidi.rb
    # """
    local app conf_args dict
    koopa_activate_app --build-only 'make' 'pkg-config'
    local -A app
    app['make']="$(koopa_locate_make)"
    [[ -x "${app['make']}" ]] || exit 1
    local -A dict=(
        ['jobs']="$(koopa_cpu_count)"
        ['name']='fribidi'
        ['prefix']="${KOOPA_INSTALL_PREFIX:?}"
        ['version']="${KOOPA_INSTALL_VERSION:?}"
    )
    dict['file']="${dict['name']}-${dict['version']}.tar.xz"
    dict['url']="https://github.com/${dict['name']}/${dict['name']}/releases/\
download/v${dict['version']}/${dict['file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}"
    koopa_cd "${dict['name']}-${dict['version']}"
    conf_args=(
        "--prefix=${dict['prefix']}"
        '--disable-debug'
        '--disable-dependency-tracking'
        '--disable-silent-rules'
        '--enable-static'
    )
    koopa_print_env
    koopa_dl 'configure args' "${conf_args[*]}"
    ./configure --help
    ./configure "${conf_args[@]}"
    "${app['make']}" VERBOSE=1 --jobs="${dict['jobs']}"
    "${app['make']}" install
    return 0
}
