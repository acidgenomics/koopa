#!/usr/bin/env bash

main() {
    # """
    # Install LAME.
    # @note Updated 2022-05-31.
    #
    # @seealso
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/lame.rb
    # """
    local app dict
    koopa_assert_has_no_args "$#"
    koopa_activate_app --build-only 'make'
    local -A app
    app['make']="$(koopa_locate_make)"
    [[ -x "${app['make']}" ]] || exit 1
    local -A dict=(
        ['jobs']="$(koopa_cpu_count)"
        ['name']='lame'
        ['prefix']="${KOOPA_INSTALL_PREFIX:?}"
        ['version']="${KOOPA_INSTALL_VERSION:?}"
    )
    dict['file']="${dict['name']}-${dict['version']}.tar.gz"
    dict['url']="https://downloads.sourceforge.net/project/${dict['name']}/\
${dict['name']}/${dict['version']}/${dict['file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}"
    koopa_cd "${dict['name']}-${dict['version']}"
    koopa_find_and_replace_in_file \
        --multiline \
        --pattern='lame_init_old\n' \
        --regex \
        --replacement='' \
        'include/libmp3lame.sym'
    conf_args=(
        "--prefix=${dict['prefix']}"
        '--disable-debug'
        '--disable-dependency-tracking'
        '--enable-nasm'
    )
    koopa_print_env
    koopa_dl 'configure args' "${conf_args[*]}"
    ./configure --help
    ./configure "${conf_args[@]}"
    "${app['make']}" VERBOSE=1 --jobs="${dict['jobs']}"
    "${app['make']}" install
    return 0
}
