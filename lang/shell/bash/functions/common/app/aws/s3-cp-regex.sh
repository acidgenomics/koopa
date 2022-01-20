#!/usr/bin/env bash

koopa::aws_s3_cp_regex() { # {{{1
    # """
    # Copy a local file or S3 object to another location locally or in S3 using
    # regular expression pattern matching.
    #
    # @note Updated 2022-01-20.
    #
    # @seealso
    # - aws s3 cp help
    # """
    local app dict
    koopa::assert_has_args "$#"
    declare -A app=(
        [aws]="$(koopa::locate_aws)"
    )
    declare -A dict=(
        [profile]="${AWS_PROFILE:-}"
    )
    [[ -z "${dict[profile]}" ]] && dict[profile]='default'
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--pattern='*)
                pattern="${1#*=}"
                shift 1
                ;;
            '--pattern')
                pattern="${2:?}"
                shift 2
                ;;
            '--profile='*)
                profile="${1#*=}"
                shift 1
                ;;
            '--profile')
                profile="${2:?}"
                shift 2
                ;;
            '--source_prefix='*)
                source_prefix="${1#*=}"
                shift 1
                ;;
            '--source_prefix')
                source_prefix="${2:?}"
                shift 2
                ;;
            '--target_prefix='*)
                target_prefix="${1#*=}"
                shift 1
                ;;
            '--target_prefix')
                target_prefix="${2:?}"
                shift 2
                ;;
            # Other ------------------------------------------------------------
            *)
                koopa::invalid_arg "$1"
                ;;
        esac
    done
    koopa::assert_is_set \
        '--pattern' "${dict[pattern]:-}" \
        '--profile or AWS_PROFILE' "${dict[profile]:-}" \
        '--source-prefix' "${dict[source_prefix]:-}" \
        '--target-prefix' "${dict[target_prefix]:-}"
    "${app[aws]}" --profile="${dict[profile]}" \
        s3 cp \
            --exclude='*' \
            --follow-symlinks \
            --include="${dict[pattern]}" \
            --recursive \
            "${dict[source_prefix]}" \
            "${dict[target_prefix]}"
    return 0
}
