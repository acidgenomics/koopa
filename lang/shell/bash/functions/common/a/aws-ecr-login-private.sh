#!/usr/bin/env bash

koopa_aws_ecr_login_private() {
    # """
    # Log in to AWS ECR private registry.
    # @note Updated 2023-03-15.
    #
    # @seealso
    # - https://docs.aws.amazon.com/AmazonECR/latest/
    #     userguide/registry_auth.html
    # """
    local app dict
    declare -A app dict
    app['aws']="$(koopa_locate_aws)"
    app['docker']="$(koopa_locate_docker)"
    [[ -x "${app['aws']}" ]] || return 1
    [[ -x "${app['docker']}" ]] || return 1
    dict['account_id']="${AWS_ECR_ACCOUNT_ID:?}" # FIXME
    dict['profile']="${AWS_ECR_PROFILE:?}" # FIXME
    dict['region']="${AWS_ECR_REGION:?}" # FIXME
    dict['repo_url']="${dict['account_id']}.dkr.ecr.\
${dict['region']}.amazonaws.com"
    koopa_alert "Logging into '${dict['repo_url']}'."
    "${app['docker']}" logout "${dict['repo_url']}" >/dev/null || true
    "${app['aws']}" --profile="${dict['profile']}" \
        ecr get-login-password \
            --region "${dict['region']}" \
    | "${app['docker']}" login \
        --password-stdin \
        --username 'AWS' \
        "${dict['repo_url']}" \
        >/dev/null \
    || return 1
    return 0
}
