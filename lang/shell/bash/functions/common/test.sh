#!/usr/bin/env bash

koopa::check_bin_man_consistency() { # {{{1
    # """
    # Check bin and man consistency.
    # @note Updated 2021-08-14.
    # """
    koopa::assert_has_no_args "$#"
    koopa::r_koopa 'cliCheckBinManConsistency' "$@"
    return 0
}

koopa::test() { # {{{1
    # """
    # Run koopa unit tests.
    # @note Updated 2020-08-12.
    # """
    local script
    script="$(koopa::tests_prefix)/tests"
    koopa::assert_is_file "$script"
    "$script" "$@"
    return 0
}

koopa::test_find_files() { # {{{1
    # """
    # Find relevant files for unit tests.
    # @note Updated 2022-01-31.
    #
    # Not sorting here can speed the function up.
    # """
    local app dict
    koopa::assert_has_no_args "$#"
    declare -A app=(
        [find]="$(koopa::locate_find)"
    )
    declare -A dict=(
        [app_prefix]="$(koopa::app_prefix)"
        [opt_prefix]="$(koopa::opt_prefix)"
        [prefix]="$(koopa::koopa_prefix)"
    )
    # FIXME Rework using 'koopa::find'.
    dict[files]="$( \
        "${app[find]}" "${dict[prefix]}" \
            -mindepth 1 \
            -type 'f' \
            -not -name "$(koopa::basename "$0")" \
            -not -name '*.1' \
            -not -name '*.md' \
            -not -name '*.ronn' \
            -not -name '*.swp' \
            -not -name '.pylintrc' \
            -not -path "${dict[app_prefix]}/*" \
            -not -path "${dict[opt_prefix]}/*" \
            -not -path "${dict[prefix]}/.*" \
            -not -path "${dict[prefix]}/.git/*" \
            -not -path "${dict[prefix]}/app/*" \
            -not -path "${dict[prefix]}/cellar/*" \
            -not -path "${dict[prefix]}/coverage/*" \
            -not -path "${dict[prefix]}/dotfiles/*" \
            -not -path "${dict[prefix]}/lang/r/.Rproj.user/*" \
            -not -path "${dict[prefix]}/opt/*" \
            -not -path "${dict[prefix]}/tests/*" \
            -not -path "${dict[prefix]}/todo.org" \
            -not -path '*/etc/R/*' \
            -print \
    )"
    if [[ -z "${dict[files]}" ]]
    then
        koopa::stop 'Failed to find any test files.'
    fi
    koopa::print "${dict[files]}"
}

koopa::test_find_files_by_ext() { # {{{1
    # """
    # Find relevant test files by extension.
    # @note Updated 2022-01-31.
    # """
    local all_files dict
    koopa::assert_has_args "$#"
    declare -A dict=(
        [ext]="${1:?}"
    )
    dict[pattern]="\.${dict[ext]}$"
    readarray -t all_files <<< "$(koopa::test_find_files)"
    dict[files]="$( \
        printf '%s\n' "${all_files[@]}" \
        | koopa::grep \
            --extended-regexp \
            "${dict[pattern]}" \
        || true \
    )"
    if [[ -z "${dict[files]}" ]]
    then
        koopa::stop "Failed to find test files with extension '${dict[ext]}'."
    fi
    koopa::print "${dict[files]}"
    return 0
}

koopa::test_find_files_by_shebang() { # {{{1
    # """
    # Find relevant test files by shebang.
    # @note Updated 2022-01-31.
    # """
    local all_files app dict file shebang_files
    koopa::assert_has_args "$#"
    declare -A app=(
        [head]="$(koopa::locate_head)"
        [tr]="$(koopa::locate_tr)"
    )
    declare -A dict=(
        [pattern]="${1:?}"
    )
    readarray -t all_files <<< "$(koopa::test_find_files)"
    shebang_files=()
    for file in "${all_files[@]}"
    do
        local shebang
        [[ -s "$file" ]] || continue
        # Avoid 'command substitution: ignored null byte in input' warning.
        shebang="$( \
            "${app[tr]}" -d '\0' < "$file" \
                | "${app[head]}" -n 1 \
        )"
        [[ -n "$shebang" ]] || continue
        if koopa::str_detect_regex "$shebang" "${dict[pattern]}"
        then
            shebang_files+=("$file")
        fi
    done
    koopa::print "${shebang_files[@]}"
    return 0
}

koopa::test_grep() { # {{{1
    # """
    # Grep illegal patterns.
    # @note Updated 2022-01-31.
    #
    # Requires Perl-compatible regular expression (PCRE) support (-P).
    #
    # This doesn't currently ignore commented lines.
    # """
    local app dict failures file pos
    koopa::assert_has_args "$#"
    declare -A app=(
        [grep]="$(koopa::locate_grep)"
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
                koopa::invalid_arg "$1"
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    koopa::assert_has_args "$#"
    koopa::assert_is_set \
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
        koopa::status_fail "${dict[name]} [${#failures[@]}]"
        printf '%s\n' "${failures[@]}"
        return 1
    fi
    koopa::status_ok "${dict[name]} [${#}]"
    return 0
}

koopa::test_true_color() { # {{{1
    # """
    # Test 24-bit true color support.
    # @note Updated 2022-01-31.
    #
    # @seealso
    # https://jdhao.github.io/2018/10/19/tmux_nvim_true_color/
    # """
    local app
    koopa::assert_has_no_args "$#"
    declare -A app=(
        [awk]="$(koopa::locate_awk)"
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
