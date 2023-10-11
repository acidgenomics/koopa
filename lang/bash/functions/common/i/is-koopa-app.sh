#!/usr/bin/env bash

# FIXME This is failing to detect our koopa R on Ubuntu 22 corectly.

koopa_is_koopa_app() {
    # """
    # Is a specific command installed in koopa app prefix?
    # @note Updated 2022-02-17.
    # """
    local app_prefix str
    koopa_assert_has_args "$#"
    app_prefix="$(koopa_app_prefix)"
    [[ -d "$app_prefix" ]] || return 1
    for str in "$@"
    do
        if koopa_is_installed "$str"
        then
            str="$(koopa_which_realpath "$str")"
        elif [[ -e "$str" ]]
        then
            str="$(koopa_realpath "$str")"
        else
            return 1
        fi
        koopa_str_detect_regex \
            --string="$str" \
            --pattern="^${app_prefix}" \
            || return 1
    done
    return 0
}
