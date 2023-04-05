#!/usr/bin/env bash

main() {
    # """
    # Install xz.
    # @note Updated 2023-03-27.

    # @seealso
    # - https://github.com/Homebrew/homebrew-core/blob/HEAD/Formula/xz.rb
    # """
    local app dict
    koopa_assert_has_no_args "$#"
    koopa_activate_app --build-only 'make' 'pkg-config'
    declare -A app
    app['make']="$(koopa_locate_make)"
    [[ -x "${app['make']}" ]] || exit 1
    declare -A dict=(
        ['jobs']="$(koopa_cpu_count)"
        ['name']='xz'
        ['prefix']="${KOOPA_INSTALL_PREFIX:?}"
        ['version']="${KOOPA_INSTALL_VERSION:?}"
    )
    dict['file']="${dict['name']}-${dict['version']}.tar.gz"
    dict['url']="https://downloads.sourceforge.net/project/\
lzmautils/${dict['file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}"
    koopa_cd "${dict['name']}-${dict['version']}"
    conf_args=(
        "--prefix=${dict['prefix']}"
        '--disable-debug'
        '--disable-dependency-tracking'
        '--disable-silent-rules'
    )
    koopa_print_env
    koopa_dl 'configure args' "${conf_args[*]}"
    ./configure --help
    ./configure "${conf_args[@]}"
    "${app['make']}" VERBOSE=1 --jobs="${dict['jobs']}"
    "${app['make']}" install
    return 0
}
