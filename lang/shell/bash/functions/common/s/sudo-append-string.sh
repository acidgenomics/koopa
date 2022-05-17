#!/usr/bin/env bash

koopa_sudo_append_string() {
    # """
    # Append a string at end of file as root user.
    # @note Updated 2022-03-01.
    #
    # Alternative approach:
    # > sudo sh -c "printf '%s\n' '$string' >> '${file}'"
    # """
    local app dict
    koopa_assert_has_args "$#"
    koopa_assert_is_admin
    declare -A app=(
        [sudo]="$(koopa_locate_sudo)"
        [tee]="$(koopa_locate_tee)"
    )
    declare -A dict=(
        [file]=''
        [string]=''
    )
    while (("$#"))
    do
        case "$1" in
            # Key value pairs --------------------------------------------------
            '--file='*)
                dict[file]="${1#*=}"
                shift 1
                ;;
            '--file')
                dict[file]="${2:?}"
                shift 2
                ;;
            '--string='*)
                dict[string]="${1#*=}"
                shift 1
                ;;
            '--string')
                dict[string]="${2:?}"
                shift 2
                ;;
            # Other ------------------------------------------------------------
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set \
        '--file' "${dict[file]}" \
        '--string' "${dict[string]}"
    if [[ ! -f "${dict[file]}" ]]
    then
        koopa_mkdir --sudo "$(koopa_dirname "${dict[file]}")"
        koopa_touch --sudo "${dict[file]}"
    fi
    koopa_print "${dict[string]}" \
        | "${app[sudo]}" "${app[tee]}" -a "${dict[file]}" >/dev/null
    return 0
}
