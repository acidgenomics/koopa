#!/usr/bin/env bash

main() {
    # """
    # Install xorg-xtrans.
    # @note Updated 2025-02-20.
    #
    # @seealso
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/xtrans.rb
    # - https://github.com/maxim-belkin/homebrew-xorg/issues/453
    # """
    local -A dict
    local -a conf_args
    _koopa_activate_app --build-only 'pkg-config'
    _koopa_activate_app 'xorg-xorgproto'
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    conf_args=(
        '--disable-dependency-tracking'
        '--disable-silent-rules'
        '--enable-docs=no'
        "--prefix=${dict['prefix']}"
    )
# >     dict['url']="https://www.x.org/archive/individual/lib/\
# > xtrans-${dict['version']}.tar.gz"
    dict['url']="https://xorg.freedesktop.org/archive/individual/lib/\
xtrans-${dict['version']}.tar.xz"
    _koopa_download "${dict['url']}"
    _koopa_extract "$(_koopa_basename "${dict['url']}")" 'src'
    _koopa_cd 'src'
    _koopa_find_and_replace_in_file \
        --fixed \
        --pattern='# include <sys/stropts.h>' \
        --replacement='# include <sys/ioctl.h>' \
        'Xtranslcl.c'
    _koopa_make_build "${conf_args[@]}"
    return 0
}
