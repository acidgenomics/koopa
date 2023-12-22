#!/usr/bin/env bash

koopa_current_aws_cli_version() {
    # """
    # Get the current AWS CLI version.
    # @note Updated 2023-12-22.
    # """
    local -A app
    local string
    koopa_assert_has_no_args "$#"
    app['gh']="$(koopa_locate_gh)"
    app['head']="$(koopa_locate_head)"
    app['jq']="$(koopa_locate_jq)"
    app['sort']="$(koopa_locate_sort)"
    string="$( \
        "${app['gh']}" api 'https://api.github.com/repos/aws/aws-cli/tags' \
            | "${app['jq']}" --raw-output '.[].name' \
            | "${app['sort']}" -nr \
            | "${app['head']}" -n 1 \
    )"
    [[ -n "$string" ]] || return 1
    koopa_print "$string"
    return 0
}
