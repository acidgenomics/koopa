#!/usr/bin/env bash

koopa_enable_passwordless_sudo() {
    # """
    # Enable passwordless sudo access for all admin users.
    # @note Updated 2022-07-28.
    # """
    local dict
    koopa_assert_has_no_args "$#"
    koopa_assert_is_admin
    declare -A dict
    dict[group]="$(koopa_admin_group)"
    dict[file]="/etc/sudoers.d/koopa-${dict[group]}"
    if [[ -f "${dict[file]}" ]]
    then
        koopa_alert_success "Passwordless sudo for '${dict[group]}' group \
already enabled at '${dict[file]}'."
        return 0
    fi
    koopa_alert "Modifying '${dict[file]}' to include '${dict[group]}'."
    dict[string]="%${dict[group]} ALL=(ALL) NOPASSWD: ALL"
    koopa_sudo_write_string \
        --file="${dict[file]}" \
        --string="${dict[string]}"
    koopa_chmod --sudo '0440' "${dict[file]}"
    koopa_alert_success "Passwordless sudo enabled for '${dict[group]}' \
at '${dict[file]}'."
    return 0
}
