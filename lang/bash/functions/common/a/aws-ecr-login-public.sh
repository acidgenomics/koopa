#!/usr/bin/env bash

koopa_aws_ecr_login_public() {
    # """
    # Log in to AWS ECR public registry.
    # @note Updated 2023-03-15.
    # """
    local -A app dict
    app['aws']="$(koopa_locate_aws)"
    app['docker']="$(koopa_locate_docker)"
    koopa_assert_is_executable "${app[@]}"
    dict['profile']="${AWS_ECR_PROFILE:?}" # FIXME
    dict['region']="${AWS_ECR_REGION:?}" # FIXME
    dict['repo_url']='public.ecr.aws'
    koopa_alert "Logging into '${dict['repo_url']}'."
    "${app['docker']}" logout "${dict['repo_url']}" >/dev/null || true
    "${app['aws']}" --profile="${dict['profile']}" \
        ecr-public get-login-password \
            --region "${dict['region']}" \
    | "${app['docker']}" login \
        --password-stdin \
        --username 'AWS' \
        "${dict['repo_url']}" \
        >/dev/null \
    || return 1
    return 0
}
