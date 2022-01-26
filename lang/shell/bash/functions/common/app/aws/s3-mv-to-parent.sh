#!/usr/bin/env bash

koopa::aws_s3_mv_to_parent() { # {{{1
    # """
    # Move objects in an S3 bucket directory to parent directory.
    #
    # @note Updated 2021-11-05.
    #
    # @details
    # Empty directory will be removed automatically, since S3 uses object
    # storage.
    # """
    local app dict pos
    local bn dn1 dn2 file files prefix profile target x
    koopa::assert_has_args "$#"
    declare -A app=(
        [aws]="$(koopa::locate_aws)"
    )
    declare -A dict=(
        [profile]="${AWS_PROFILE:-}"
    )
    [[ -z "${dict[profile]}" ]] && dict[profile]='default'
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
            '--profile='*)
                dict[profile]="${1#*=}"
                shift 1
                ;;
            '--profile')
                dict[profile]="${2:?}"
                shift 2
                ;;
            # Other ------------------------------------------------------------
            '-'*)
                koopa::invalid_arg "$1"
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    if [[ "$#" -gt 0 ]]
    then
        koopa::assert_has_args_eq "$#" 1
        dict[prefix]="${1:?}"
    fi
    koopa::assert_is_set \
        '--profile or AWS_PROFILE' "${dict[profile]:-}"
        '--prefix' "${dict[prefix]:-}"
    x="$( \
        koopa::aws_s3_ls \
            --profile="${dict[profile]}" \
            "${dict[prefix]}" \
    )"
    if [[ -z "$x" ]]
    then
        koopa::warn "Failed to list any files in '${dict[prefix]}'."
        return 1
    fi
    readarray -t files <<< "$x"
    for file in "${files[@]}"
    do
        bn="$(koopa::basename "$file")"
        dn1="$(koopa::dirname "$file")"
        dn2="$(koopa::dirname "$dn1")"
        target="${dn2}/${bn}"
        "${app[aws]}" --profile="${dict[profile]}" \
            s3 mv "$file" "$target"
    done
    return 0
}
