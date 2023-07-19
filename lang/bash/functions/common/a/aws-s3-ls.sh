#!/usr/bin/env bash

# S3 API programmatic access examples:
# > aws s3api list-buckets --output 'json'
# > aws s3api list-objects --output 'json' --bucket 'koopa.acidgenomics.com'

koopa_aws_s3_ls() {
    # """
    # List an AWS S3 bucket.
    # @note Updated 2022-03-01.
    #
    # @seealso
    # - aws s3 ls help
    #
    # @examples
    # > prefix='s3://r.acidgenomics.com/src/contrib/'
    # > profile='acidgenomics'
    #
    # # Files and directories (default):
    # > koopa_aws_s3_ls \
    # >     --prefix="$prefix" \
    # >     --profile="$profile"
    #
    # # Files only:
    # > koopa_aws_s3_ls \
    # >     --prefix="$prefix" \
    # >     --profile="$profile" \
    # >     --type='f'
    #
    # # Directories only:
    # > koopa_aws_s3_ls \
    # >     --prefix="$prefix" \
    # >     --profile="$profile" \
    # >     --type='d'
    #
    # Recursive mode:
    # > koopa_aws_s3_ls \
    # >     --prefix="$prefix" \
    # >     --profile="$profile" \
    # >     --recursive
    # """
    local -A app dict
    local -a ls_args
    local str
    koopa_assert_has_args "$#"
    app['awk']="$(koopa_locate_awk)"
    app['aws']="$(koopa_locate_aws)"
    app['sed']="$(koopa_locate_sed --allow-system)"
    koopa_assert_is_executable "${app[@]}"
    dict['prefix']=''
    dict['profile']="${AWS_PROFILE:-default}"
    dict['recursive']=0
    dict['type']=''
    ls_args=()
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
            '--type='*)
                dict['type']="${1#*=}"
                shift 1
                ;;
            '--type')
                dict['type']="${2:?}"
                shift 2
                ;;
            # Flags ------------------------------------------------------------
            '--recursive')
                dict['recursive']=1
                shift 1
                ;;
            # Other ------------------------------------------------------------
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set \
        '--prefix' "${dict['prefix']}" \
        '--profile or AWS_PROFILE' "${dict['profile']}"
    koopa_assert_is_matching_regex \
        --pattern='^s3://.+/$' \
        --string="${dict['prefix']}"
    case "${dict['type']}" in
        '')
            dict['dirs']=1
            dict['files']=1
            ;;
        'd')
            dict['dirs']=1
            dict['files']=0
            ;;
        'f')
            dict['dirs']=0
            dict['files']=1
            ;;
        *)
            koopa_stop "Unsupported type: '${dict['type']}'."
            ;;
    esac
    if [[ "${dict['recursive']}" -eq 1 ]]
    then
        ls_args+=('--recursive')
        if [[ "${dict['type']}" == 'd' ]]
        then
            koopa_stop 'Recursive directory listing is not supported.'
        fi
    fi
    str="$( \
        "${app['aws']}" s3 ls \
            --profile "${dict['profile']}" \
            "${ls_args[@]}" \
            "${dict['prefix']}" \
            2>/dev/null \
    )"
    [[ -n "$str" ]] || return 1
    # Recursive mode, which only returns files.
    if [[ "${dict['recursive']}" -eq 1 ]]
    then
        dict['bucket_prefix']="$( \
            koopa_grep \
                --only-matching \
                --pattern='^s3://[^/]+' \
                --regex \
                --string="${dict['prefix']}" \
        )"
        files="$( \
            koopa_grep \
                --pattern='^[0-9]{4}-[0-9]{2}-[0-9]{2}' \
                --regex \
                --string="$str" \
            || true \
        )"
        [[ -n "$files" ]] || return 0
        files="$( \
            # shellcheck disable=SC2016
            koopa_print "$files" \
                | "${app['awk']}" '{print $4}' \
                | "${app['awk']}" 'NF' \
                | "${app['sed']}" "s|^|${dict['bucket_prefix']}/|g" \
                | koopa_grep --pattern='^s3://.+[^/]$' --regex \
        )"
        koopa_print "$files"
        return 0
    fi
    # Directories.
    if [[ "${dict['dirs']}" -eq 1 ]]
    then
        dirs="$( \
            koopa_grep \
                --only-matching \
                --pattern='^\s+PRE\s.+/$' \
                --regex \
                --string="$str" \
            || true \
        )"
        if [[ -n "$dirs" ]]
        then
            dirs="$( \
                koopa_print "$dirs" \
                    | "${app['sed']}" 's|^ \+PRE ||g' \
                    | "${app['awk']}" 'NF' \
                    | "${app['sed']}" "s|^|${dict['prefix']}|g" \
            )"
            koopa_print "$dirs"
        fi
    fi
    # Files.
    if [[ "${dict['files']}" -eq 1 ]]
    then
        files="$( \
            koopa_grep \
                --pattern='^[0-9]{4}-[0-9]{2}-[0-9]{2}' \
                --regex \
                --string="$str" \
            || true \
        )"
        if [[ -n "$files" ]]
        then
            # shellcheck disable=SC2016
            files="$( \
                koopa_print "$files" \
                    | "${app['awk']}" '{print $4}' \
                    | "${app['awk']}" 'NF' \
                    | "${app['sed']}" "s|^|${dict['prefix']}|g" \
            )"
            koopa_print "$files"
        fi
    fi
    return 0
}
