#!/usr/bin/env bash

koopa_is_current_version() {
    # """
    # Is the program version current?
    # @note Updated 2020-07-20.
    # """
    local actual_version app expected_version
    koopa_assert_has_args "$#"
    for app in "$@"
    do
        expected_version="$(koopa_variable "$app")"
        actual_version="$(koopa_get_version "$app")"
        [[ "$actual_version" == "$expected_version" ]] || return 1
    done
    return 0
}
