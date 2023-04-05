#!/usr/bin/env bash

koopa_aws_ec2_instance_id() {
    # """
    # AWS EC2 instance identifier.
    # @note Updated 2023-04-05.
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
    [[ -x "${app['ec2metadata']}" ]] || exit 1
    dict['string']="$("${app['ec2metadata']}" --instance-id)"
    [[ -n "${dict['string']}" ]] || return 1
    koopa_print "${dict['string']}"
    return 0
}
