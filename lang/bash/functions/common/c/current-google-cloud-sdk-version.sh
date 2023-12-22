#!/usr/bin/env bash

koopa_current_google_cloud_sdk_version() {
    # """
    # Get the current Google Cloud SDK version.
    # @note Updated 2023-12-22.
    # """
    local -A app dict
    koopa_assert_has_no_args "$#"
    app['awk']="$(koopa_locate_awk)"
    app['pup']="$(koopa_locate_pup)"
    koopa_assert_is_executable "${app[@]}"
    dict['url']='https://cloud.google.com/sdk/docs/release-notes'
    # shellcheck disable=SC2016
    dict['version']="$( \
        koopa_parse_url "${dict['url']}" \
            | "${app['pup']}" 'h2 text{}' \
            | "${app['awk']}" 'NR==1 {print $1}' \
    )"
    [[ -n "${dict['version']}" ]] || return 1
    koopa_print "${dict['version']}"
    return 0
}
