#!/usr/bin/env bash

koopa::append_string() { # {{{1
    # """
    # Append a string at end of file.
    # @note Updated 2021-03-24.
    # """
    local file string
    koopa::assert_has_args_eq "$#" 2
    koopa::assert_is_installed grep
    string="${1:?}"
    file="${2:?}"
    koopa::mkdir "$(dirname "$file")"
    if ! grep -Eq "^${string}$" "$file"
    then
        koopa::print "$string" >> "$file"
    fi
    return 0
}

koopa::sudo_append_string() { # {{{1
    # """
    # Append a string at end of file as root user.
    # @note Updated 2021-03-24.
    #
    # Alternative approach:
    # > sudo sh -c "printf '%s\n' '$string' >> '${file}'"
    # """
    local file string
    koopa::assert_has_args_eq "$#" 2
    koopa::assert_is_admin
    koopa::assert_is_installed grep tee
    string="${1:?}"
    file="${2:?}"
    if [[ ! -d "$(dirname "$file")" ]]
    then
        koopa::mkdir -S "$(dirname "$file")"
    fi
    if ! sudo grep -Eq "^${string}$" "$file"
    then
        koopa::print "$string" | sudo tee -a "$file" >/dev/null
    fi
    return 0
}

koopa::sudo_write_string() { # {{{1
    # """
    # Write a string to disk using root user.
    # @note Updated 2021-03-01.
    #
    # Alternative approach:
    # > sudo sh -c "printf '%s\n' '$string' > '${file}'"
    # """
    local file string
    koopa::assert_has_args_eq "$#" 2
    koopa::assert_is_admin
    koopa::assert_is_installed tee
    string="${1:?}"
    file="${2:?}"
    if [[ ! -d "$(dirname "$file")" ]]
    then
        koopa::mkdir -S "$(dirname "$file")"
    fi
    koopa::print "$string" | sudo tee "$file" >/dev/null
    return 0
}

koopa::write_string() { # {{{1
    # """
    # Write a string to disk.
    # @note Updated 2021-03-01.
    # """
    local file string
    koopa::assert_has_args_eq "$#" 2
    string="${1:?}"
    file="${2:?}"
    koopa::mkdir "$(dirname "$file")"
    koopa::print "$string" > "$file"
    return 0
}
