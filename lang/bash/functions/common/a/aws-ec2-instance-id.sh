#!/usr/bin/env bash

koopa_aws_ec2_instance_id() {
    # """
    # AWS EC2 current instance identifier.
    # @note Updated 2023-04-06.
    #
    # @seealso
    # - https://stackoverflow.com/questions/625644/
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
    dict['string']="$("${app['ec2metadata']}" --instance-id)"
    [[ -n "${dict['string']}" ]] || return 1
    koopa_print "${dict['string']}"
    return 0
}
