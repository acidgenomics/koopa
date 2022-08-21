#!/usr/bin/env bash

__koopa_unlink_in_dir() {
    # """
    # Unlink multiple symlinks in a directory.
    # @note Updated 2022-08-03.
    # """
    local dict name names pos
    koopa_assert_has_args "$#"
    declare -A dict=(
        [allow_missing]=0
        [prefix]=''
    )
    pos=()
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--prefix='*)
                dict[prefix]="${1#*=}"
                shift 1
                ;;
            '--prefix')
                dict[prefix]="${2:?}"
                shift 2
                ;;
            # Flags ------------------------------------------------------------
            '--allow-missing')
                dict[allow_missing]=1
                shift 1
                ;;
            # Other ------------------------------------------------------------
            '-'*)
                koopa_invalid_arg "$1"
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    koopa_assert_has_args "$#"
    koopa_assert_is_set '--prefix' "${dict['prefix']}"
    koopa_assert_is_dir "${dict['prefix']}"
    dict[prefix]="$(koopa_realpath "${dict['prefix']}")"
    names=("$@")
    for name in "${names[@]}"
    do
        local file
        file="${dict['prefix']}/${name}"
        if [[ "${dict['allow_missing']}" -eq 1 ]]
        then
            if [[ -L "$file" ]]
            then
                koopa_alert "Unlinking '${file}'."
                koopa_rm "$file"
            fi
        else
            koopa_assert_is_symlink "$file"
            koopa_alert "Unlinking '${file}'."
            koopa_rm "$file"
        fi
    done
    return 0
}
