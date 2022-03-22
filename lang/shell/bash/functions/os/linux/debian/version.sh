#!/usr/bin/env bash

koopa_debian_version() { # {{{1
    # """
    # Debian version (including minor version).
    # @note Updated 2021-02-16.
    # """
    local file x
    file='/etc/debian_version'
    koopa_assert_is_file "$file"
    x="$(cat "$file")"
    koopa_print "$x"
    return 0
}
