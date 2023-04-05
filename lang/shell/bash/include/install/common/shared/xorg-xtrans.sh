#!/usr/bin/env bash

main() {
    # """
    # Install xorg-xtrans.
    # @note Updated 2023-03-27.
    #
    # @seealso
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/xtrans.rb
    # - https://github.com/maxim-belkin/homebrew-xorg/issues/453
    # """
    local app conf_args dict
    koopa_assert_has_no_args "$#"
    koopa_activate_app --build-only 'make' 'pkg-config'
    koopa_activate_app 'xorg-xorgproto'
    declare -A app
    app['make']="$(koopa_locate_make)"
    [[ -x "${app['make']}" ]] || exit 1
    declare -A dict=(
        ['jobs']="$(koopa_cpu_count)"
        ['name']='xtrans'
        ['prefix']="${KOOPA_INSTALL_PREFIX:?}"
        ['version']="${KOOPA_INSTALL_VERSION:?}"
    )
    dict['file']="${dict['name']}-${dict['version']}.tar.bz2"
    dict['url']="https://www.x.org/archive/individual/lib/${dict['file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}"
    koopa_cd "${dict['name']}-${dict['version']}"
    conf_args=(
        "--prefix=${dict['prefix']}"
        '--disable-dependency-tracking'
        '--disable-silent-rules'
        '--enable-docs=no'
    )
    # Refer to line 84.
    # NOTE We want to replace '<sys/stropts.h>' but not '<stropts.h>'.
    koopa_find_and_replace_in_file \
        --fixed \
        --pattern='# include <sys/stropts.h>' \
        --replacement='# include <sys/ioctl.h>' \
        'Xtranslcl.c'
    koopa_print_env
    koopa_dl 'configure args' "${conf_args[*]}"
    ./configure --help
    ./configure "${conf_args[@]}"
    "${app['make']}" VERBOSE=1 --jobs="${dict['jobs']}"
    "${app['make']}" install
    return 0
}
