#!/usr/bin/env bash
# shellcheck disable=SC2039

_koopa_aws_s3_ls() {
    # """
    # List AWS S3 bucket.
    # @note Updated 2020-02-10.
    #
    # @seealso aws s3 ls help
    #
    # @examples
    # _koopa_aws_s3_ls s3://cpi-bioinfo01/
    # _koopa_aws_s3_ls cpi-bioinfo01/
    # """
    _koopa_is_installed aws || return 1

    local flags
    flags=()

    local pos
    pos=()
    while (("$#"))
    do
        case "$1" in
            --recursive)
                flags+=("--recursive")
                shift 1
                ;;
            --)
                shift 1
                break
                ;;
            --*|-*)
                _koopa_invalid_arg "$1"
                ;;
            *)
                POSITIONAL+=("$1")
                shift 1
                ;;
        esac
    done
    set -- "${pos[@]}"

    local prefix
    prefix="${1:?}"
    prefix="$(_strip_trailing_slash "$prefix")"
    prefix="${prefix}/"

    local x
    x="$(aws s3 ls "${flags[@]}" "$prefix")"

    dirs="$(echo "$x" | grep -Eo '  PRE .+$')"
    if [[ -n "$dirs" ]]
    then
        dirs="$( \
            echo "$dirs" \
                | sed 's/^  PRE //g' \
                | sed "s|^|${prefix}|g" \
        )"
        echo "$dirs"
    fi

    files="$(echo "$x" | grep -E '^[0-9]{4}-[0-9]{2}-[0-9]{2}')"
    if [[ -n "$files" ]]
    then
        files="$( \
            echo "$files" \
                | grep -Eo '  [0-9]+ .+$' \
                | sed 's/^  [0-9]* //g' \
                | sed "s|^|${prefix}|g" \
        )"
        echo "$files"
    fi

    return 0
}
