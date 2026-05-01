#!/usr/bin/env bash

_koopa_list_app_versions() {
    # """
    # List installed application versions.
    # @note Updated 2023-04-06.
    # """
    local -A dict
    _koopa_assert_has_no_args "$#"
    dict['prefix']="$(_koopa_app_prefix)"
    if [[ ! -d "${dict['prefix']}" ]]
    then
        _koopa_alert_note "No apps are installed in '${dict['prefix']}'."
        return 0
    fi
    dict['str']="$( \
        _koopa_find \
            --max-depth=2 \
            --min-depth=2 \
            --prefix="${dict['prefix']}" \
            --sort \
            --type='d' \
    )"
    [[ -n "${dict['str']}" ]] || return 1
    _koopa_print "${dict['str']}"
    return 0
}
