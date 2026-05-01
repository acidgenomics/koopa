#!/usr/bin/env bash

_koopa_debian_apt_delete_repo() {
    # """
    # Delete an apt repo file.
    # @note Updated 2023-04-06.
    # """
    local -A dict
    local name
    _koopa_assert_has_args "$#"
    _koopa_assert_is_admin
    dict['prefix']="$(_koopa_debian_apt_sources_prefix)"
    for name in "$@"
    do
        local file
        file="${dict['prefix']}/koopa-${name}.list"
        if [[ ! -f "$file" ]]
        then
            _koopa_alert_note "File does not exist: '${file}'."
            continue
        fi
        _koopa_rm --sudo "$file"
    done
    return 0
}
