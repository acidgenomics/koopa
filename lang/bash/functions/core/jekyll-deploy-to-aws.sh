#!/usr/bin/env bash

_koopa_jekyll_deploy_to_aws() {
    # """
    # Deploy Jekyll website to AWS S3 and CloudFront.
    # @note Updated 2023-07-18.
    #
    # @seealso
    # - aws cloudfront create-invalidation help
    # """
    local -A app dict
    _koopa_assert_has_args "$#"
    app['aws']="$(_koopa_locate_aws)"
    app['bundle']="$(_koopa_locate_bundle)"
    _koopa_assert_is_executable "${app[@]}"
    dict['bucket_prefix']=''
    dict['bundle_prefix']="$(_koopa_xdg_data_home)/gem"
    dict['distribution_id']=''
    dict['local_prefix']="${PWD:?}"
    dict['profile']="${AWS_PROFILE:-default}"
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--bucket='*)
                dict['bucket_prefix']="${1#*=}"
                shift 1
                ;;
            '--bucket')
                dict['bucket_prefix']="${2:?}"
                shift 2
                ;;
            '--distribution-id='*)
                dict['distribution_id']="${1#*=}"
                shift 1
                ;;
            '--distribution-id')
                dict['distribution_id']="${2:?}"
                shift 2
                ;;
            '--local-prefix='*)
                dict['local_prefix']="${1#*=}"
                shift 1
                ;;
            '--local-prefix')
                dict['local_prefix']="${2:?}"
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
                _koopa_invalid_arg "$1"
                ;;
        esac
    done
    _koopa_assert_is_set \
        '--bucket' "${dict['bucket_prefix']:-}" \
        '--distribution-id' "${dict['distribution_id']:-}" \
        '--profile' "${dict['profile']:-}"
    _koopa_assert_is_dir "${dict['local_prefix']}"
    dict['local_prefix']="$( \
        _koopa_realpath "${dict['local_prefix']}" \
    )"
    dict['bucket_prefix']="$( \
        _koopa_strip_trailing_slash "${dict['bucket_prefix']}" \
    )"
    _koopa_alert "Deploying '${dict['local_prefix']}' \
to '${dict['bucket_prefix']}'."
    (
        _koopa_cd "${dict['local_prefix']}"
        _koopa_assert_is_file 'Gemfile'
        _koopa_dl 'Bundle prefix' "${dict['bundle_prefix']}"
        "${app['bundle']}" config set --local path "${dict['bundle_prefix']}"
        [[ -f 'Gemfile.lock' ]] && _koopa_rm 'Gemfile.lock'
        "${app['bundle']}" install
        "${app['bundle']}" exec jekyll build
        _koopa_rm 'Gemfile.lock'
    )
    _koopa_aws_s3_sync --profile="${dict['profile']}" \
        "${dict['local_prefix']}/_site/" \
        "${dict['bucket_prefix']}/"
    # Using 'yes' here to avoid pager invocation.
    _koopa_alert "Invalidating CloudFront cache at '${dict['distribution_id']}'."
    # The '--paths' variable should only be called once, using space-separated
    # variables. Consider adding '/css/*' here if necessary.
    "${app['aws']}" cloudfront create-invalidation \
        --distribution-id "${dict['distribution_id']}" \
        --no-cli-pager \
        --output 'text' \
        --paths '/*' \
        --profile "${dict['profile']}"
    return 0
}
