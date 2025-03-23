#!/usr/bin/env bash

koopa_linux_aws_ec2_instance_type() {
    # """
    # AWS EC2 current instance type.
    # @note Updated 2025-02-04.
    #
    # @seealso
    # - https://stackoverflow.com/questions/51486405/
    # """
    local -A app dict
    koopa_assert_has_no_args "$#"
    app['ec2_metadata']="$(koopa_linux_locate_ec2_metadata)"
    koopa_assert_is_executable "${app[@]}"
    dict['string']="$("${app['ec2_metadata']}" --instance-type)"
    [[ -n "${dict['string']}" ]] || return 1
    koopa_print "${dict['string']}"
    return 0
}
