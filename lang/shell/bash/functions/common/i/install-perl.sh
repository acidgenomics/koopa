#!/usr/bin/env bash



koopa_install_perl() {
    # """
    # Not currently linking:
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
    koopa_install_app \
        --link-in-bin='cpan' \
        --link-in-bin='perl' \
        --link-in-bin='perlbug' \
        --link-in-bin='perldoc' \
        --link-in-bin='perlivp' \
        --link-in-bin='perlthanks' \
        --link-in-bin='piconv' \
        --link-in-bin='pl2pm' \
        --link-in-bin='pod2html' \
        --link-in-bin='pod2man' \
        --link-in-bin='pod2text' \
        --link-in-bin='pod2usage' \
        --link-in-bin='podchecker' \
        --link-in-bin='prove' \
        --link-in-bin='ptar' \
        --link-in-bin='ptardiff' \
        --link-in-bin='ptargrep' \
        --name='perl' \
        "$@"
}
