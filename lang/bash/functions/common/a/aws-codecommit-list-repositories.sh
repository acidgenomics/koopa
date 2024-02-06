#!/usr/bin/env bash

koopa_aws_codecommit_list_repositories() {
    # """
    # List AWS CodeCommit repositories.
    # @note Updated 2024-01-31.
    #
    # @section Keyword support using query:
    # > keyword='2023'
    # > query="repositories[?contains(repositoryName, \`${keyword}\`)].\
    # > repositoryName" \
    # > aws codecommit list-repositories --query "$query" \
    # > | jq -r '.[]'
    #
    # @seealso
    # - aws codecommit list-repositories help
    # """
    local -A app dict
    app['aws']="$(koopa_locate_aws)"
    app['jq']="$(koopa_locate_jq)"
    koopa_assert_is_executable "${app[@]}"
    dict['profile']="${AWS_PROFILE:-default}"
    dict['region']="${AWS_REGION:-us-east-1}"
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
            '--region='*)
                dict['region']="${1#*=}"
                shift 1
                ;;
            '--region')
                dict['region']="${2:?}"
                shift 2
                ;;
            # Other ------------------------------------------------------------
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set \
        '--profile or AWS_PROFILE' "${dict['profile']}" \
        '--region or AWS_REGION' "${dict['region']}"
    dict['string']="$( \
        "${app['aws']}" codecommit list-repositories \
            --no-cli-pager \
            --output 'json' \
            --profile "${dict['profile']}" \
            --region "${dict['region']}" \
        | "${app['jq']}" --raw-output '.repositories[].repositoryName' \
    )"
    [[ -n "${dict['string']}" ]] || return 1
    koopa_print "${dict['string']}"
    return 0
}
