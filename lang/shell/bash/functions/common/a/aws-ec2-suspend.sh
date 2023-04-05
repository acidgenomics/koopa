#!/usr/bin/env bash

koopa_aws_ec2_suspend() {
    # """
    # Suspend current AWS EC2 instance.
    # @note Updated 2023-04-03.
    # """
    local -A app dict
    app['aws']="$(koopa_locate_aws)"
    [[ -x "${app['aws']}" ]] || exit 1
    dict['id']="$(koopa_aws_ec2_instance_id)"
    [[ -n "${dict['id']}" ]] || return 1
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
    koopa_alert "Suspending EC2 instance '${dict['id']}'."
    "${app['aws']}" --profile="${dict['profile']}" \
        ec2 stop-instances --instance-id "${dict['id']}" \
        >/dev/null
    return 0
}
