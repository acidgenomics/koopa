#!/usr/bin/env bash

koopa_push_all_app_builds() {
    # """
    # Push all koopa app builds.
    # @note Updated 2022-07-15.
    # """
    local app dict names
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [basename]="$(koopa_locate_basename)"
        [grep]="$(koopa_locate_grep)"
        [xargs]="$(koopa_locate_xargs)"
    )
    [[ -x "${app['basename']}" ]] || return 1
    [[ -x "${app['grep']}" ]] || return 1
    [[ -x "${app['xargs']}" ]] || return 1
    declare -A dict=(
        [opt_prefix]="$(koopa_opt_prefix)"
    )
    readarray -t names <<< "$( \
        koopa_find \
            --max-depth=1 \
            --min-depth=1 \
            --prefix="${dict['opt_prefix']}" \
            --print0 \
            --sort \
            --type='l' \
        | "${app['xargs']}" -0 -n 1 "${app['basename']}" \
        | "${app['grep']}" -Ev '^.+-packages$' \
    )"
    koopa_assert_is_array_non_empty "${names[@]:-}"
    koopa_push_app_build "${names[@]}"
    return 0
}
