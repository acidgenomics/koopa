#!/bin/sh

_koopa_is_aws_ec2() {
    # """
    # Is the current shell running on an AWS EC2 instance?
    # @note Updated 2023-09-14.
    #
    # @seealso
    # - https://serverfault.com/questions/462903/
    # """
    [ -x '/usr/bin/ec2metadata' ] && return 0
    [ "$(hostname -d)" = 'ec2.internal' ] && return 0
    return 1
}
