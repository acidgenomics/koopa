#!/usr/bin/env bash

main() {
    # """
    # Install FLAC.
    # @note Updated 2022-05-27.
    #
    # @seealso
    # - https://xiph.org/flac/
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/flac.rb
    # - https://www.linuxfromscratch.org/blfs/view/svn/multimedia/flac.html
    # """
    local app dict
    koopa_assert_has_no_args "$#"
    koopa_activate_app --build-only 'pkg-config'
    declare -A app=(
        ['make']="$(koopa_locate_make)"
    )
    [[ -x "${app['make']}" ]] || return 1
    declare -A dict=(
        ['jobs']="$(koopa_cpu_count)"
        ['name']='flac'
        ['prefix']="${KOOPA_INSTALL_PREFIX:?}"
        ['version']="${KOOPA_INSTALL_VERSION:?}"
    )
    dict['file']="${dict['name']}-${dict['version']}.tar.xz"
    dict['url']="https://downloads.xiph.org/releases/\
${dict['name']}/${dict['file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}"
    koopa_cd "${dict['name']}-${dict['version']}"
    conf_args=(
        "--prefix=${dict['prefix']}"
        '--disable-thorough-tests'
    )
    koopa_print_env
    koopa_dl 'configure args' "${conf_args[*]}"
    ./configure --help
    ./configure "${conf_args[@]}"
    "${app['make']}" VERBOSE=1 --jobs="${dict['jobs']}"
    "${app['make']}" install
    return 0
}
