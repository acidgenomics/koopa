#!/usr/bin/env bash

# FIXME Require the user to use '--string' and '--file' flags here.
koopa_append_string() { # {{{1
    # """
    # Append a string at end of file.
    # @note Updated 2022-01-31.
    # """
    local dict
    koopa_assert_has_args_eq "$#" 2
    declare -A dict=(
        [string]="${1:?}"
        [file]="${2:?}"
    )
    if [[ ! -f "${dict[file]}" ]]
    then
        koopa_mkdir "$(koopa_dirname "${dict[file]}")"
        koopa_touch "${dict[file]}"
    fi
    koopa_print "${dict[string]}" >> "${dict[file]}"
    return 0
}

# FIXME Require the user to use '--string' and '--file' flags here.
koopa_sudo_append_string() { # {{{1
    # """
    # Append a string at end of file as root user.
    # @note Updated 2022-02-01.
    #
    # Alternative approach:
    # > sudo sh -c "printf '%s\n' '$string' >> '${file}'"
    # """
    local app dict
    koopa_assert_has_args_eq "$#" 2
    koopa_assert_is_admin
    declare -A app=(
        [sudo]="$(koopa_locate_sudo)"
        [tee]="$(koopa_locate_tee)"
    )
    declare -A dict=(
        [string]="${1:?}"
        [file]="${2:?}"
    )
    if [[ ! -f "${dict[file]}" ]]
    then
        koopa_mkdir --sudo "$(koopa_dirname "${dict[file]}")"
        koopa_touch --sudo "${dict[file]}"
    fi
    koopa_print "${dict[string]}" \
        | "${app[sudo]}" "${app[tee]}" -a "${dict[file]}" >/dev/null
    return 0
}

# FIXME Require the user to use '--string' and '--file' flags here.
koopa_sudo_write_string() { # {{{1
    # """
    # Write a string to disk using root user.
    # @note Updated 2022-01-31.
    #
    # Alternative approach:
    # > sudo sh -c "printf '%s\n' '$string' > '${file}'"
    # """
    local app dict
    koopa_assert_has_args_eq "$#" 2
    koopa_assert_is_admin
    declare -A app=(
        [sudo]="$(koopa_locate_sudo)"
        [tee]="$(koopa_locate_tee)"
    )
    declare -A dict=(
        [string]="${1:?}"
        [file]="${2:?}"
    )
    dict[parent_dir]="$(koopa_dirname "${dict[file]}")"
    if [[ ! -d "${dict[parent_dir]}" ]]
    then
        koopa_mkdir --sudo "${dict[parent_dir]}"
    fi
    koopa_print "${dict[string]}" \
        | "${app[sudo]}" "${app[tee]}" "${dict[file]}" >/dev/null
    return 0
}

# FIXME Require the user to use '--string' and '--file' flags here.
koopa_write_string() { # {{{1
    # """
    # Write a string to disk.
    # @note Updated 2022-01-31.
    # """
    local dict
    koopa_assert_has_args_eq "$#" 2
    declare -A dict=(
        [string]="${1:?}"
        [file]="${2:?}"
    )
    koopa_mkdir "$(koopa_dirname "${dict[file]}")"
    koopa_print "${dict[string]}" > "${dict[file]}"
    return 0
}
