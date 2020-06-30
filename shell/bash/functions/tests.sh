#!/usr/bin/env bash

_koopa_test_find_files_by_ext() {  # {{{1
    # """
    # Find relevant test files by extension.
    # @note Updated 2020-06-29.
    # """
    [[ "$#" -gt 0 ]] || return 1
    local ext files pattern x
    ext="${1:?}"
    pattern="\.${ext}$"
    readarray -t files <<< "$(_koopa_test_find_files)"
    x="$( \
        printf '%s\n' "${files[@]}" \
        | grep -Ei "$pattern" \
    )"
    [[ -n "$x" ]] || return 1
    _koopa_print "$x"
    return 0
}

_koopa_test_find_files_by_shebang() {  # {{{1
    # """
    # Find relevant test files by shebang.
    # @note Updated 2020-06-29.
    # """
    [[ "$#" -gt 0 ]] || return 1
    local file files pattern shebang_files x
    pattern="${1:?}"
    readarray -t files <<< "$(_koopa_test_find_files)"
    shebang_files=()
    for file in "${files[@]}"
    do
        x="$(
            grep -El \
                --binary-files="without-match" \
                "$pattern" \
                "$file" \
            || true \
        )"
        [[ -n "$x" ]] && shebang_files+=("$x")
    done
    printf '%s\n' "${shebang_files[@]}"
    return 0
}

_koopa_test_find_failures() {  # {{{1
    # """
    # Find test failures.
    # @note Updated 2020-06-29.
    # """
    [[ "$#" -gt 0 ]] || return 1
    local failures file files ignore name pattern x
    name="$(_koopa_basename_sans_ext "$0")"
    pattern="${1:?}"
    ignore="${2:-}"
    failures=()
    readarray -t files <<< "$(_koopa_test_find_files)"
    for file in "${files[@]}"
    do
        # Skip ignored files.
        if [[ -n "$ignore" ]]
        then
            if grep -Eq \
                --binary-files="without-match" \
                "^# koopa nolint=\"${ignore}\"$" \
                "$file"
            then
                continue
            fi
        fi
        x="$(
            grep -EHn \
                --binary-files="without-match" \
                "$pattern" \
                "$file" \
            || true \
        )"
        [[ -n "$x" ]] && failures+=("$x")
    done
    if [[ "${#failures[@]}" -gt 0 ]]
    then
        _koopa_status_fail "${name} [${#failures[@]}]"
        printf '%s\n' "${failures[@]}"
        return 1
    fi
    _koopa_status_ok "${name} [${#files[@]}]"
    return 0
}
