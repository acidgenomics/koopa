#!/usr/bin/env bash

koopa_list_app_versions() {
    # """
    # List installed application versions.
    # @note Updated 2022-02-11.
    # """
    local dict
    koopa_assert_has_no_args "$#"
    declare -A dict=(
        [prefix]="$(koopa_app_prefix)"
    )
    if [[ ! -d "${dict[prefix]}" ]]
    then
        koopa_alert_note "No apps are installed in '${dict[prefix]}'."
        return 0
    fi
    dict[str]="$( \
        koopa_find \
            --max-depth=2 \
            --min-depth=2 \
            --prefix="${dict[prefix]}" \
            --sort \
            --type='d' \
    )"
    [[ -n "${dict[str]}" ]] || return 1
    koopa_print "${dict[str]}"
    return 0
}
