#!/usr/bin/env bash

# FIXME Use jq to get the count of items in the JSON here.
# FIXME Print out the path of the temporary file for debugging.

koopa_aws_s3_delete_markers() {
    # """
    # Clean up delete markers in S3 bucket.
    # Updated 2025-05-09.
    # """
    local -A app bool dict
    local i
    app['aws']="$(koopa_locate_aws)"
    # FIXME head
    # FIXME cut
    # FIXME wc
    koopa_assert_is_executable "${app[@]}"
    bool['dry_run']=0
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
    koopa_alert "Removing deletion markers in '${dict['bucket']}' at \
'${dict['prefix']}'."
    dict['objects_file']="$(koopa_tmp_file)"
    dict['query']='{Objects: DeleteMarkers[].{Key:Key,VersionId:VersionId}}'
    koopa_dl 'Query' "${dict['query']}"
    i=0
    while [[ -f "${dict['objects_file']}" ]]
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
            --query="${dict['query']}" \
            2> /dev/null \
            > "${dict['objects_file']}"
        if grep -q '"Objects": null' "${dict['objects_file']}"
        then
            koopa_alert_note 'No deletion markers detected.'
            koopa_rm "${dict['objects_file']}"
            break
        fi
        dict['lines']="$( \
            "${app['wc']}" -l "${dict['objects_file']}" \
            | "${app['cut']}" -d ' ' -f 1 \
        )"
        if [[ "${dict['lines']}" -gt 3997 ]]
        then
            # FIXME Rework this approach.
            "${app['head']}" -n 3997 output.tmp > output.json
            # FIXME Use koopa_append_string here instead.
            echo "        } ] }" >> output.json
            # FIXME Move back to original object.
        fi
        # FIXME If dry-run, just show the objects file here instead.
        # FIXME Need to pass more parameters here.
        "${app['aws']}" s3api delete-objects \
            --bucket "${dict['bucket']}" \
            --delete "file://${dict['objects_file']}" \
            --profile "${dict['profile']}"
    done
    return 0
}
