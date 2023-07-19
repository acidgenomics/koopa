#!/usr/bin/env bash

koopa_jekyll_deploy_to_aws() {
    # """
    # Deploy Jekyll website to AWS S3 and CloudFront.
    # @note Updated 2023-07-18.
    #
    # @seealso
    # - aws cloudfront create-invalidation help
    # """
    local -A app dict
    koopa_assert_has_args "$#"
    app['aws']="$(koopa_locate_aws)"
    app['bundle']="$(koopa_locate_bundle)"
    koopa_assert_is_executable "${app[@]}"
    dict['bucket_prefix']=''
    dict['bundle_prefix']="$(koopa_xdg_data_home)/gem"
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
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set \
        '--bucket' "${dict['bucket_prefix']:-}" \
        '--distribution-id' "${dict['distribution_id']:-}" \
        '--profile' "${dict['profile']:-}"
    koopa_assert_is_dir "${dict['local_prefix']}"
    dict['local_prefix']="$( \
        koopa_realpath "${dict['local_prefix']}" \
    )"
    dict['bucket_prefix']="$( \
        koopa_strip_trailing_slash "${dict['bucket_prefix']}" \
    )"
    koopa_alert "Deploying '${dict['local_prefix']}' \
to '${dict['bucket_prefix']}'."
    (
        koopa_cd "${dict['local_prefix']}"
        koopa_assert_is_file 'Gemfile'
        koopa_dl 'Bundle prefix' "${dict['bundle_prefix']}"
        "${app['bundle']}" config set --local path "${dict['bundle_prefix']}"
        [[ -f 'Gemfile.lock' ]] && koopa_rm 'Gemfile.lock'
        "${app['bundle']}" install
        "${app['bundle']}" exec jekyll build
        koopa_rm 'Gemfile.lock'
    )
    koopa_aws_s3_sync --profile="${dict['profile']}" \
        "${dict['local_prefix']}/_site/" \
        "${dict['bucket_prefix']}/"
    # Using 'yes' here to avoid pager invocation.
    koopa_alert "Invalidating CloudFront cache at '${dict['distribution_id']}'."
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
