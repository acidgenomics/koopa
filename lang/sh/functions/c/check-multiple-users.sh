#!/bin/sh

_koopa_check_multiple_users() {
    # """
    # Check for multiple users, and print who is logged in.
    # @note Updated 2023-09-14.
    #
    # Only performing this check on AWS EC2 currently.
    # """
    _koopa_is_aws_ec2 || return 0
    __kvar_n="$(_koopa_logged_in_user_count)"
    if [ "$__kvar_n" -gt 1 ]
    then
        __kvar_users="$(_koopa_logged_in_users)"
        _koopa_print "Multiple users active: ${__kvar_users}"
        unset -v __kvar_users
    fi
    unset -v __kvar_n
    return 0
}
