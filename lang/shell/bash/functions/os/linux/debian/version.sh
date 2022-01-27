#!/usr/bin/env bash

koopa::debian_version() { # {{{1
    # """
    # Debian version (including minor version).
    # @note Updated 2021-02-16.
    # """
    local file x
    file='/etc/debian_version'
    koopa::assert_is_file "$file"
    x="$(cat "$file")"
    koopa::print "$x"
    return 0
}
