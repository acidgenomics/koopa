#!/usr/bin/env bash

_koopa_debian_debian_version() {
    # """
    # Debian version (including minor version).
    # @note Updated 2021-02-16.
    # """
    local file x
    file='/etc/debian_version'
    _koopa_assert_is_file "$file"
    x="$(cat "$file")"
    _koopa_print "$x"
    return 0
}
