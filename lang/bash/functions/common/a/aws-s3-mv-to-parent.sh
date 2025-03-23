#!/usr/bin/env bash

koopa_aws_s3_mv_to_parent() {
    # """
    # Move objects in an S3 bucket directory to parent directory.
    #
    # @note Updated 2022-07-18.
    #
    # @details
    # Empty directory will be removed automatically, since S3 uses object
    # storage.
    # """
    local -A app dict
    local -a files
    local file prefix
    koopa_assert_has_args "$#"
    app['aws']="$(koopa_locate_aws)"
    koopa_assert_is_executable "${app[@]}"
    dict['prefix']=''
    dict['profile']="${AWS_PROFILE:-default}"
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--prefix='*)
                dict['prefix']="${1#*=}"
                shift 1
                ;;
            '--prefix')
                dict['prefix']="${2:?}"
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
            # Other ------------------------------------------------------------
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set \
        '--profile or AWS_PROFILE' "${dict['profile']}"
        '--prefix' "${dict['prefix']}"
    koopa_assert_is_matching_regex \
        --pattern='^s3://.+/$' \
        --string="${dict['prefix']}"
    dict['str']="$( \
        koopa_aws_s3_ls \
            --prefix="${dict['prefix']}" \
            --profile="${dict['profile']}" \
    )"
    if [[ -z "${dict['str']}" ]]
    then
        koopa_stop "No content detected in '${dict['prefix']}'."
    fi
    readarray -t files <<< "${dict['str']}"
    for file in "${files[@]}"
    do
        local -A dict2
        dict2['bn']="$(koopa_basename "$file")"
        dict2['dn1']="$(koopa_dirname "$file")"
        dict2['dn2']="$(koopa_dirname "${dict2['dn1']}")"
        dict2['target']="${dict2['dn2']}/${dict2['bn']}"
        "${app['aws']}" s3 mv \
            --profile "${dict['profile']}" \
            --recursive \
            "${dict2['file']}" \
            "${dict2['target']}"
    done
    return 0
}
