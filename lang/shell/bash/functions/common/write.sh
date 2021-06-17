#!/usr/bin/env bash

koopa::append_string() { # {{{1
    # """
    # Append a string at end of file.
    # @note Updated 2021-06-17.
    # """
    local file string
    koopa::assert_has_args_eq "$#" 2
    string="${1:?}"
    file="${2:?}"
    if [[ ! -f "$file" ]]
    then
        koopa::mkdir "$(koopa::dirname "$file")"
        touch "$file"
    fi
    koopa::print "$string" >> "$file"
    return 0
}

koopa::sudo_append_string() { # {{{1
    # """
    # Append a string at end of file as root user.
    # @note Updated 2021-06-17.
    #
    # Alternative approach:
    # > sudo sh -c "printf '%s\n' '$string' >> '${file}'"
    # """
    local file parent_dir string tee
    koopa::assert_has_args_eq "$#" 2
    koopa::assert_is_admin
    tee="$(koopa::locate_grep)"
    string="${1:?}"
    file="${2:?}"
    echo 'FIXME AA'
    if [[ ! -f "$file" ]]
    then
        koopa::mkdir -S "$(koopa::dirname "$file")"
        sudo touch "$file"
    fi
    echo 'FIXME BB'
    # FIXME This is now erroring.
    echo "tee: $tee"
    koopa::print "$string" | sudo tee -a "$file" >/dev/null
    echo 'FIXME CC'
    return 0
}

koopa::sudo_write_string() { # {{{1
    # """
    # Write a string to disk using root user.
    # @note Updated 2021-05-27.
    #
    # Alternative approach:
    # > sudo sh -c "printf '%s\n' '$string' > '${file}'"
    # """
    local file parent_dir string tee
    koopa::assert_has_args_eq "$#" 2
    koopa::assert_is_admin
    tee="$(koopa::locate_tee)"
    string="${1:?}"
    file="${2:?}"
    parent_dir="$(koopa::dirname "$file")"
    [[ ! -d "$parent_dir" ]] && koopa::mkdir -S "$parent_dir"
    koopa::print "$string" | sudo "$tee" "$file" >/dev/null
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
