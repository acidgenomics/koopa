#!/usr/bin/env bash

koopa_assert_is_existing_aws_s3_uri() {
    # """
    # Assert that input is an existing AWS S3 URI.
    # @note Updated 2023-12-05.
    # """
    local -A dict
    local -a pos
    local arg
    koopa_assert_has_args "$#"
    pos=()
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--profile='*)
                dict['profile']="${1#*=}"
                shift 1
                ;;
            '--profile')
                dict['profile']="${2:?}"
                shift 2
                ;;
            # Other ------------------------------------------------------------
            '-'*)
                koopa_invalid_arg "$1"
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    koopa_assert_has_args "$#"
    for arg in "$@"
    do
        if ! koopa_is_existing_aws_s3_uri \
            --profile="${dict['profile']}" \
            "$arg"
        then
            koopa_stop "Not AWS S3 URI: '${arg}'."
        fi
    done
    return 0
}
