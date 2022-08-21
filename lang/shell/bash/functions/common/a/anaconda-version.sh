#!/usr/bin/env bash

koopa_anaconda_version() {
    # """
    # Anaconda verison.
    # @note Updated 2022-07-15.
    #
    # @examples
    # # Version-specific lookup:
    # > koopa_anaconda_version '/opt/koopa/app/anaconda/2021.05/bin/conda'
    # # 2021.05
    # """
    local app str
    koopa_assert_has_args_le "$#" 1
    declare -A app=(
        ['awk']="$(koopa_locate_awk)"
        ['conda']="${1:-}"
    )
    [[ -x "${app['awk']}" ]] || return 1
    [[ -z "${app['conda']}" ]] && app[conda]="$(koopa_locate_anaconda)"
    [[ -x "${app['conda']}" ]] || return 1
    koopa_is_anaconda "${app['conda']}" || return 1
    # shellcheck disable=SC2016
    str="$( \
        "${app['conda']}" list 'anaconda' \
            | koopa_grep \
                --pattern='^anaconda ' \
                --regex \
            | "${app['awk']}" '{print $2}' \
    )"
    [[ -n "$str" ]] || return 1
    koopa_print "$str"
    return 0
}
