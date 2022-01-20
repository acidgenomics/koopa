#!/usr/bin/env bash

koopa::aws_s3_find() { # {{{1
    # """
    # Find files in an AWS S3 bucket.
    #
    # @note Updated 2021-11-05.
    #
    # @seealso
    # - https://docs.aws.amazon.com/cli/latest/reference/s3/
    #
    # @examples
    # koopa::aws_s3_find \
    #     --include='*.bw$' \
    #     --exclude='antisense' \
    #     's3://bioinfo/igv/'
    # """
    local dict pos x
    koopa::assert_has_args "$#"
    declare -A dict=(
        [exclude]=''
        [include]=''
        [profile]="${AWS_PROFILE:-}"
    )
    [[ -z "${dict[profile]}" ]] && dict[profile]='default'
    pos=()
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--exclude='*)
                dict[exclude]="${1#*=}"
                shift 1
                ;;
            '--exclude')
                dict[exclude]="${2:?}"
                shift 2
                ;;
            '--include='*)
                dict[include]="${1#*=}"
                shift 1
                ;;
            '--include')
                dict[include]="${2:?}"
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
    x="$( \
        koopa::aws_s3_ls \
        --profile="${dict[profile]}" \
        --recursive \
        "$@" \
    )"
    if [[ -z "$x" ]]
    then
        koopa::warn 'Failed to recursively list any files.'
        return 1
    fi
    # Exclude pattern.
    if [[ -n "${dict[exclude]}" ]]
    then
        x="$( \
            koopa::print "$x" \
                | koopa::grep \
                    --extended-regexp \
                    --invert-match \
                    "${dict[exclude]}" \
        )"
        if [[ -z "$x" ]]
        then
            koopa::warn "No files left with '--exclude' argument."
            return 1
        fi
    fi
    # Include pattern.
    if [[ -n "${dict[include]}" ]]
    then
        x="$( \
            koopa::print "$x" \
                | koopa::grep \
                    --extended-regexp "${dict[include]}" \
        )"
        if [[ -z "$x" ]]
        then
            koopa::warn "No files left with '--include' argument."
            return 1
        fi
    fi
    koopa::print "$x"
    return 0
}
