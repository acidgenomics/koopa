#!/usr/bin/env bash

_koopa_linux_aws_ec2_instance_id() {
    # """
    # AWS EC2 current instance identifier.
    # @note Updated 2025-02-04.
    #
    # @seealso
    # - https://stackoverflow.com/questions/625644/
    # """
    local -A app dict
    _koopa_assert_has_no_args "$#"
    app['ec2_metadata']="$(_koopa_linux_locate_ec2_metadata)"
    _koopa_assert_is_executable "${app[@]}"
    dict['string']="$("${app['ec2_metadata']}" --instance-id)"
    [[ -n "${dict['string']}" ]] || return 1
    _koopa_print "${dict['string']}"
    return 0
}
