#!/usr/bin/env bash

# NOTE Consider adding support for help2man during build.

main() {
    # """
    # Install flex.
    # @note Updated 2022-08-27.
    #
    # @seealso
    # - https://github.com/westes/flex/
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/flex.rb
    # """
    local app conf_args dict
    koopa_activate_build_opt_prefix 'bison'
    koopa_activate_opt_prefix \
        'gettext' \
        'm4'
    declare -A app=(
        ['make']="$(koopa_locate_make)"
    )
    [[ -x "${app['make']}" ]] || return 1
    declare -A dict=(
        ['jobs']="$(koopa_cpu_count)"
        ['name']='flex'
        ['prefix']="${INSTALL_PREFIX:?}"
        ['version']="${INSTALL_VERSION:?}"
    )
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
    ./configure "${conf_args[@]}"
    "${app['make']}" --jobs="${dict['jobs']}"
    "${app['make']}" install
    return 0
}
