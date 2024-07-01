#!/usr/bin/env bash

koopa_debian_apt_delete_key() {
    # """
    # Delete an apt repo GPG key.
    # @note Updated 2024-07-01.
    # """
    local -A dict
    local name
    koopa_assert_has_args "$#"
    koopa_assert_is_admin
    dict['prefix']="$(koopa_debian_apt_key_prefix)"
    for name in "$@"
    do
        local file
        file="${dict['prefix']}/koopa-${name}.gpg"
        if [[ ! -f "$file" ]]
        then
            koopa_alert_note "File does not exist: '${file}'."
            continue
        fi
        koopa_rm --sudo "$file"
    done
    return 0
}
