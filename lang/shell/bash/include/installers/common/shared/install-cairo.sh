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
        'fontconfig' \ # FIXME
        'freetype' \
        'glib' \ # FIXME
        'libpng' \
        'libx11' \ # FIXME
        'libxcb' \ # FIXME
        'libxext' \ # FIXME
        'libxrender' \ # FIXME
        'lzo' \ # FIXME
        'pixman' \ # FIXME
        'pkg-config' \
        'zlib'
    declare -A app=(
        [make]="$(koopa_locate_make)"
    )
    declare -A dict=(
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    return 0
}
