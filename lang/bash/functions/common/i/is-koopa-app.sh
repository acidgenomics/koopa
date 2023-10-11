#!/usr/bin/env bash

koopa_is_koopa_app() {
    # """
    # Is a specific command installed in koopa app prefix?
    # @note Updated 2023-10-11.
    # """
    local app_prefix str
    koopa_assert_has_args "$#"
    app_prefix="$(koopa_app_prefix)"
    [[ -d "$app_prefix" ]] || return 1
    for str in "$@"
    do
        [[ -e "$str" ]] || return 1
        str="$(koopa_realpath "$str")"
        # FIXME This may be problematic on Ubuntu 22...may need to rework.
        koopa_str_detect_regex \
            --string="$str" \
            --pattern="^${app_prefix}" \
            || return 1
    done
    return 0
}
