#!/usr/bin/env bash

_koopa_linux_aws_ec2_stop() {
    # """
    # Stop (suspend) current AWS EC2 instance.
    # @note Updated 2024-02-04.
    #
    # @seealso
    # - aws ec2 stop-instances help
    # """
    local -A app dict
    app['aws']="$(_koopa_locate_aws)"
    _koopa_assert_is_executable "${app[@]}"
    dict['id']="$(_koopa_linux_aws_ec2_instance_id)"
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
                _koopa_invalid_arg "$1"
                ;;
        esac
    done
    _koopa_assert_is_set '--profile or AWS_PROFILE' "${dict['profile']}"
    _koopa_alert "Stopping EC2 instance '${dict['id']}'."
    "${app['aws']}" ec2 stop-instances \
        --instance-ids "${dict['id']}" \
        --no-cli-pager \
        --output 'text' \
        --profile "${dict['profile']}"
    return 0
}
