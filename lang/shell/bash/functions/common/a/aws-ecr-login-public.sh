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
        ['region']="${AWS_ECR_REGION:?}"
    )
    "${app['aws']}" ecr-public get-login-password \
        --region "${dict['region']}" \
    | "${app['docker']}" login \
        --password-stdin \
        --username 'AWS' \
        'public.ecr.aws' \
        >/dev/null
    return 0
}
