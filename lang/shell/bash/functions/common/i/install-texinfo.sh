#!/usr/bin/env bash

koopa_install_texinfo() {
    koopa_install_app \
        --link-in-bin='pdftexi2dvi' \
        --link-in-bin='pod2texi' \
        --link-in-bin='texi2any' \
        --link-in-bin='texi2dvi' \
        --link-in-bin='texi2pdf' \
        --link-in-bin='texindex' \
        --name='texinfo' \
        "$@"
}
