#!/usr/bin/env bash



_koopa_install_perl() {
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
    _koopa_install_app \
        --name='perl' \
        "$@"
}
