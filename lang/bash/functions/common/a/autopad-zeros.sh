#!/usr/bin/env bash

koopa_autopad_zeros() {
    # """
    # Autopad zeroes in file names.
    # @note Updated 2023-05-12.
    # """
    local -A dict
    local -a pos
    local file
    koopa_assert_has_args "$#"
    dict['dryrun']=0
    dict['padwidth']=2
    dict['prefix']=''
    pos=()
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--pad-width='* | \
            '--padwidth='*)
                dict['padwidth']="${1#*=}"
                shift 1
                ;;
            '--pad-width' | \
            '--padwidth')
                dict['padwidth']="${2:?}"
                shift 2
                ;;
            '--prefix='*)
                dict['prefix']="${1#*=}"
                shift 1
                ;;
            '--prefix')
                dict['prefix']="${2:?}"
                shift 2
                ;;
            # Flags ------------------------------------------------------------
            '--dry-run' | \
            '--dryrun')
                dict['dryrun']=1
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
    koopa_assert_is_file "$@"
    for file in "$@"
    do
        local -A dict2
        dict2['source']="$file"
        dict2['bn']="$(koopa_basename "${dict2['source']}")"
        dict2['dn']="$(koopa_dirname "${dict2['source']}")"
        if [[ "${dict2['bn']}" =~ ^([0-9]+)(.*)$ ]]
        then
            dict2['num']="${BASH_REMATCH[1]}"
            dict2['num']="$(printf "%.${dict['padwidth']}d" "${dict2['num']}")"
            dict2['stem']="${BASH_REMATCH[2]}"
            dict2['bn2']="${dict['prefix']}${dict2['num']}${dict2['stem']}"
            dict2['target']="${dict2['dn']}/${dict2['bn2']}"
            koopa_alert "Renaming '${dict2['source']}' to '${dict2['target']}'."
            [[ "${dict['dryrun']}" -eq 1 ]] && continue
            koopa_mv "${dict2['source']}" "${dict2['target']}"
        else
            koopa_alert_note "Skipping '${dict2['source']}'."
        fi
    done
    return 0
}
