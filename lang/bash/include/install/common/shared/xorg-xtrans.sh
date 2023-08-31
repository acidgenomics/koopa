#!/usr/bin/env bash

main() {
    # """
    # Install xorg-xtrans.
    # @note Updated 2023-08-31.
    #
    # @seealso
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/xtrans.rb
    # - https://github.com/maxim-belkin/homebrew-xorg/issues/453
    # """
    local -A dict
    local -a conf_args
    koopa_activate_app --build-only 'pkg-config'
    koopa_activate_app 'xorg-xorgproto'
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    conf_args=(
        '--disable-dependency-tracking'
        '--disable-silent-rules'
        '--enable-docs=no'
        "--prefix=${dict['prefix']}"
    )
    # FIXME Switch to 'xz' with next update.
    dict['url']="https://www.x.org/archive/individual/lib/\
xtrans-${dict['version']}.tar.gz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    koopa_find_and_replace_in_file \
        --fixed \
        --pattern='# include <sys/stropts.h>' \
        --replacement='# include <sys/ioctl.h>' \
        'Xtranslcl.c'
    koopa_make_build "${conf_args[@]}"
    return 0
}
