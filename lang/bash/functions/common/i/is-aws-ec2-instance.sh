#!/usr/bin/env bash

koopa_is_aws_ec2_instance() {
    # """
    # Is the current environment running inside an AWS EC2 instance?
    # @note Updated 2025-04-17.
    # """
    local -A app
    koopa_is_linux || return 1
    app['ec2_metadata']="$(koopa_linux_locate_ec2_metadata --allow-missing)"
    [[ -x "${app['ec2_metadata']}" ]]
}
