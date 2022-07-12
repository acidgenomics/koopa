#!/usr/bin/env bash

# FIXME This is having trouble locating '-lX11' on Ubuntu...

# NOTE Consider adding support for libxft.
# https://gitlab.freedesktop.org/xorg/lib/libxft

main() {
    # """
    # Install FLTK.
    # @note Updated 2022-07-12.
    #
    # @seealso
    # - https://github.com/Homebrew/homebrew-core/blob/HEAD/Formula/fltk.rb
    # - https://courses.cs.washington.edu/courses/csep557/14au/tools/
    #     fltk_install.html
    # """
    local app conf_args dict
    koopa_assert_has_no_args "$#"
    koopa_activate_build_opt_prefix 'pkg-config'
    koopa_activate_opt_prefix \
        'freetype' \
        'xorg-xorgproto' \
        'xorg-xcb-proto' \
        'xorg-libpthread-stubs' \
        'xorg-libxau' \
        'xorg-libxdmcp' \
        'xorg-libxcb' \
        'xorg-libx11' \
        'xorg-libxext' \
        'xorg-libxrender' \
        'cairo'
    # >     'xorg-xorgproto' \
    # >     'xorg-xtrans' \
    # >     'xorg-libpthread-stubs' \
    # >     'xorg-libxau' \
    # >     'xorg-libxdmcp' \
    # >     'xorg-libxcb' \
    # >     'xorg-libx11'
    declare -A app=(
        [make]="$(koopa_locate_make)"
    )
    declare -A dict=(
        [jobs]="$(koopa_cpu_count)"
        [name]='fltk'
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    dict[file]="${dict[name]}-${dict[version]}-source.tar.gz"
    dict[url]="https://www.${dict[name]}.org/pub/${dict[name]}/\
${dict[version]}/${dict[file]}"
    koopa_download "${dict[url]}" "${dict[file]}"
    koopa_extract "${dict[file]}"
    koopa_cd "${dict[name]}-${dict[version]}"
    conf_args=(
        "--prefix=${dict[prefix]}"
        # > '--disable-xft'
        '--enable-cairo'
        '--enable-x11'
        '--enable-shared'
        '--enable-threads'
    )
    ./configure --help # FIXME
    ./configure "${conf_args[@]}"
    "${app[make]}" --jobs="${dict[jobs]}"
    "${app[make]}" install
    return 0
}
