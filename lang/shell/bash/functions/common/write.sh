#!/usr/bin/env bash

# FIXME Require the user to use '--string' and '--file' flags here.
koopa::append_string() { # {{{1
    # """
    # Append a string at end of file.
    # @note Updated 2022-01-31.
    # """
    local dict
    koopa::assert_has_args_eq "$#" 2
    declare -A dict=(
        [string]="${1:?}"
        [file]="${2:?}"
    )
    if [[ ! -f "${dict[file]}" ]]
    then
        koopa::mkdir "$(koopa::dirname "${dict[file]}")"
        koopa::touch "${dict[file]}"
    fi
    koopa::print "${dict[string]}" >> "${dict[file]}"
    return 0
}

# FIXME Require the user to use '--string' and '--file' flags here.
koopa::sudo_append_string() { # {{{1
    # """
    # Append a string at end of file as root user.
    # @note Updated 2022-02-01.
    #
    # Alternative approach:
    # > sudo sh -c "printf '%s\n' '$string' >> '${file}'"
    # """
    local app dict
    koopa::assert_has_args_eq "$#" 2
    koopa::assert_is_admin
    declare -A app=(
        [sudo]="$(koopa::locate_sudo)"
        [tee]="$(koopa::locate_tee)"
    )
    declare -A dict=(
        [string]="${1:?}"
        [file]="${2:?}"
    )
    if [[ ! -f "${dict[file]}" ]]
    then
        koopa::mkdir --sudo "$(koopa::dirname "${dict[file]}")"
        koopa::touch --sudo "${dict[file]}"
    fi
    koopa::print "${dict[string]}" \
        | "${app[sudo]}" "${app[tee]}" -a "${dict[file]}" >/dev/null
    return 0
}

# FIXME Require the user to use '--string' and '--file' flags here.
koopa::sudo_write_string() { # {{{1
    # """
    # Write a string to disk using root user.
    # @note Updated 2022-01-31.
    #
    # Alternative approach:
    # > sudo sh -c "printf '%s\n' '$string' > '${file}'"
    # """
    local app dict
    koopa::assert_has_args_eq "$#" 2
    koopa::assert_is_admin
    declare -A app=(
        [sudo]="$(koopa::locate_sudo)"
        [tee]="$(koopa::locate_tee)"
    )
    declare -A dict=(
        [string]="${1:?}"
        [file]="${2:?}"
    )
    dict[parent_dir]="$(koopa::dirname "${dict[file]}")"
    if [[ ! -d "${dict[parent_dir]}" ]]
    then
        koopa::mkdir --sudo "${dict[parent_dir]}"
    fi
    koopa::print "${dict[string]}" \
        | "${app[sudo]}" "${app[tee]}" "${dict[file]}" >/dev/null
    return 0
}

# FIXME Require the user to use '--string' and '--file' flags here.
koopa::write_string() { # {{{1
    # """
    # Write a string to disk.
    # @note Updated 2022-01-31.
    # """
    local dict
    koopa::assert_has_args_eq "$#" 2
    declare -A dict=(
        [string]="${1:?}"
        [file]="${2:?}"
    )
    koopa::mkdir "$(koopa::dirname "${dict[file]}")"
    koopa::print "${dict[string]}" > "${dict[file]}"
    return 0
}
