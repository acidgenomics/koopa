#!/usr/bin/env bash

koopa::append_string() { # {{{1
    # """
    # Append a string at end of file.
    # @note Updated 2021-10-27.
    # """
    local app file string
    koopa::assert_has_args_eq "$#" 2
    declare -A app=(
        [touch]="$(koopa::locate_touch)"
    )
    string="${1:?}"
    file="${2:?}"
    if [[ ! -f "$file" ]]
    then
        koopa::mkdir "$(koopa::dirname "$file")"
        "${app[touch]}" "$file"
    fi
    koopa::print "$string" >> "$file"
    return 0
}

koopa::sudo_append_string() { # {{{1
    # """
    # Append a string at end of file as root user.
    # @note Updated 2021-10-27.
    #
    # Alternative approach:
    # > sudo sh -c "printf '%s\n' '$string' >> '${file}'"
    # """
    local app file parent_dir string
    koopa::assert_has_args_eq "$#" 2
    koopa::assert_is_admin
    declare -A app=(
        [sudo]="$(koopa::locate_sudo)"
        [tee]="$(koopa::locate_tee)"
        [touch]="$(koopa::locate_touch)"
    )
    string="${1:?}"
    file="${2:?}"
    if [[ ! -f "$file" ]]
    then
        koopa::mkdir --sudo "$(koopa::dirname "$file")"
        "${app[sudo]}" "${app[touch]}" "$file"
    fi
    koopa::print "$string" \
        | "${app[sudo]}" "${app[tee]}" -a "$file" >/dev/null
    return 0
}

koopa::sudo_write_string() { # {{{1
    # """
    # Write a string to disk using root user.
    # @note Updated 2021-10-27.
    #
    # Alternative approach:
    # > sudo sh -c "printf '%s\n' '$string' > '${file}'"
    # """
    local app file parent_dir string
    koopa::assert_has_args_eq "$#" 2
    koopa::assert_is_admin
    declare -A app=(
        [sudo]="$(koopa::locate_sudo)"
        [tee]="$(koopa::locate_tee)"
    )
    string="${1:?}"
    file="${2:?}"
    parent_dir="$(koopa::dirname "$file")"
    if [[ ! -d "$parent_dir" ]]
    then
        koopa::mkdir --sudo "$parent_dir"
    fi
    koopa::print "$string" \
        | "${app[sudo]}" "${app[tee]}" "$file" >/dev/null
    return 0
}

koopa::write_string() { # {{{1
    # """
    # Write a string to disk.
    # @note Updated 2021-10-26.
    # """
    local file string
    koopa::assert_has_args_eq "$#" 2
    string="${1:?}"
    file="${2:?}"
    koopa::mkdir "$(koopa::dirname "$file")"
    koopa::print "$string" > "$file"
    return 0
}
