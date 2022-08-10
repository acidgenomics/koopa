#!/usr/bin/env bash

koopa_uninstall_perl() {
    # """
    # Not currently unlinking:
    # - corelist
    # - enc2xs
    # - encguess
    # - h2ph
    # - h2xs
    # - instmodsh
    # - json_pp
    # - libnetcfg
    # - perl<version>
    # - shasum
    # - splain
    # - streamzip
    # - xsubpp
    # - zipdetails
    # """
    koopa_uninstall_app \
        --name='perl' \
        --unlink-in-bin='cpan' \
        --unlink-in-bin='perl' \
        --unlink-in-bin='perlbug' \
        --unlink-in-bin='perldoc' \
        --unlink-in-bin='perlivp' \
        --unlink-in-bin='perlthanks' \
        --unlink-in-bin='piconv' \
        --unlink-in-bin='pl2pm' \
        --unlink-in-bin='pod2html' \
        --unlink-in-bin='pod2man' \
        --unlink-in-bin='pod2text' \
        --unlink-in-bin='pod2usage' \
        --unlink-in-bin='podchecker' \
        --unlink-in-bin='prove' \
        --unlink-in-bin='ptar' \
        --unlink-in-bin='ptardiff' \
        --unlink-in-bin='ptargrep' \
        "$@"
}
