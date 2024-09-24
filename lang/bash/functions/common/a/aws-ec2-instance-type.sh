#!/usr/bin/env bash

koopa_aws_ec2_instance_type() {
    # """
    # AWS EC2 current instance type.
    # @note Updated 2024-09-24.
    #
    # @seealso
    # - https://stackoverflow.com/questions/51486405/
    # """
    local -A app dict
    koopa_assert_has_no_args "$#"
    if koopa_is_ubuntu_like
    then
        app['ec2metadata']='/usr/bin/ec2metadata'
    else
        # e.g. Amazon Linux 2.
        app['ec2metadata']='/usr/bin/ec2-metadata'
    fi
    koopa_assert_is_executable "${app[@]}"
    dict['string']="$("${app['ec2metadata']}" --instance-type)"
    [[ -n "${dict['string']}" ]] || return 1
    koopa_print "${dict['string']}"
    return 0
}
