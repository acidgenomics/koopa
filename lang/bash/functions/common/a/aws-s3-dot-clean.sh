#!/usr/bin/env bash

koopa_aws_s3_dot_clean() {
    # """
    # Delete dot files accidentally stored in an S3 bucket.
    # @note Updated 2023-07-18.
    #
    # This also intentionally deletes git repos, which should be stored at
    # CodeCommit.
    #
    # @examples
    # koopa_aws_s3_dot_clean --dry-run --bucket='s3://28-7tx-data/'
    # """
    local -A app bool dict
    local -a keys
    local key
    app['aws']="$(koopa_locate_aws)"
    app['jq']="$(koopa_locate_jq)"
    koopa_assert_is_executable "${app[@]}"
    bool['dryrun']=0
    dict['bucket']=''
    dict['profile']="${AWS_PROFILE:-default}"
    dict['region']="${AWS_REGION:-us-east-1}"
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--bucket='*)
                dict['bucket']="${1#*=}"
                shift 1
                ;;
            '--bucket')
                dict['bucket']="${2:?}"
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
            '--region='*)
                dict['region']="${1#*=}"
                shift 1
                ;;
            '--region')
                dict['region']="${2:?}"
                shift 2
                ;;
            # Flags ------------------------------------------------------------
            '--dry-run' | \
            '--dryrun')
                bool['dryrun']=1
                shift 1
                ;;
            # Other ------------------------------------------------------------
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set \
        '--bucket' "${dict['bucket']}" \
        '--profile or AWS_PROFILE' "${dict['profile']}" \
        '--region or AWS_REGION' "${dict['region']}"
    koopa_assert_is_matching_regex \
        --pattern='^s3://.+/$' \
        --string="${dict['bucket']}"
    dict['bucket']="$( \
        koopa_sub \
            --pattern='s3://' \
            --replacement='' \
            "${dict['bucket']}" \
    )"
    dict['bucket']="$(koopa_strip_trailing_slash "${dict['bucket']}")"
    if [[ "${bool['dryrun']}" -eq 1 ]]
    then
        koopa_alert_info 'Dry run mode enabled.'
    fi
    koopa_alert "Fetching objects in '${dict['bucket']}'."
    dict['json']="$( \
        "${app['aws']}" s3api list-objects \
            --bucket "${dict['bucket']}" \
            --no-cli-pager \
            --output 'json' \
            --profile "${dict['profile']}" \
            --query "Contents[?contains(Key,'/.')].Key" \
            --region "${dict['region']}" \
    )"
    if [[ -z "${dict['json']}" ]] || [[ "${dict['json']}" == '[]' ]]
    then
        koopa_alert_note "No dot files in '${dict['bucket']}'."
        return 0
    fi
    readarray -t keys <<< "$( \
        koopa_print "${dict['json']}" \
            | "${app['jq']}" --raw-output '.[]' \
    )"
    koopa_alert_info "$(koopa_ngettext \
        --num="${#keys[@]}" \
        --msg1='object' \
        --msg2='objects' \
        --suffix=' detected.' \
    )"
    for key in "${keys[@]}"
    do
        local s3uri
        s3uri="s3://${dict['bucket']}/${key}"
        koopa_alert "Deleting '${s3uri}'."
        [[ "${bool['dryrun']}" -eq 1 ]] && continue
        "${app['aws']}" s3 rm \
            --profile "${dict['profile']}" \
            --region "${dict['region']}" \
            "$s3uri"
    done
    return 0
}
