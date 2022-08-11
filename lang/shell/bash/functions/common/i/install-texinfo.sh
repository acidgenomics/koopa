#!/usr/bin/env bash

# FIXME Break out to separate installer. Don't use '--activate-opt' here, as
# it can cause issues with binary package install.

koopa_install_texinfo() {
    local install_args
    install_args=(
        '--installer=gnu-app'
        '--link-in-bin=pdftexi2dvi'
        '--link-in-bin=pod2texi'
        '--link-in-bin=texi2any'
        '--link-in-bin=texi2dvi'
        '--link-in-bin=texi2pdf'
        '--link-in-bin=texindex'
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
