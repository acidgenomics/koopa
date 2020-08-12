#!/usr/bin/env bash

koopa::sudo_write_string() { # {{{1
    # """
    # Write a string to disk using root user.
    # @note Updated 2020-07-06.
    #
    # Alternatively, 'tee -a' can be used to append file.
    # """
    koopa::assert_has_args_eq "$#" 2
    local file string
    string="${1:?}"
    file="${2:?}"
    koopa::mkdir -S "$(dirname "$file")"
    koopa::print "$string" | sudo tee "$file" >/dev/null
    return 0
}

koopa::write_string() { # {{{1
    # """
    # Write a string to disk.
    # @note Updated 2020-08-06.
    # """
    koopa::assert_has_args_eq "$#" 2
    local file string
    string="${1:?}"
    file="${2:?}"
    koopa::mkdir "$(dirname "$file")"
    koopa::print "$string" > "$file"
    return 0
}
