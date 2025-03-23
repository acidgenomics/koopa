#!/usr/bin/env bash

koopa_is_gnu() {
    # """
    # Is a GNU program installed?
    # @note Updated 2023-03-09.
    # """
    local cmd
    koopa_assert_has_args "$#"
    for cmd in "$@"
    do
        local str
        koopa_is_installed "$cmd" || return 1
        str="$("$cmd" --version 2>&1 || true)"
        koopa_str_detect_fixed --pattern='GNU' --string="$str" || return 1
    done
    return 0
}
