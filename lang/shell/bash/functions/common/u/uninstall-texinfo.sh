#!/usr/bin/env bash

koopa_uninstall_texinfo() {
    koopa_uninstall_app \
        --name='texinfo' \
        --unlink-in-bin='pdftexi2dvi' \
        --unlink-in-bin='pod2texi' \
        --unlink-in-bin='texi2any' \
        --unlink-in-bin='texi2dvi' \
        --unlink-in-bin='texi2pdf' \
        --unlink-in-bin='texindex' \
        "$@"
}
