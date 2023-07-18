#!/usr/bin/env bash

# FIXME Need to add support for profile and region.
# FIXME Need to ensure we're returning JSON here.

koopa_aws_ec2_map_instance_ids_to_names() {
    # """
    # Map AWS EC2 instance identifiers to human-friendly names.
    # @note Updated 2023-07-18.
    # """
    local -A app dict
    local -a ids names out
    app['aws']="$(koopa_locate_aws)"
    app['jq']="$(koopa_locate_jq)"
    koopa_assert_is_executable "${app[@]}"
    # FIXME Add support for '--profile'.
    # FIXME Add support for '--region'.
    dict['json']="$( \
        "${app['aws']}" ec2 describe-instances \
            --output 'json' \
    )"
    readarray -t ids <<< "$( \
        koopa_print "${dict['json']}" \
        | "${app['jq']}" --raw-output \
            '.Reservations[] | "\(.Instances[].InstanceId)"' \
    )"
    koopa_assert_is_array_non_empty "${ids[@]}"
    readarray -t names <<< "$( \
        koopa_print "${dict['json']}" \
        | "${app['jq']}" --raw-output \
            '.Reservations[] | "\(.Instances[].Tags[0].Value)"' \
    )"
    koopa_assert_is_array_non_empty "${names[@]}"
    for i in "${!ids[@]}"
    do
        out+=("${ids[$i]} : ${names[$i]}")
    done
    koopa_print "${out[@]}"
    return 0
}
