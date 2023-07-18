#!/usr/bin/env bash

koopa_aws_s3_cp_regex() {
    # """
    # Copy a local file or S3 object to another location locally or in S3 using
    # regular expression pattern matching.
    #
    # @note Updated 2022-07-18.
    #
    # @seealso
    # - aws s3 cp help
    # """
    local -A app dict
    koopa_assert_has_args "$#"
    app['aws']="$(koopa_locate_aws)"
    koopa_assert_is_executable "${app[@]}"
    dict['bucket_pattern']='^s3://.+/$'
    dict['pattern']=''
    dict['profile']="${AWS_PROFILE:-default}"
    dict['source_prefix']=''
    dict['target_prefix']=''
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--pattern='*)
                dict['pattern']="${1#*=}"
                shift 1
                ;;
            '--pattern')
                dict['pattern']="${2:?}"
                shift 2
                ;;
            '--profile='*)
                dict['profile']="${1#*=}"
                shift 1
                ;;
            '--profile')
                dict['profile']="${2:?}"
                shift 2
                ;;
            '--source_prefix='*)
                dict['source_prefix']="${1#*=}"
                shift 1
                ;;
            '--source_prefix')
                dict['source_prefix']="${2:?}"
                shift 2
                ;;
            '--target_prefix='*)
                dict['target_prefix']="${1#*=}"
                shift 1
                ;;
            '--target_prefix')
                dict['target_prefix']="${2:?}"
                shift 2
                ;;
            # Other ------------------------------------------------------------
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set \
        '--pattern' "${dict['pattern']}" \
        '--profile or AWS_PROFILE' "${dict['profile']}" \
        '--source-prefix' "${dict['source_prefix']}" \
        '--target-prefix' "${dict['target_prefix']}"
    if ! koopa_str_detect_regex \
            --pattern="${dict['bucket_pattern']}" \
            --string "${dict['source_prefix']}" &&
        ! koopa_str_detect_regex \
            --pattern="${dict['bucket_pattern']}" \
            --string "${dict['target_prefix']}"
    then
        koopa_stop "Souce and or/target must match '${dict['bucket_pattern']}'."
    fi
    "${app['aws']}" s3 cp \
        --exclude '*' \
        --follow-symlinks \
        --include "${dict['pattern']}" \
        --profile "${dict['profile']}" \
        --recursive \
        "${dict['source_prefix']}" \
        "${dict['target_prefix']}"
    return 0
}
