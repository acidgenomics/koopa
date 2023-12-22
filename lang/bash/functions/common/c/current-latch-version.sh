#!/usr/bin/env bash

koopa_current_latch_version() {
    # """
    # Current latch package version at pypi.
    # @note Updated 2023-12-22.
    #
    # Our awk command removes empty lines with NF, trims whitespace, and then
    # prints the second column in the string, which contains the version.
    # """
    local -A app
    local string
    koopa_assert_has_no_args "$#"
    app['awk']="$(koopa_locate_awk)"
    app['curl']="$(koopa_locate_curl)"
    app['pup']="$(koopa_locate_pup)"
    koopa_assert_is_executable "${app[@]}"
    # shellcheck disable=SC2016
    string="$( \
        "${app['curl']}" -s 'https://pypi.org/project/latch/' \
            | "${app['pup']}" 'h1 text{}' \
            | "${app['awk']}" 'NF {$1=$1; print $2}'
    )"
    [[ -n "$string" ]] || return 1
    koopa_print "$string"
    return 0
}
