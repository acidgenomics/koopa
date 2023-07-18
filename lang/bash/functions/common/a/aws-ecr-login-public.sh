#!/usr/bin/env bash

koopa_aws_ecr_login_public() {
    # """
    # Log in to AWS ECR public registry.
    # @note Updated 2023-07-18.
    # """
    local -A app dict
    app['aws']="$(koopa_locate_aws)"
    app['docker']="$(koopa_locate_docker)"
    koopa_assert_is_executable "${app[@]}"
    dict['profile']="${AWS_ECR_PROFILE:-}"
    dict['region']="${AWS_ECR_REGION:-}"
    dict['repo_url']='public.ecr.aws'
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
        '--profile or AWS_ECR_PROFILE' "${dict['profile']}" \
        '--region or AWS_ECR_REGION' "${dict['region']}"
    koopa_alert "Logging into '${dict['repo_url']}'."
    "${app['docker']}" logout "${dict['repo_url']}" >/dev/null || true
    "${app['aws']}" ecr-public get-login-password \
        --profile "${dict['profile']}" \
        --region "${dict['region']}" \
    | "${app['docker']}" login \
        --password-stdin \
        --username 'AWS' \
        "${dict['repo_url']}" \
        >/dev/null \
    || return 1
    return 0
}
