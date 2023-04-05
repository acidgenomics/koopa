#!/usr/bin/env bash

main() {
    # """
    # Install nano.
    # @note Updated 2023-01-03.
    #
    # @seealso
    # - https://www.nano-editor.org/
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/nano.rb
    # """
    local app conf_args dict
    koopa_assert_has_no_args "$#"
    koopa_activate_app --build-only 'make' 'pkg-config'
    # NOTE Consider requiring 'libmagic' on Linux.
    koopa_activate_app \
        'gettext' \
        'ncurses'
    local -A app
    app['make']="$(koopa_locate_make)"
    [[ -x "${app['make']}" ]] || exit 1
    local -A dict=(
        ['jobs']="$(koopa_cpu_count)"
        ['name']='nano'
        ['prefix']="${KOOPA_INSTALL_PREFIX:?}"
        ['version']="${KOOPA_INSTALL_VERSION:?}"
    )
    dict['maj_ver']="$(koopa_major_version "${dict['version']}")"
    dict['file']="${dict['name']}-${dict['version']}.tar.xz"
    dict['url']="https://www.nano-editor.org/dist/\
v${dict['maj_ver']}/${dict['file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}"
    koopa_cd "${dict['name']}-${dict['version']}"
    conf_args=(
        '--disable-debug'
        '--disable-dependency-tracking'
        '--enable-color'
        '--enable-extra'
        '--enable-multibuffer'
        '--enable-nanorc'
        '--enable-utf8'
        "--prefix=${dict['prefix']}"
    )
    koopa_print_env
    koopa_dl 'configure args' "${conf_args[*]}"
    ./configure --help
    ./configure "${conf_args[@]}"
    "${app['make']}" VERBOSE=1 --jobs="${dict['jobs']}"
    "${app['make']}" install
    return 0
}
