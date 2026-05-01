#!/usr/bin/env bash

_koopa_uninstall_perl() {
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
    _koopa_uninstall_app \
        --name='perl' \
        "$@"
}
