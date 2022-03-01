#!/usr/bin/env bash

koopa_jekyll_deploy_to_aws() { # {{{1
    # """
    # Deploy Jekyll website to AWS S3 and CloudFront.
    # @note Updated 2022-03-01.
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
    "${app[aws]}" --profile="${dict[profile]}" \
        cloudfront create-invalidation \
            --distribution-id="${dict[distribution_id]}" \
            --paths '/' \
            >/dev/null
    [[ -f 'Gemfile.lock' ]] && koopa_rm 'Gemfile.lock'
    return 0
}

koopa_jekyll_serve() { # {{{1
    # """
    # Render Jekyll website.
    # Updated 2021-12-08.
    # """
    local app dict
    koopa_assert_has_args_le "$#" 1
    declare -A app=(
        [bundle]="$(koopa_locate_bundle)"
    )
    declare -A dict=(
        [prefix]="${1:-}"
    )
    [[ -z "${dict[prefix]}" ]] && dict[prefix]="${PWD:?}"
    dict[prefix]="$(koopa_realpath "${dict[prefix]}")"
    koopa_alert "Serving Jekyll website in '${dict[prefix]}'."
    (
        koopa_cd "${dict[prefix]}"
        koopa_assert_is_file 'Gemfile'
        if [[ -f 'Gemfile.lock' ]]
        then
            "${app[bundle]}" update --bundler
        fi
        "${app[bundle]}" install
        "${app[bundle]}" exec jekyll serve
    )
    return 0
}
