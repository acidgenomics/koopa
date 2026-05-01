#!/usr/bin/env bash

# FIXME Add option for current user only.

_koopa_enable_passwordless_sudo() {
    # """
    # Enable passwordless sudo access for all admin users.
    # @note Updated 2023-05-10.
    #
    # @seealso
    # - https://linuxconfig.org/configure-sudo-without-password-on-ubuntu-
    #     22-04-jammy-jellyfish-linux
    # """
    local -A dict
    _koopa_assert_has_no_args "$#"
    _koopa_assert_is_admin
    dict['group']="$(_koopa_admin_group_name)"
    dict['file']="/etc/sudoers.d/koopa-${dict['group']}"
    # NOTE This check will fail for non-root users.
    if [[ -e "${dict['file']}" ]]
    then
        _koopa_alert_success "Passwordless sudo for '${dict['group']}' group \
already enabled at '${dict['file']}'."
        return 0
    fi
    _koopa_alert "Modifying '${dict['file']}' to include '${dict['group']}'."
    dict['string']="%${dict['group']} ALL=(ALL:ALL) NOPASSWD:ALL"
    _koopa_sudo_write_string \
        --file="${dict['file']}" \
        --string="${dict['string']}"
    _koopa_chmod --sudo '0440' "${dict['file']}"
    _koopa_alert_success "Passwordless sudo enabled for '${dict['group']}' \
at '${dict['file']}'."
    return 0
}
