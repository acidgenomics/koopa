#!/usr/bin/env bash

koopa_is_gnu() {
    # """
    # Is a GNU program installed?
    # @note Updated 2022-01-21.
    # """
    local cmd str
    koopa_assert_has_args "$#"
    for cmd in "$@"
    do
        koopa_is_installed "$cmd" || return 1
        str="$("$cmd" --version 2>&1 || true)"
        koopa_str_detect_posix "$str" 'GNU' || return 1
    done
    return 0
}
