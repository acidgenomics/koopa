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
        "$@"
}
