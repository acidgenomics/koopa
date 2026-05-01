#!/usr/bin/env bash

# NOTE Is there a way to speed this up using GNU find or something?

_koopa_find_symlinks() {
    # """
    # Find symlinks matching a specified source prefix.
    # @note Updated 2023-04-06.
    #
    # @examples
    # > _koopa_find_symlinks \
    # >     --source-prefix="$(_koopa_app_prefix)/r" \
    # >     --target-prefix="$(_koopa_bin_prefix)"
    # """
    local -A dict
    local -a hits symlinks
    local symlink
    _koopa_assert_has_args "$#"
    dict['source_prefix']=''
    dict['target_prefix']=''
    dict['verbose']=0
    hits=()
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--source-prefix='*)
                dict['source_prefix']="${1#*=}"
                shift 1
                ;;
            '--source-prefix')
                dict['source_prefix']="${2:?}"
                shift 2
                ;;
            '--target-prefix='*)
                dict['target_prefix']="${1#*=}"
                shift 1
                ;;
            '--target-prefix')
                dict['target_prefix']="${2:?}"
                shift 2
                ;;
            # Flags ------------------------------------------------------------
            '--verbose')
                dict['verbose']=1
                shift 1
                ;;
            # Other ------------------------------------------------------------
            *)
                _koopa_invalid_arg "$1"
                ;;
        esac
    done
    _koopa_assert_is_set \
        '--source-prefix' "${dict['source_prefix']}" \
        '--target-prefix' "${dict['target_prefix']}"
    _koopa_assert_is_dir "${dict['source_prefix']}" "${dict['target_prefix']}"
    dict['source_prefix']="$(_koopa_realpath "${dict['source_prefix']}")"
    dict['target_prefix']="$(_koopa_realpath "${dict['target_prefix']}")"
    readarray -t symlinks <<< "$(
        _koopa_find \
            --prefix="${dict['target_prefix']}" \
            --sort \
            --type='l' \
    )"
    for symlink in "${symlinks[@]}"
    do
        local symlink_real
        symlink_real="$(_koopa_realpath "$symlink")"
        if _koopa_str_detect_regex \
            --pattern="^${dict['source_prefix']}/" \
            --string="$symlink_real"
        then
            if [[ "${dict['verbose']}" -eq 1 ]]
            then
                _koopa_warn "${symlink} -> ${symlink_real}"
            fi
            hits+=("$symlink")
        fi
    done
    _koopa_is_array_empty "${hits[@]}" && return 1
    _koopa_print "${hits[@]}"
    return 0
}
