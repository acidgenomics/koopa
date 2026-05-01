#!/usr/bin/env bash

_koopa_aws_ec2_map_instance_ids_to_names() {
    # """
    # Map AWS EC2 instance identifiers to human-friendly names.
    # @note Updated 2023-07-18.
    # """
    local -A app dict
    local -a ids names out
    app['aws']="$(_koopa_locate_aws)"
    app['jq']="$(_koopa_locate_jq)"
    _koopa_assert_is_executable "${app[@]}"
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
    dict['json']="$( \
        "${app['aws']}" ec2 describe-instances \
            --no-cli-pager \
            --output 'json' \
            --profile "${dict['profile']}" \
    )"
    readarray -t ids <<< "$( \
        _koopa_print "${dict['json']}" \
        | "${app['jq']}" --raw-output \
            '.Reservations[] | "\(.Instances[].InstanceId)"' \
    )"
    _koopa_assert_is_array_non_empty "${ids[@]}"
    readarray -t names <<< "$( \
        _koopa_print "${dict['json']}" \
        | "${app['jq']}" --raw-output \
            '.Reservations[] | "\(.Instances[].Tags[0].Value)"' \
    )"
    _koopa_assert_is_array_non_empty "${names[@]}"
    for i in "${!ids[@]}"
    do
        out+=("${ids[$i]} : ${names[$i]}")
    done
    _koopa_print "${out[@]}"
    return 0
}
