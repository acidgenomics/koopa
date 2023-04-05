#!/usr/bin/env bash

koopa_extract_version() {
    # """
    # Extract version number.
    # @note Updated 2022-08-30.
    #
    # @examples
    # > koopa_extract_version "$(bash --version)"
    # # 5.1.16
    # """
    local app arg dict
    local -A app
    app['head']="$(koopa_locate_head --allow-system)"
    [[ -x "${app['head']}" ]] || exit 1
    local -A dict=(
        ['pattern']="$(koopa_version_pattern)"
    )
    if [[ "$#" -eq 0 ]]
    then
        args=("$(</dev/stdin)")
    else
        args=("$@")
    fi
    for arg in "${args[@]}"
    do
        local str
        str="$( \
            koopa_grep \
                --only-matching \
                --pattern="${dict['pattern']}" \
                --regex \
                --string="$arg" \
            | "${app['head']}" -n 1 \
        )"
        [[ -n "$str" ]] || return 1
        koopa_print "$str"
    done
    return 0
}
