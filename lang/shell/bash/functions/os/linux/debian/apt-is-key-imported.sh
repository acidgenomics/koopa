#!/usr/bin/env bash

koopa_debian_apt_is_key_imported() {
    # """
    # Is a GPG key imported for apt?
    # @note Updated 2021-11-02.
    #
    # sed only supports up to 9 elements in replacement, even though our
    # input contains 10. Need to switch to awk or another approach to make
    # this matching even more exact.
    # """
    local app dict
    koopa_assert_has_args_eq "$#" 1
    declare -A app=(
        [apt_key]="$(koopa_debian_locate_apt_key)"
        [sed]="$(koopa_locate_sed)"
    )
    declare -A dict=(
        [key]="${1:?}"
    )
    dict[key_pattern]="$( \
        koopa_print "${dict[key]}" \
        | "${app[sed]}" 's/ //g' \
        | "${app[sed]}" -E \
            "s/^(.{4})(.{4})(.{4})(.{4})(.{4})(.{4})(.{4})\
(.{4})(.{4})(.{4})\$/\1 \2 \3 \4 \5  \6 \7 \8 \9/" \
    )"
    dict[string]="$("${app[apt_key]}" list 2>&1 || true)"
    koopa_str_detect_fixed \
        --string="${dict[string]}" \
        --pattern="${dict[key_pattern]}"
}
