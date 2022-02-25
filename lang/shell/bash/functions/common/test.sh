#!/usr/bin/env bash

koopa_test() { # {{{1
    # """
    # Run all koopa unit tests.
    # @note Updated 2022-02-17.
    # """
    local prefix
    koopa_assert_has_no_args "$#"
    prefix="$(koopa_tests_prefix)"
    (
        koopa_cd "$prefix"
        ./check-bin-man-consistency
        ./linter
        ./shunit2
        # > ./roff
    )
    return 0
}

koopa_test_find_files() { # {{{1
    # """
    # Find relevant files for unit tests.
    # @note Updated 2022-02-24.
    #
    # Not sorting here can speed the function up.
    # """
    local dict files
    koopa_assert_has_no_args "$#"
    declare -A dict=(
        [prefix]="$(koopa_koopa_prefix)"
    )
    readarray -t files <<< "$( \
        koopa_find \
            --exclude='**/etc/R/**' \
            --exclude='*.1' \
            --exclude='*.md' \
            --exclude='*.ronn' \
            --exclude='*.swp' \
            --exclude='.*' \
            --exclude='.git/**' \
            --exclude='app/**' \
            --exclude='coverage/**' \
            --exclude='etc/R/**' \
            --exclude='opt/**' \
            --exclude='tests/**' \
            --exclude='todo.org' \
            --prefix="${dict[prefix]}" \
            --type='f' \
    )"
    if koopa_is_array_empty "${files[@]:-}"
    then
        koopa_stop 'Failed to find any test files.'
    fi
    koopa_print "${files[@]}"
}

koopa_test_find_files_by_ext() { # {{{1
    # """
    # Find relevant test files by extension.
    # @note Updated 2022-01-31.
    # """
    local all_files dict
    koopa_assert_has_args "$#"
    declare -A dict=(
        [ext]="${1:?}"
    )
    dict[pattern]="\.${dict[ext]}$"
    readarray -t all_files <<< "$(koopa_test_find_files)"
    dict[files]="$( \
        koopa_print "${all_files[@]}" \
        | koopa_grep \
            --extended-regexp \
            --pattern="${dict[pattern]}" \
        || true \
    )"
    if [[ -z "${dict[files]}" ]]
    then
        koopa_stop "Failed to find test files with extension '${dict[ext]}'."
    fi
    koopa_print "${dict[files]}"
    return 0
}

koopa_test_find_files_by_shebang() { # {{{1
    # """
    # Find relevant test files by shebang.
    # @note Updated 2022-01-31.
    # """
    local all_files app dict file shebang_files
    koopa_assert_has_args "$#"
    declare -A app=(
        [head]="$(koopa_locate_head)"
        [tr]="$(koopa_locate_tr)"
    )
    declare -A dict=(
        [pattern]="${1:?}"
    )
    readarray -t all_files <<< "$(koopa_test_find_files)"
    shebang_files=()
    for file in "${all_files[@]}"
    do
        local shebang
        [[ -s "$file" ]] || continue
        # Avoid 'command substitution: ignored null byte in input' warning.
        shebang="$( \
            "${app[tr]}" --delete '\0' < "$file" \
                | "${app[head]}" --lines=1 \
        )"
        [[ -n "$shebang" ]] || continue
        if koopa_str_detect_regex \
            --string="$shebang" \
            --pattern="${dict[pattern]}"
        then
            shebang_files+=("$file")
        fi
    done
    koopa_print "${shebang_files[@]}"
    return 0
}

koopa_test_grep() { # {{{1
    # """
    # Grep illegal patterns.
    # @note Updated 2022-01-31.
    #
    # Requires Perl-compatible regular expression (PCRE) support (-P).
    #
    # This doesn't currently ignore commented lines.
    # """
    local app dict failures file pos
    koopa_assert_has_args "$#"
    declare -A app=(
        [grep]="$(koopa_locate_grep)"
    )
    declare -A dict=(
        [ignore]=''
        [name]=''
        [pattern]=''
    )
    pos=()
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--ignore='*)
                dict[ignore]="${1#*=}"
                shift 1
                ;;
            '--ignore' | \
            '-i')
                dict[ignore]="${2:?}"
                shift 2
                ;;
            '--name='*)
                dict[name]="${1#*=}"
                shift 1
                ;;
            '--name' | \
            '-n')
                dict[name]="${2:?}"
                shift 2
                ;;
            '--pattern='*)
                dict[pattern]="${1#*=}"
                shift 1
                ;;
            '--pattern' | \
            '-p')
                dict[pattern]="${2:?}"
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
        '--name' "${dict[name]}" \
        '--pattern' "${dict[pattern]}"
    failures=()
    for file in "$@"
    do
        local x
        # Skip ignored files.
        if [[ -n "${dict[ignore]}" ]]
        then
            if "${app[grep]}" -Pq \
                --binary-files='without-match' \
                "^# koopa nolint=${dict[ignore]}$" \
                "$file"
            then
                continue
            fi
        fi
        x="$(
            "${app[grep]}" -HPn \
                --binary-files='without-match' \
                "${dict[pattern]}" \
                "$file" \
            || true \
        )"
        [[ -n "$x" ]] && failures+=("$x")
    done
    if [[ "${#failures[@]}" -gt 0 ]]
    then
        koopa_status_fail "${dict[name]} [${#failures[@]}]"
        printf '%s\n' "${failures[@]}"
        return 1
    fi
    koopa_status_ok "${dict[name]} [${#}]"
    return 0
}

koopa_test_true_color() { # {{{1
    # """
    # Test 24-bit true color support.
    # @note Updated 2022-01-31.
    #
    # @seealso
    # https://jdhao.github.io/2018/10/19/tmux_nvim_true_color/
    # """
    local app
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [awk]="$(koopa_locate_awk)"
    )
    "${app[awk]}" 'BEGIN{
        s="/\\/\\/\\/\\/\\"; s=s s s s s s s s;
        for (colnum = 0; colnum<77; colnum++) {
            r = 255-(colnum*255/76);
            g = (colnum*510/76);
            b = (colnum*255/76);
            if (g>255) g = 510-g;
            printf "\033[48;2;%d;%d;%dm", r,g,b;
            printf "\033[38;2;%d;%d;%dm", 255-r,255-g,255-b;
            printf "%s\033[0m", substr(s,colnum+1,1);
        }
        printf "\n";
    }'
    return 0
}
