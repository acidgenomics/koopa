#!/usr/bin/env bash

# TODO Rework this to use 'delete-objects', which requires JSON input but
# only uses a single call to AWS.
# FIXME Improve CLI message to show current n out of total n.
# FIXME Rework to take bucket as first positional argument.
# FIXME Support parameterization of multiple buckets in a loop.

koopa_aws_s3_delete_versioned_glacier_objects() {
    # """
    # Delete all non-canonical versioned glacier objects for an S3 bucket.
    # @note Updated 2023-11-16.
    #
    # @seealso
    # - aws s3api list-object-versions help
    # - https://docs.aws.amazon.com/AmazonS3/latest/userguide/
    #     DeletingObjectVersions.html
    # - https://github.com/swoodford/aws/blob/master/
    #     s3-remove-glacier-objects.sh
    #
    # @examples
    # > koopa_aws_s3_delete_versioned_glacier_objects \
    # >     --dry-run \
    # >     --bucket='s3://example-bucket/' \
    # >     --profile='default' \
    # >     --region='us-east-1'
    # """
    local -A app bool dict
    local -a keys version_ids
    local i
    app['aws']="$(koopa_locate_aws)"
    app['jq']="$(koopa_locate_jq)"
    koopa_assert_is_executable "${app[@]}"
    bool['dryrun']=0
    dict['bucket']=''
    dict['prefix']=''
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
    koopa_alert "Fetching versioned Glacier objects in '${dict['bucket']}'."
    dict['json']="$( \
        "${app['aws']}" s3api list-object-versions \
            --bucket "${dict['bucket']}" \
            --no-cli-pager \
            --output 'json' \
            --prefix "${dict['prefix']}" \
            --profile "${dict['profile']}" \
            --query "Versions[?StorageClass=='GLACIER']" \
            --region "${dict['region']}" \
    )"
    if [[ -z "${dict['json']}" ]] || [[ "${dict['json']}" == '[]' ]]
    then
        koopa_alert_note "No versioned Glacier objects in '${dict['bucket']}'."
        return 0
    fi
    readarray -t keys <<< "$( \
        koopa_print "${dict['json']}" \
            | "${app['jq']}" --raw-output '.[].Key' \
    )"
    readarray -t version_ids <<< "$( \
        koopa_print "${dict['json']}" \
            | "${app['jq']}" --raw-output '.[].VersionId' \
    )"
    koopa_alert_info "$(koopa_ngettext \
        --num="${#keys[@]}" \
        --msg1='object' \
        --msg2='objects' \
        --suffix=' detected.' \
    )"
    for i in "${!keys[@]}"
    do
        local -A dict2
        dict2['key']="${keys[$i]}"
        dict2['version_id']="${version_ids[$i]}"
        koopa_alert "Deleting 's3://${dict['bucket']}/${dict2['key']}' \
(${dict2['version_id']})."
        [[ "${bool['dryrun']}" -eq 1 ]] && continue
        "${app['aws']}" s3api delete-object \
            --bucket "${dict['bucket']}" \
            --key "${dict2['key']}" \
            --no-cli-pager \
            --output 'text' \
            --profile "${dict['profile']}" \
            --region "${dict['region']}" \
            --version-id "${dict2['version_id']}" \
        > /dev/null
    done
    return 0
}
