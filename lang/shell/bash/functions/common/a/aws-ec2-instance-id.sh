#!/usr/bin/env bash

koopa_aws_ec2_instance_id() {
    # """
    # AWS EC2 instance identifier.
    # @note Updated 2022-03-21.
    #
    # @seealso
    # - https://stackoverflow.com/questions/625644/
    # """
    local app
    declare -A app
    if koopa_is_ubuntu
    then
        app[ec2_metadata]='/usr/bin/ec2metadata'
    else
        # e.g. Amazon Linux 2.
        app[ec2_metadata]='/usr/bin/ec2-metadata'
    fi
    [[ -x "${app[ec2_metadata]}" ]] || return 1
    str="$("${app[ec2_metadata]}" --instance-id)"
    [[ -n "$str" ]] || return 1
    koopa_print "$str"
    return 0
}
