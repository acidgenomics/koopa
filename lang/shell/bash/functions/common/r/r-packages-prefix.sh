#!/usr/bin/env bash

koopa_r_packages_prefix() {
    # """
    # R site library prefix.
    # @note Updated 2022-08-22.
    #
    # @usage
    # > koopa_r_packages_prefix '/opt/koopa/bin/R'
    # # /opt/koopa/app/r-packages/4.2
    # """
    local -A app dict
    app['r']="${1:?}"
    koopa_assert_is_executable "${app[@]}"
    dict['r_prefix']="$(koopa_r_prefix "${app['r']}")"
    dict['str']="${dict['r_prefix']}/site-library"
    [[ -d "${dict['str']}" ]] || return 1
    koopa_print "${dict['str']}"
    return 0
}
