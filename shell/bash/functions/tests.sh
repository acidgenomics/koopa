#!/usr/bin/env bash

koopa::test_find_files() { # {{{1
    # """
    # Find relevant files for unit tests.
    # @note Updated 2020-07-08.
    # Not sorting here can speed the function up.
    # """
    koopa::assert_has_no_args "$#"
    local prefix x
    prefix="$(koopa::prefix)"
    x="$( \
        find "$prefix" \
            -mindepth 1 \
            -type f \
            -not -name "$(basename "$0")" \
            -not -name '*.md' \
            -not -name '.pylintrc' \
            -not -path "${prefix}/.git/*" \
            -not -path "${prefix}/cellar/*" \
            -not -path "${prefix}/coverage/*" \
            -not -path "${prefix}/dotfiles/*" \
            -not -path "${prefix}/opt/*" \
            -not -path "${prefix}/tests/*" \
            -not -path "${prefix}/workflows/*" \
            -not -path '*/etc/R/*' \
            -print \
        | sort \
    )"
    koopa::print "$x"
}

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

koopa::test_grep() { # {{{1
    # """
    # Grep illegal patterns.
    # @note Updated 2020-07-07.
    # """
    local OPTIND failures file ignore name pattern x
    koopa::assert_has_args "$#"
    ignore=
    OPTIND=1
    while getopts 'i:n:p:' opt
    do
        case "$opt" in
            i)
                ignore="$OPTARG"
                ;;
            n)
                name="$OPTARG"
                ;;
            p)
                pattern="$OPTARG"
                ;;
            \?)
                koopa::invalid_arg
                ;;
        esac
    done
    shift "$((OPTIND-1))"
    koopa::assert_has_args "$#"
    koopa::assert_is_set name pattern
    failures=()
    for file in "$@"
    do
        # Skip ignored files.
        if [[ -n "$ignore" ]]
        then
            if grep -Eq \
                --binary-files="without-match" \
                "^# koopa nolint=${ignore}$" \
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
    koopa::status_ok "${name} [${#}]"
    return 0
}
