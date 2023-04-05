#!/usr/bin/env bash

# FIXME Need to add support for profile here.

koopa_aws_codecommit_list_repositories() {
    # """
    # List AWS CodeCommit repositories.
    # @note Updated 2023-04-05.
    # """
    local -A app dict
    app['aws']="$(koopa_locate_aws)"
    app['jq']="$(koopa_locate_jq)"
    [[ -x "${app['aws']}" ]] || exit 1
    [[ -x "${app['jq']}" ]] || exit 1
    dict['string']="$( \
        "${app['aws']}" codecommit list-repositories \
            | "${app['jq']}" --raw-output '.repositories[].repositoryName' \
    )"
    [[ -n "${dict['string']}" ]] || return 1
    koopa_print "${dict['string']}"
    return 0
}
