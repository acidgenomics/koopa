#!/usr/bin/env zsh

_koopa_is_aws_ec2() {
    [[ -x '/usr/bin/ec2metadata' ]] && return 0
    [[ "$(hostname -d)" == 'ec2.internal' ]] && return 0
    return 1
}
