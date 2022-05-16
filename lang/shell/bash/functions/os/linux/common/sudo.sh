#!/usr/bin/env bash

koopa_linux_fix_sudo_setrlimit_error() {
    # """
    # Fix bug in recent version of sudo.
    # @note Updated 2022-03-01.
    #
    # This is popping up on Docker builds:
    # sudo: setrlimit(RLIMIT_CORE): Operation not permitted
    #
    # @seealso
    # - https://ask.fedoraproject.org/t/
    #       sudo-setrlimit-rlimit-core-operation-not-permitted/4223
    # - https://bugzilla.redhat.com/show_bug.cgi?id=1773148
    # """
    local dict
    koopa_assert_has_no_args "$#"
    declare -A dict=(
        [file]='/etc/sudo.conf'
        [string]='Set disable_coredump false'
    )
    koopa_sudo_append_string \
        --file="${dict[file]}" \
        --string="${dict[string]}"
    return 0
}
