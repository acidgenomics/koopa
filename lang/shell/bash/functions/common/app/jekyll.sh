#!/usr/bin/env bash

koopa::jekyll_deploy_to_aws() { # {{{1
    # """
    # Deploy Jekyll website to AWS S3 and CloudFront.
    # @note Updated 2021-09-21.
    # """
    local aws bucket_prefix bundle distribution_id local_prefix profile
    koopa::assert_has_args "$#"
    aws="$(koopa::locate_aws)"
    bundle="$(koopa::locate_bundle)"
    profile="${AWS_PROFILE:-default}"
    koopa::assert_is_file 'Gemfile'
    local_prefix='_site'
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--bucket='*)
                bucket_prefix="${1#*=}"
                shift 1
                ;;
            '--bucket')
                bucket_prefix="${2:?}"
                shift 2
                ;;
            '--distribution-id='*)
                distribution_id="${1#*=}"
                shift 1
                ;;
            '--distribution-id')
                distribution_id="${2:?}"
                shift 2
                ;;
            '--profile='*)
                profile="${1#*=}"
                shift 1
                ;;
            '--profile')
                profile="${2:?}"
                shift 2
                ;;
            # Other ------------------------------------------------------------
            *)
                koopa::invalid_arg "$1"
                ;;
        esac
    done
    koopa::assert_is_set 'bucket_prefix' 'distribution_id' 'local_prefix'
    bucket_prefix="$(koopa::strip_trailing_slash "$bucket_prefix")"
    local_prefix="$(koopa::strip_trailing_slash "$local_prefix")"
    if [[ -f 'Gemfile.lock' ]]
    then
        "$bundle" update --bundler
    fi
    "$bundle" install
    "$bundle" exec jekyll build
    koopa::aws_s3_sync "${local_prefix}/" "${bucket_prefix}/"
    "$aws" cloudfront create-invalidation \
        --distribution-id="$distribution_id" \
        --profile="$profile" \
        --paths '/'
    return 0
}

koopa::jekyll_serve() { # {{{1
    # """
    # Render Jekyll website.
    # Updated 2021-09-21.
    # """
    local bundle dir
    koopa::assert_has_args_le "$#" 1
    bundle="$(koopa::locate_bundle)"
    koopa::assert_is_file 'Gemfile'
    dir="${1:-.}"
    dir="$(koopa::realpath "$dir")"
    koopa::alert "Serving Jekyll website in '${dir}'."
    (
        koopa::cd "$dir"
        if [[ -f 'Gemfile.lock' ]]
        then
            "$bundle" update --bundler
        fi
        "$bundle" install
        "$bundle" exec jekyll serve
    )
    return 0
}
