#!/usr/bin/env bash

# FIXME Need to add support for profile here.

koopa_aws_codecommit_list_repositories() {
    # """
    # List AWS CodeCommit repositories.
    # @note Updated 2022-11-17.
    # """
    local app dict
    declare -A app=(
        ['aws']="$(koopa_locate_aws)"
        ['jq']="$(koopa_locate_jq)"
    )
    [[ -x "${app['aws']}" ]] || return 1
    [[ -x "${app['jq']}" ]] || return 1
    declare -A dict
    dict['string']="$( \
        "${app['aws']}" codecommit list-repositories \
            | "${app['jq']}" --raw-output '.repositories[].repositoryName' \
    )"
    [[ -n "${dict['string']}" ]] || return 1
    koopa_print "${dict['string']}"
    return 0
}
