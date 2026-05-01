#!/usr/bin/env bash

_koopa_linux_update_profile_d() {
    # """
    # Link shared koopa configuration file into '/etc/profile.d/'.
    # @note Updated 2025-03-01.
    # """
    local -A dict
    _koopa_assert_has_no_args "$#"
    _koopa_is_shared_install || return 0
    _koopa_assert_is_admin
    dict['koopa_prefix']="$(_koopa_koopa_prefix)"
    dict['file']="$(_koopa_linux_profile_d_file)"
    dict['today']="$(_koopa_today)"
    # Early return if file exists and is not a symlink.
    # Previous verisons of koopa prior to 2020-05-09 created a symlink here.
    if [[ -f "${dict['file']}" ]] && [[ ! -L "${dict['file']}" ]]
    then
        return 0
    fi
    _koopa_alert "Adding koopa activation to '${dict['file']}'."
    _koopa_rm --sudo "${dict['file']}"
    read -r -d '' "dict[string]" << END || true
_koopa_activate_shared_profile() {
    if [ -f '${dict['koopa_prefix']}/activate' ]
    then
        . '${dict['koopa_prefix']}/activate'
    fi
    return 0
}

_koopa_activate_shared_profile
END
    _koopa_sudo_write_string \
        --file="${dict['file']}" \
        --string="${dict['string']}"
}
