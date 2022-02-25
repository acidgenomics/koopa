#!/usr/bin/env bash

koopa_linux_fix_sudo_setrlimit_error() { # {{{1
    # """
    # Fix bug in recent version of sudo.
    # @note Updated 2021-03-24.
    #
    # This is popping up on Docker builds:
    # sudo: setrlimit(RLIMIT_CORE): Operation not permitted
    #
    # @seealso
    # - https://ask.fedoraproject.org/t/
    #       sudo-setrlimit-rlimit-core-operation-not-permitted/4223
    # - https://bugzilla.redhat.com/show_bug.cgi?id=1773148
    # """
    local file
    koopa_assert_has_no_args "$#"
    string='Set disable_coredump false'
    file='/etc/sudo.conf'
    koopa_sudo_append_string "$string" "$file"
    return 0
}
