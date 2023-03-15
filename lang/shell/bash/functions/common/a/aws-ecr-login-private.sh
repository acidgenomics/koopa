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
    declare -A app=(
        ['aws']="$(koopa_locate_aws)"
        ['docker']="$(koopa_locate_docker)"
    )
    [[ -x "${app['aws']}" ]] || return 1
    [[ -x "${app['docker']}" ]] || return 1
    declare -A dict=(
        ['account_id']="${AWS_ECR_ACCOUNT_ID:?}" # FIXME
        ['region']="${AWS_ECR_REGION:?}" # FIXME
    )
    "${app['aws']}" ecr get-login-password \
        --region "${dict['region']}" \
    | "${app['docker']}" login \
            --password-stdin \
            --username 'AWS' \
            "${dict['account_id']}.dkr.ecr.${dict['region']}.amazonaws.com" \
        >/dev/null
    return 0
}
