#!/usr/bin/env bash

koopa_aws_s3_delete_versioned_objects() {
    # """
    # Delete all non-canonical versioned glacier objects for an S3 bucket.
    # @note Updated 2025-05-09.
    #
    # @seealso
    # - aws s3api list-object-versions help
    # - https://docs.aws.amazon.com/AmazonS3/latest/userguide/
    #     DeletingObjectVersions.html
    # - https://github.com/swoodford/aws/blob/master/
    #     s3-remove-glacier-objects.sh
    # - https://gist.github.com/sdarwin/dcb4afc68f0952ded62d864a6f720ccb
    # - https://github.com/swoodford/aws/blob/master/
    #     s3-remove-glacier-objects.sh
    #
    # @examples
    # > koopa_aws_s3_delete_versioned_glacier_objects \
    # >     --bucket='example-bucket' \
    # >     --dry-run \
    # >     --prefix='subdir' \
    # >     --profile='default' \
    # >     --region='us-east-1'
    # """
    local -A app bool dict
    local i
    app['aws']="$(koopa_locate_aws)"
    koopa_assert_is_executable "${app[@]}"
    bool['dry_run']=0
    bool['glacier']=0
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
                bool['dry_run']=1
                shift 1
                ;;
            '--glacier')
                bool['glacier']=1
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
    dict['bucket']="$( \
        koopa_sub \
            --pattern='s3://' \
            --replacement='' \
            "${dict['bucket']}" \
    )"
    dict['bucket']="$(koopa_strip_trailing_slash "${dict['bucket']}")"
    if [[ "${bool['dry_run']}" -eq 1 ]]
    then
        koopa_alert_info 'Dry run mode enabled.'
    fi
    koopa_alert "Deleting outdated versioned objects in \
's3://${dict['bucket']}/${dict['prefix']}/'."
    dict['json_file']="$(koopa_tmp_file)"
    if [[ "${bool['glacier']}" -eq 1 ]]
    then
        dict['version_query']="StorageClass=='GLACIER'"
    else
        dict['version_query']="IsLatest==\`false\`"
    fi
    dict['query']="{Objects: Versions[?${dict['version_query']}].\
{Key:Key,VersionId:VersionId}}"
    koopa_dl \
        'JSON file' "${dict['json_file']}" \
        'Query' "${dict['query']}"
    i=0
    while [[ -f "${dict['json_file']}" ]]
    do
        i=$((i+1))
        koopa_alert_info "Batch ${i}"
        "${app['aws']}" s3api list-object-versions \
            --bucket "${dict['bucket']}" \
            --max-items 1000 \
            --no-cli-pager \
            --output 'json' \
            --prefix "${dict['prefix']}" \
            --profile "${dict['profile']}" \
            --query "${dict['query']}" \
            --region "${dict['region']}" \
            2> /dev/null \
            > "${dict['json_file']}"
        koopa_assert_is_file "${dict['json_file']}"
        if koopa_file_detect_fixed \
            --file="${dict['json_file']}" \
            --pattern='"Objects": null' \
        || koopa_file_detect_fixed \
            --file="${dict['json_file']}" \
            --pattern='"Objects": []'
        then
            koopa_alert_note 'No outdated versioned objects detected.'
            koopa_rm "${dict['json_file']}"
            break
        fi
        if [[ "${bool['dry_run']}" -eq 1 ]]
        then
            app['less']="$(koopa_locate_less)"
            koopa_assert_is_executable "${app['less']}"
            "${app['less']}" "${dict['json_file']}"
            break
        fi
        "${app['aws']}" s3api delete-objects \
            --bucket "${dict['bucket']}" \
            --delete "file://${dict['json_file']}" \
            --no-cli-pager \
            --profile "${dict['profile']}" \
            --region "${dict['region']}"
    done
    return 0
}
