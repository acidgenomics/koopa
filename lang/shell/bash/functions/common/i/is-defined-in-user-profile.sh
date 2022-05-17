#!/usr/bin/env bash

koopa_is_defined_in_user_profile() {
    # """
    # Is koopa defined in current user's shell profile configuration file?
    # @note Updated 2022-02-17.
    # """
    local file
    koopa_assert_has_no_args "$#"
    file="$(koopa_find_user_profile)"
    koopa_file_detect_fixed --file="$file" --pattern='koopa'
}
