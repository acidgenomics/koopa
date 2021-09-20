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
    # @note Updated 2021-05-21.
    # Not sorting here can speed the function up.
    # """
    local find grep prefix sort x
    koopa::assert_has_no_args "$#"
    find="$(koopa::locate_find)"
    grep="$(koopa::locate_grep)"
    sort="$(koopa::locate_sort)"
    prefix="$(koopa::koopa_prefix)"
    x="$( \
        "$find" "$prefix" \
            -mindepth 1 \
            -type f \
            -not -name "$(koopa::basename "$0")" \
            -not -name '*.1' \
            -not -name '*.md' \
            -not -name '*.ronn' \
            -not -name '*.swp' \
            -not -name '.pylintrc' \
            -not -path "$(koopa::app_prefix)/*" \
            -not -path "$(koopa::opt_prefix)/*" \
            -not -path "${prefix}/.*" \
            -not -path "${prefix}/.git/*" \
            -not -path "${prefix}/app/*" \
            -not -path "${prefix}/cellar/*" \
            -not -path "${prefix}/coverage/*" \
            -not -path "${prefix}/dotfiles/*" \
            -not -path "${prefix}/lang/r/.Rproj.user/*" \
            -not -path "${prefix}/lang/shell/bash/functions/deprecated/*" \
            -not -path "${prefix}/opt/*" \
            -not -path "${prefix}/tests/*" \
            -not -path "${prefix}/todo.org" \
            -not -path '*/etc/R/*' \
            -print \
        2>&1 \
        | "$grep" -v 'Permission denied' \
        | "$sort" \
    )"
    koopa::print "$x"
}

koopa::test_find_files_by_ext() { # {{{1
    # """
    # Find relevant test files by extension.
    # @note Updated 2021-05-21.
    # """
    local ext files grep pattern x
    koopa::assert_has_args "$#"
    grep="$(koopa::locate_grep)"
    ext="${1:?}"
    pattern="\.${ext}$"
    readarray -t files <<< "$(koopa::test_find_files)"
    x="$( \
        printf '%s\n' "${files[@]}" \
        | "$grep" -Ei "$pattern" \
        || true \
    )"
    [[ -n "$x" ]] || return 1
    koopa::print "$x"
    return 0
}

koopa::test_find_files_by_shebang() { # {{{1
    # """
    # Find relevant test files by shebang.
    # @note Updated 2021-05-21.
    # """
    local file files head pattern shebang shebang_files tr x
    koopa::assert_has_args "$#"
    head="$(koopa::locate_head)"
    tr="$(koopa::locate_tr)"
    pattern="${1:?}"
    readarray -t files <<< "$(koopa::test_find_files)"
    shebang_files=()
    for file in "${files[@]}"
    do
        [[ -s "$file" ]] || continue
        # Avoid 'command substitution: ignored null byte in input' warning.
        shebang="$("$tr" -d '\0' < "$file" | "$head" -n 1)"
        [[ -n "$shebang" ]] || continue
        koopa::str_match_regex "$shebang" "$pattern" && shebang_files+=("$file")
    done
    koopa::print "${shebang_files[@]}"
    return 0
}

koopa::test_grep() { # {{{1
    # """
    # Grep illegal patterns.
    # @note Updated 2021-05-21.
    #
    # Requires Perl-compatible regular expression (PCRE) support (-P).
    #
    # This doesn't currently ignore commented lines.
    # """
    local OPTIND failures file grep ignore name pattern x
    koopa::assert_has_args "$#"
    ignore=''
    OPTIND=1
    while getopts 'i:n:p:' opt
    do
        case "$opt" in
            'i')
                ignore="$OPTARG"
                ;;
            'n')
                name="$OPTARG"
                ;;
            'p')
                pattern="$OPTARG"
                ;;
            \?)
                koopa::invalid_arg
                ;;
        esac
    done
    shift "$((OPTIND-1))"
    koopa::assert_has_args "$#"
    grep="$(koopa::locate_grep)"
    failures=()
    for file in "$@"
    do
        # Skip ignored files.
        if [[ -n "$ignore" ]]
        then
            if "$grep" -Pq \
                --binary-files='without-match' \
                "^# koopa nolint=${ignore}$" \
                "$file"
            then
                continue
            fi
        fi
        x="$(
            "$grep" -HPn \
                --binary-files='without-match' \
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

koopa::test_true_color() { # {{{1
    # """
    # Test 24-bit true color support.
    # @note Updated 2021-05-24.
    #
    # @seealso
    # https://jdhao.github.io/2018/10/19/tmux_nvim_true_color/
    # """
    local awk
    koopa::assert_has_no_args "$#"
    awk="$(koopa::locate_awk)"
    "$awk" 'BEGIN{
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
