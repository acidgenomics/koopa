#!/usr/bin/env bash

koopa_linux_update_etc_profile_d() {
    # """
    # Link shared 'zzz-koopa.sh' configuration file into '/etc/profile.d/'.
    # @note Updated 2021-11-16.
    # """
    local dict
    koopa_assert_has_no_args "$#"
    koopa_is_shared_install || return 0
    koopa_assert_is_admin
    declare -A dict=(
        [koopa_prefix]="$(koopa_koopa_prefix)"
        [file]='/etc/profile.d/zzz-koopa.sh'
    )
    # Early return if file exists and is not a symlink.
    # Previous verisons of koopa prior to 2020-05-09 created a symlink here.
    if [[ -f "${dict[file]}" ]] && [[ ! -L "${dict[file]}" ]]
    then
        return 0
    fi
    koopa_alert "Adding koopa activation to '${dict[file]}'."
    koopa_rm --sudo "${dict[file]}"
    read -r -d '' "dict[string]" << END || true
#!/bin/sh

__koopa_activate_shared_profile() {
    # """
    # Activate koopa shell for all users.
    # @note Updated 2021-11-11.
    # @seealso
    # - https://koopa.acidgenomics.com/
    # """
    # shellcheck source=/dev/null
    . "${dict[koopa_prefix]}/activate"
    return 0
}

__koopa_activate_shared_profile
END
    koopa_sudo_write_string \
        --file="${dict[file]}" \
        --string="${dict[string]}"
}
