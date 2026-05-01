#!/usr/bin/env bash

_koopa_aws_s3_delete_markers() {
    # """
    # Clean up delete markers in S3 bucket.
    # Updated 2025-05-09.
    # """
    local -A app bool dict
    local i
    app['aws']="$(_koopa_locate_aws)"
    app['cut']="$(_koopa_locate_cut)"
    app['head']="$(_koopa_locate_head)"
    app['wc']="$(_koopa_locate_wc)"
    _koopa_assert_is_executable "${app[@]}"
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
                _koopa_invalid_arg "$1"
                ;;
        esac
    done
    _koopa_assert_is_set \
        '--bucket' "${dict['bucket']}" \
        '--profile or AWS_PROFILE' "${dict['profile']}" \
        '--region or AWS_REGION' "${dict['region']}"
    dict['bucket']="$( \
        _koopa_sub \
            --pattern='s3://' \
            --replacement='' \
            "${dict['bucket']}" \
    )"
    dict['bucket']="$(_koopa_strip_trailing_slash "${dict['bucket']}")"
    if [[ "${bool['dry_run']}" -eq 1 ]]
    then
        _koopa_alert_info 'Dry run mode enabled.'
    fi
    _koopa_alert "Removing deletion markers in \
's3://${dict['bucket']}/${dict['prefix']}/'."
    dict['json_file']="$(_koopa_tmp_file)"
    dict['query']='{Objects: DeleteMarkers[].{Key:Key,VersionId:VersionId}}'
    _koopa_dl \
        'JSON file' "${dict['json_file']}" \
        'Query' "${dict['query']}"
    i=0
    while [[ -f "${dict['json_file']}" ]]
    do
        i=$((i+1))
        _koopa_alert_info "Batch ${i}"
        "${app['aws']}" s3api list-object-versions \
            --bucket "${dict['bucket']}" \
            --max-items 1000 \
            --no-cli-pager \
            --output 'json' \
            --prefix "${dict['prefix']}" \
            --profile "${dict['profile']}" \
            --query="${dict['query']}" \
            2> /dev/null \
            > "${dict['json_file']}"
        if _koopa_file_detect_fixed \
            --file="${dict['json_file']}" \
            --pattern='"Objects": null' \
        || _koopa_file_detect_fixed \
            --file="${dict['json_file']}" \
            --pattern='"Objects": []'
        then
            _koopa_alert_note 'No deletion markers detected.'
            _koopa_rm "${dict['json_file']}"
            break
        fi
        dict['lines']="$( \
            "${app['wc']}" -l "${dict['json_file']}" \
            | "${app['cut']}" -d ' ' -f 1 \
        )"
        if [[ "${dict['lines']}" -gt 3997 ]]
        then
            dict['tmp_file']="$(_koopa_tmp_file)"
            "${app['head']}" \
                -n 3997 \
                "${dict['json_file']}" \
                > "${dict['tmp_file']}"
            _koopa_append_string \
                --file="${dict['tmp_file']}" \
                --string='        } ] }'
            _koopa_mv "${dict['tmp_file']}" "${dict['json_file']}"
        fi
        if [[ "${bool['dry_run']}" -eq 1 ]]
        then
            app['less']="$(_koopa_locate_less)"
            _koopa_assert_is_executable "${app['less']}"
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
