#!/usr/bin/env bash

koopa::jekyll_deploy_to_aws() { # {{{1
    # """
    # Deploy Jekyll website to AWS S3 and CloudFront.
    # @note Updated 20201-01-07.
    # """
    local bucket_prefix distribution_id local_prefix
    koopa::assert_has_args "$#"
    koopa::assert_is_installed aws bundle
    koopa::assert_is_file 'Gemfile'
    local_prefix='_site'
    while (("$#"))
    do
        case "$1" in
            --bucket=*)
                bucket_prefix="${1#*=}"
                shift 1
                ;;
            --distribution-id=*)
                distribution_id="${1#*=}"
                shift 1
                ;;
            *)
                koopa::invalid_arg "$1"
                ;;
        esac
    done
    koopa::assert_is_set bucket_prefix distribution_id local_prefix
    bucket_prefix="$(koopa::strip_trailing_slash "$bucket_prefix")"
    local_prefix="$(koopa::strip_trailing_slash "$local_prefix")"
    if [[ -f 'Gemfile.lock' ]]
    then
        bundle update --bundler
    fi
    bundle install
    bundle exec jekyll build
    koopa::aws_s3_sync "${local_prefix}/" "${bucket_prefix}/"
    aws cloudfront create-invalidation \
        --distribution-id="$distribution_id" \
        --profile='default' \
        --paths '/'
    return 0
}

koopa::jekyll_serve() { # {{{1
    # """
    # Render Jekyll website.
    # Updated 2021-01-07.
    # """
    local dir
    koopa::assert_has_args_le "$#" 1
    koopa::assert_is_file 'Gemfile'
    koopa::assert_is_installed bundle
    dir="${1:-.}"
    (
        koopa::cd "$dir"
        [[ -f 'Gemfile.lock' ]] && bundle update --bundler
        bundle install
        bundle exec jekyll serve
    )
    return 0
}
