#!/usr/bin/env bash

koopa_aws_ecr_login_public() {
    # """
    # Log in to AWS ECR public registry.
    # @note Updated 2023-03-15.
    # """
    local app dict
    declare -A app=(
        ['aws']="$(koopa_locate_aws)"
        ['docker']="$(koopa_locate_docker)"
    )
    [[ -x "${app['aws']}" ]] || return 1
    [[ -x "${app['docker']}" ]] || return 1
    declare -A dict=(
        ['profile']="${AWS_ECR_PROFILE:?}" # FIXME
        ['region']="${AWS_ECR_REGION:?}" # FIXME
        ['repo_url']='public.ecr.aws'
    )
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
