#!/usr/bin/env bash

koopa_jekyll_deploy_to_aws() {
    # """
    # Deploy Jekyll website to AWS S3 and CloudFront.
    # @note Updated 2022-03-11.
    # """
    local app dict
    koopa_assert_has_args "$#"
    declare -A app=(
        [aws]="$(koopa_locate_aws)"
        [bundle]="$(koopa_locate_bundle)"
    )
    declare -A dict=(
        [bucket_prefix]=''
        [distribution_id]=''
        [local_prefix]='_site'
        [profile]="${AWS_PROFILE:-}"
    )
    [[ -z "${dict[profile]}" ]] && dict[profile]='default'
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--bucket='*)
                dict[bucket_prefix]="${1#*=}"
                shift 1
                ;;
            '--bucket')
                dict[bucket_prefix]="${2:?}"
                shift 2
                ;;
            '--distribution-id='*)
                dict[distribution_id]="${1#*=}"
                shift 1
                ;;
            '--distribution-id')
                dict[distribution_id]="${2:?}"
                shift 2
                ;;
            '--profile='*)
                dict[profile]="${1#*=}"
                shift 1
                ;;
            '--profile')
                dict[profile]="${2:?}"
                shift 2
                ;;
            # Other ------------------------------------------------------------
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set \
        '--bucket' "${dict[bucket_prefix]:-}" \
        '--distribution-id' "${dict[distribution_id]:-}" \
        '--profile' "${dict[profile]:-}"
    dict[bucket_prefix]="$( \
        koopa_strip_trailing_slash "${dict[bucket_prefix]}" \
    )"
    dict[local_prefix]="$( \
        koopa_strip_trailing_slash "${dict[local_prefix]}" \
    )"
    koopa_assert_is_file 'Gemfile'
    [[ -f 'Gemfile.lock' ]] && koopa_rm 'Gemfile.lock'
    "${app[bundle]}" install
    "${app[bundle]}" exec jekyll build
    koopa_aws_s3_sync --profile="${dict[profile]}" \
        "${dict[local_prefix]}/" \
        "${dict[bucket_prefix]}/"
    # Using 'yes' here to avoid pager invocation.
    koopa_alert "Invalidating CloudFront cache at '${dict[distribution_id]}'."
    # The '--paths' variable should only be called once, using space-separated
    # variables. Consider adding '/css/*' here if necessary.
    "${app[aws]}" --profile="${dict[profile]}" \
        cloudfront create-invalidation \
            --distribution-id="${dict[distribution_id]}" \
            --paths='/*' \
            >/dev/null
    [[ -f 'Gemfile.lock' ]] && koopa_rm 'Gemfile.lock'
    return 0
}
