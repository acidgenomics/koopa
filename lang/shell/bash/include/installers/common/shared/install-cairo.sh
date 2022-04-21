#!/usr/bin/env bash

main() { # {{{1
    # """
    # Install Cairo.
    # @note Updated 2022-04-21.
    #
    # @seealso
    # - https://github.com/Homebrew/homebrew-core/blob/HEAD/Formula/cairo.rb
    # - https://github.com/archlinux/svntogit-packages/blob/master/cairo/
    #     trunk/PKGBUILD
    # """
    local app dict
    koopa_assert_has_no_args "$#"
    koopa_activate_opt_prefix \
        'fontconfig' \
        'freetype' \
        'glib' \
        'libpng' \
        'libx11' \
        'libxcb' \
        'libxext' \
        'libxrender' \
        'lzo' \
        'pixman' \
        'pkg-config' \
        'zlib'

    return 0
}
