#!/usr/bin/env bash

__koopa_link_in_dir() {
    # """
    # Symlink multiple programs in a directory.
    # @note Updated 2022-04-26.
    #
    # @usage
    # > __koopa_link_in_dir \
    # >     --prefix=PREFIX \
    # >     SOURCE_FILE_1 TARGET_NAME_1 \
    # >     SOURCE_FILE_2 TARGET_NAME_2 \
    # >     ...
    #
    # @examples
    # > __koopa_link_in_dir \
    # >     --prefix="$(koopa_bin_prefix) \
    # >     '/usr/local/bin/emacs' 'emacs' \
    # >     '/usr/local/bin/vim' 'vim'
    # """
    local dict pos
    koopa_assert_has_args "$#"
    declare -A dict=(
        [allow_missing]=0
        [prefix]=''
        [quiet]=0
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
            '--quiet')
                dict[quiet]=1
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
    koopa_assert_has_args_ge "$#" 2
    koopa_assert_is_set '--prefix' "${dict[prefix]}"
    [[ ! -d "${dict[prefix]}" ]] && koopa_mkdir "${dict[prefix]}"
    dict[prefix]="$(koopa_realpath "${dict[prefix]}")"
    while [[ "$#" -ge 2 ]]
    do
        local dict2
        declare -A dict2=(
            [source_file]="${1:?}"
            [target_name]="${2:?}"
        )
        dict2[target_file]="${dict[prefix]}/${dict2[target_name]}"
        if [[ ! -e "${dict2[source_file]}" ]] && \
            [[ "${dict[allow_missing]}" -eq 0 ]]
        then
            if [[ "${dict[quiet]}" -eq 0 ]]
            then
                koopa_alert_note "Skipping link of '${dict2[source_file]}'."
            fi
            return 0
        fi
        if [[ "${dict[quiet]}" -eq 0 ]]
        then
            koopa_alert "Linking '${dict2[source_file]}' -> \
'${dict2[target_file]}'."
        fi
        koopa_sys_ln "${dict2[source_file]}" "${dict2[target_file]}"
        shift 2
    done
    return 0
}
