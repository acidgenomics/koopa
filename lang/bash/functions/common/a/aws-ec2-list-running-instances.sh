#!/usr/bin/env bash

koopa_aws_ec2_list_running_instances() {
    # """
    # List running EC2 instances.
    # @note Updated 2023-07-18.
    #
    # @seealso
    # - aws ec2 describe-instances help
    # - https://stackoverflow.com/questions/23936216/
    # """
    local -A app bool dict
    local -a filters
    app['aws']="$(koopa_locate_aws)"
    koopa_assert_is_executable "${app[@]}"
    bool['name']=0
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
            # Flags ------------------------------------------------------------
            '--with-name')
                bool['name']=1
                shift 1
                ;;
            # Other ------------------------------------------------------------
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set '--profile or AWS_PROFILE' "${dict['profile']}"
    if [[ "${bool['name']}" -eq 1 ]]
    then
        dict['query']="Reservations[*].Instances[*][Tags[?Key=='Name'].Value[],\
InstanceId,NetworkInterfaces[0].PrivateIpAddresses[0].PrivateIpAddress]"
        filters+=('Name=tag-key,Values=Name')
    else
        dict['query']='Reservations[*].Instances[*].[InstanceId]'
    fi
    filters+=('Name=instance-state-name,Values=running')
    dict['out']="$( \
        "${app['aws']}" ec2 describe-instances \
            --filters "${filters[@]}" \
            --no-cli-pager \
            --output 'text' \
            --profile "${dict['profile']}" \
            --query "${dict['query']}" \
    )"
    [[ -n "${dict['out']}" ]] || return 1
    koopa_print "${dict['out']}"
    return 0
}
