#!/usr/bin/env bash

koopa_linux_add_user_to_etc_passwd() {
    # """
    # Any any type of user, including domain user to passwd file.
    # @note Updated 2022-02-17.
    #
    # Necessary for running 'chsh' with a Kerberos / Active Directory domain
    # account, on AWS or Azure for example.
    #
    # Note that this function will enable use of RStudio for domain users.
    #
    # @examples
    # > koopa_linux_add_user_to_etc_passwd 'domain.user'
    # """
    local dict
    koopa_assert_has_args_le "$#" 1
    declare -A dict=(
        [passwd_file]='/etc/passwd'
        [user]="${1:-}"
    )
    koopa_assert_is_file "${dict[passwd_file]}"
    [[ -z "${dict[user]}" ]] && dict[user]="$(koopa_user)"
    if ! koopa_file_detect_fixed \
        --file="${dict[passwd_file]}" \
        --pattern="${dict[user]}" \
        --sudo
    then
        koopa_alert "Updating '${dict[passwd_file]}' to \
include '${dict[user]}'."
        dict[user_string]="$(getent passwd "${dict[user]}")"
        koopa_sudo_append_string \
            --file="${dict[passwd_file]}" \
            --string="${dict[user_string]}"
    else
        koopa_alert_note "'${dict[user]}' already defined \
in '${dict[passwd_file]}'."
    fi
    return 0
}
