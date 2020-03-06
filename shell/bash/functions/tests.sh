#!/usr/bin/env bash

_koopa_test_find_files() {  # {{{1
    # """
    # Find relevant files for unit tests.
    # @note Updated 2020-03-05.
    # """
    local koopa_prefix
    koopa_prefix="$(_koopa_prefix)"
    find "$koopa_prefix" \
        -mindepth 1 \
        -type f \
        -not -name "$(basename "$0")" \
        -not -name "Makeconf" \
        -not -name "*.md" \
        -not -name "*.site" \
        -not -name ".pylintrc" \
        -not -path "${koopa_prefix}/.git/*" \
        -not -path "${koopa_prefix}/cellar/*" \
        -not -path "${koopa_prefix}/coverage/*" \
        -not -path "${koopa_prefix}/dotfiles/*" \
        -not -path "${koopa_prefix}/opt/*" \
        -not -path "${koopa_prefix}/tests/*" \
        -print \
    | sort
    return 0
}

_koopa_test_find_files_by_ext() {  # {{{1
    # """
    # Find relevant test files by extension.
    # @note Updated 2020-02-16.
    # """
    local ext
    ext="${1:-?}"

    local pattern
    pattern="\.${ext}$"

    local files
    mapfile -t files < <(_koopa_test_find_files)

    local x
    x="$( \
        printf '%s\n' "${files[@]}" \
        | grep -Ei "$pattern" \
    )"
    _koopa_print "$x"
    return 0
}

_koopa_test_find_files_by_shebang() {  # {{{1
    # """
    # Find relevant test files by shebang.
    # @note Updated 2020-02-16.
    # """
    local pattern
    pattern="${1:?}"

    local files
    mapfile -t files < <(_koopa_test_find_files)

    local shebang_files
    shebang_files=()

    local file
    for file in "${files[@]}"
    do
        local x
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

_koopa_test_find_failures() {
    local name
    name="$(_koopa_basename_sans_ext "$0")"

    local pattern
    pattern="${1:?}"

    local files
    mapfile -t files < <(_koopa_test_find_files)

    local failures
    failures=()

    local file
    for file in "${files[@]}"
    do
        local x
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
