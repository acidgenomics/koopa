#!/usr/bin/env bash

koopa_push_all_app_builds() {
    # """
    # Push all app builds to S3 bucket.
    # @note Updated 2022-01-05.
    #
    # Intentionally match only apps built from source within the last 48 hours.
    # """
    local app_names dict
    declare -A dict
    dict['opt_prefix']="$(koopa_opt_prefix)"
    readarray -t app_names <<< "$( \
        koopa_find \
            --days-modified-within=7 \
            --min-depth=1 \
            --max-depth=1 \
            --prefix="${dict['opt_prefix']}" \
            --sort \
            --type='l' \
        | koopa_basename \
    )"
    if koopa_is_array_empty "${app_names[@]}"
    then
        koopa_stop 'No apps were built recently.'
    fi
    koopa_push_app_build "${app_names[@]}"
    return 0
}
