#!/usr/bin/env bash

koopa::test_find_files_by_ext() { # {{{1
    # """
    # Find relevant test files by extension.
    # @note Updated 2020-06-29.
    # """
    local ext files pattern x
    koopa::assert_has_args "$#"
    ext="${1:?}"
    pattern="\.${ext}$"
    readarray -t files <<< "$(koopa::test_find_files)"
    x="$( \
        printf '%s\n' "${files[@]}" \
        | grep -Ei "$pattern" \
    )"
    [[ -n "$x" ]] || return 1
    koopa::print "$x"
    return 0
}

koopa::test_find_files_by_shebang() { # {{{1
    # """
    # Find relevant test files by shebang.
    # @note Updated 2020-06-29.
    # """
    local file files pattern shebang_files x
    koopa::assert_has_args "$#"
    pattern="${1:?}"
    readarray -t files <<< "$(koopa::test_find_files)"
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

koopa::test_find_failures() { # {{{1
    # """
    # Find test failures.
    # @note Updated 2020-06-29.
    # """
    local failures file files ignore name pattern x
    koopa::assert_has_args "$#"
    name="$(koopa::basename_sans_ext "$0")"
    pattern="${1:?}"
    ignore="${2:-}"
    failures=()
    readarray -t files <<< "$(koopa::test_find_files)"
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
        koopa::status_fail "${name} [${#failures[@]}]"
        printf '%s\n' "${failures[@]}"
        return 1
    fi
    koopa::status_ok "${name} [${#files[@]}]"
    return 0
}
