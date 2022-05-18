#!/usr/bin/env bash

koopa_install_texinfo() {
    local install_args
    install_args=(
        '--installer=gnu-app'
        '--link-in-bin=bin/pdftexi2dvi'
        '--link-in-bin=bin/pod2texi'
        '--link-in-bin=bin/texi2any'
        '--link-in-bin=bin/texi2dvi'
        '--link-in-bin=bin/texi2pdf'
        '--link-in-bin=bin/texindex'
        '--name=texinfo'
        -D '--disable-dependency-tracking'
        -D '--disable-install-warnings'
    )
    if ! koopa_is_macos
    then
        install_args+=(
            '--activate-opt=gettext'
            '--activate-opt=ncurses'
            '--activate-opt=perl'
        )
    fi
    koopa_install_app "${install_args[@]}" "$@"
}
