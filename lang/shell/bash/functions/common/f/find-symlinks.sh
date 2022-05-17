#!/usr/bin/env bash

# NOTE Is there a way to speed this up using GNU find or something?

koopa_find_symlinks() {
    # """
    # Find symlinks matching a specified source prefix.
    # @note Updated 2022-04-01.
    #
    # @examples
    # > koopa_find_symlinks \
    # >     --source-prefix="$(koopa_app_prefix)/python" \
    # >     --target-prefix="$(koopa_make_prefix)"
    # > koopa_find_symlinks \
    # >     --source-prefix="$(koopa_macos_r_prefix)" \
    # >     --target-prefix="$(koopa_koopa_prefix)/bin"
    # """
    local dict hits symlink symlinks
    koopa_assert_has_args "$#"
    declare -A dict=(
        [source_prefix]=''
        [target_prefix]=''
        [verbose]=0
    )
    hits=()
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--source-prefix='*)
                dict[source_prefix]="${1#*=}"
                shift 1
                ;;
            '--source-prefix')
                dict[source_prefix]="${2:?}"
                shift 2
                ;;
            '--target-prefix='*)
                dict[target_prefix]="${1#*=}"
                shift 1
                ;;
            '--target-prefix')
                dict[target_prefix]="${2:?}"
                shift 2
                ;;
            # Flags ------------------------------------------------------------
            '--verbose')
                dict[verbose]=1
                shift 1
                ;;
            # Other ------------------------------------------------------------
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set \
        '--source-prefix' "${dict[source_prefix]}" \
        '--target-prefix' "${dict[target_prefix]}"
    koopa_assert_is_dir "${dict[source_prefix]}" "${dict[target_prefix]}"
    dict[source_prefix]="$(koopa_realpath "${dict[source_prefix]}")"
    dict[target_prefix]="$(koopa_realpath "${dict[target_prefix]}")"
    readarray -t symlinks <<< "$(
        koopa_find \
            --prefix="${dict[target_prefix]}" \
            --sort \
            --type='l' \
    )"
    for symlink in "${symlinks[@]}"
    do
        local symlink_real
        symlink_real="$(koopa_realpath "$symlink")"
        if koopa_str_detect_regex \
            --pattern="^${dict[source_prefix]}/" \
            --string="$symlink_real"
        then
            if [[ "${dict[verbose]}" -eq 1 ]]
            then
                koopa_warn "${symlink} -> ${symlink_real}"
            fi
            hits+=("$symlink")
        fi
    done
    koopa_is_array_empty "${hits[@]}" && return 1
    koopa_print "${hits[@]}"
    return 0
}
