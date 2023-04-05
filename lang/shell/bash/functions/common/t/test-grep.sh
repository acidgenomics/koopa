#!/usr/bin/env bash

# FIXME This doesn't seem to be picking up '\bFIXME\b' correctly.
# How to set flags for word boundary detection?
# FIXME Need to unit test this better for an expected failure.
# FIXME Allow the user to pass in multiple patterns and include this in the
# match failure more clearly...
# FIXME Can we switch to ripgrep for this?
# FIXME How to calculate array difference.
# Array3=(`echo ${Array1[@]} ${Array2[@]} | tr ' ' '\n' | sort | uniq -u `)

koopa_test_grep() {
    # """
    # Grep illegal patterns.
    # @note Updated 2022-10-07.
    #
    # Requires Perl-compatible regular expression (PCRE) support (-P).
    #
    # This doesn't currently ignore commented lines.
    # """
    local app dict failures file pos
    koopa_assert_has_args "$#"
    declare -A app
    app['grep']="$(koopa_locate_grep)"
    [[ -x "${app['grep']}" ]] || exit 1
    declare -A dict=(
        ['ignore']=''
        ['name']=''
        ['pattern']=''
    )
    pos=()
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--ignore='*)
                dict['ignore']="${1#*=}"
                shift 1
                ;;
            '--ignore')
                dict['ignore']="${2:?}"
                shift 2
                ;;
            '--name='*)
                dict['name']="${1#*=}"
                shift 1
                ;;
            '--name')
                dict['name']="${2:?}"
                shift 2
                ;;
            '--pattern='*)
                dict['pattern']="${1#*=}"
                shift 1
                ;;
            '--pattern')
                dict['pattern']="${2:?}"
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
    koopa_assert_is_set \
        '--name' "${dict['name']}" \
        '--pattern' "${dict['pattern']}"
    failures=()

    # FIXME How to set the different

    for file in "$@"
    do
        local x
        # Skip ignored files.
        if [[ -n "${dict['ignore']}" ]]
        then
            if "${app['grep']}" -Pq \
                --binary-files='without-match' \
                "^# koopa nolint=${dict['ignore']}$" \
                "$file"
            then
                continue
            fi
        fi
        x="$(
            "${app['grep']}" -HPn \
                --binary-files='without-match' \
                "${dict['pattern']}" \
                "$file" \
            || true \
        )"
        [[ -n "$x" ]] && failures+=("$x")
    done
    if [[ "${#failures[@]}" -gt 0 ]]
    then
        koopa_status_fail "${dict['name']} [${#failures[@]}]"
        printf '%s\n' "${failures[@]}"
        return 1
    fi
    koopa_status_ok "${dict['name']} [${#}]"
    return 0
}
