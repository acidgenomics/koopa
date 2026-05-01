#!/usr/bin/env bash

# FIXME Add option for current user only.

_koopa_disable_passwordless_sudo() {
    # """
    # Disable passwordless sudo access for all admin users.
    # @note Updated 2024-08-12.
    # """
    local -A dict
    _koopa_assert_has_no_args "$#"
    _koopa_assert_is_admin
    dict['group']="$(_koopa_admin_group_name)"
    dict['file']="/etc/sudoers.d/koopa-${dict['group']}"
    if [[ -f "${dict['file']}" ]]
    then
        _koopa_alert "Removing sudo permission file at '${dict['file']}'."
        _koopa_rm --sudo "${dict['file']}"
    fi
    _koopa_alert_success 'Passwordless sudo is disabled.'
    return 0
}
