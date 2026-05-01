#!/usr/bin/env bash

_koopa_current_google_cloud_sdk_version() {
    # """
    # Get the current Google Cloud SDK version.
    # @note Updated 2023-12-22.
    # """
    local -A app dict
    _koopa_assert_has_no_args "$#"
    app['awk']="$(_koopa_locate_awk)"
    app['pup']="$(_koopa_locate_pup)"
    _koopa_assert_is_executable "${app[@]}"
    dict['url']='https://cloud.google.com/sdk/docs/release-notes'
    # shellcheck disable=SC2016
    dict['version']="$( \
        _koopa_parse_url "${dict['url']}" \
            | "${app['pup']}" 'h2 text{}' \
            | "${app['awk']}" 'NR==1 {print $1}' \
    )"
    [[ -n "${dict['version']}" ]] || return 1
    _koopa_print "${dict['version']}"
    return 0
}
