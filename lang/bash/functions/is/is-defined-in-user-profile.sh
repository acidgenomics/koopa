#!/usr/bin/env bash

_koopa_is_defined_in_user_profile() {
    # """
    # Is koopa defined in current user's shell profile configuration file?
    # @note Updated 2022-11-28.
    # """
    local file
    _koopa_assert_has_no_args "$#"
    file="$(_koopa_find_user_profile)"
    [[ -f "$file" ]] || return 1
    _koopa_file_detect_fixed --file="$file" --pattern='koopa'
}
