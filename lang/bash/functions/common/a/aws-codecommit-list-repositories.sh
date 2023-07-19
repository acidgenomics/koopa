#!/usr/bin/env bash

koopa_aws_codecommit_list_repositories() {
    # """
    # List AWS CodeCommit repositories.
    # @note Updated 2023-07-18.
    #
    # @seealso
    # - aws codecommit list-repositories help
    # """
    local -A app dict
    app['aws']="$(koopa_locate_aws)"
    app['jq']="$(koopa_locate_jq)"
    koopa_assert_is_executable "${app[@]}"
    dict['profile']="${AWS_PROFILE:-default}"
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--profile='*)
                dict['profile']="${1#*=}"
                shift 1
                ;;
            '--profile')
                dict['profile']="${2:?}"
                shift 2
                ;;
            # Other ------------------------------------------------------------
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set '--profile or AWS_PROFILE' "${dict['profile']}"
    dict['string']="$( \
        "${app['aws']}" codecommit list-repositories \
            --no-cli-pager \
            --output 'json' \
            --profile "${dict['profile']}" \
        | "${app['jq']}" --raw-output '.repositories[].repositoryName' \
    )"
    [[ -n "${dict['string']}" ]] || return 1
    koopa_print "${dict['string']}"
    return 0
}
