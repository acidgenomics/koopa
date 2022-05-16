#!/usr/bin/env bash

koopa_admin_group() {
    # """
    # Return the administrator group.
    # @note Updated 2022-02-11.
    #
    # Usage of 'groups' can be terribly slow for domain users. Instead of grep
    # matching against 'groups' return, just set the expected default per Linux
    # distro. In the event that we're unsure, the function will intentionally
    # error.
    # """
    local group
    koopa_assert_has_no_args "$#"
    if koopa_is_alpine
    then
        group='wheel'
    elif koopa_is_arch
    then
        group='wheel'
    elif koopa_is_debian_like
    then
        group='sudo'
    elif koopa_is_fedora_like
    then
        group='wheel'
    elif koopa_is_macos
    then
        group='admin'
    elif koopa_is_opensuse
    then
        group='wheel'
    else
        koopa_stop 'Failed to determine admin group.'
    fi
    koopa_print "$group"
    return 0
}
