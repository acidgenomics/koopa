#!/usr/bin/env bash

koopa::find() { # {{{1
    # """
    # Find files using Rust fd (faster) or GNU findutils (slower).
    # @note Updated 2021-05-20.
    #
    # Consider updating the variant defined in the Bash header upon any
    # changes to this function.
    # """
    local find find_args glob min_depth prefix print0 type
    min_depth=1
    max_depth=0
    print0=0
    type='f'
    while (("$#"))
    do
        case "$1" in
            --glob=*)
                glob="${1#*=}"
                shift 1
                ;;
            --max-depth=*)
                max_depth="${1#*=}"
                shift 1
                ;;
            --min-depth=*)
                min_depth="${1#*=}"
                shift 1
                ;;
            --prefix=*)
                prefix="${1#*=}"
                shift 1
                ;;
            --print0)
                print0=1
                shift 1
                ;;
            --type=*)
                type="${1#*=}"
                shift 1
                ;;
            *)
                koopa::invalid_arg "$1"
                ;;
        esac
    done
    koopa::assert_has_no_args "$#"
    koopa::assert_is_set 'glob' 'prefix'
    koopa::assert_is_dir "$prefix"
    if koopa::is_installed 'fd'
    then
        find='fd'
        find_args=(
            '--absolute-path'
            '--base-directory' "$prefix"
            '--case-sensitive'
            '--glob' "$glob"
            '--hidden'
            '--min-depth' "$min_depth"
            '--no-ignore'
            '--one-file-system'
            '--type' "$type"
        )
        if [[ "$max_depth" -gt 0 ]]
        then
            find_args+=('--max-depth' "$max_depth")
        fi
        if [[ "$print0" -eq 1 ]]
        then
            find_args+=('--print0')
        fi
    else
        find="$(koopa::locate_find)"
        find_args=('-L' "$prefix")
        if [[ "$max_depth" -gt 0 ]]
        then
            find_args+=('-maxdepth' "$max_depth")
        fi
        find_args+=(
            '-mindepth' "$min_depth"
            '-type' "$type"
            '-name' "$glob"
        )
        if [[ "$print0" -eq 1 ]]
        then
            find_args+=('--print0')
        else
            find_args+=('--print')
        fi
    fi
    koopa::assert_is_installed "$find"
    "${find[@]}" "${find_args[@]}"
    return 0
}

koopa::find_and_move_in_sequence() { # {{{1
    # """
    # Find and move files in sequence.
    # @note Updated 2021-01-04.
    # """
    koopa::assert_has_args "$#"
    koopa::r_script 'findAndMoveInSequence' "$@"
    return 0
}

koopa::find_and_replace_in_files() { # {{{1
    # """
    # Find and replace inside files.
    # @note Updated 2021-05-08.
    #
    # Parameterized, supporting multiple files.
    #
    # This step requires GNU sed and won't work with BSD sed currently installed
    # by default on macOS.
    # https://stackoverflow.com/questions/4247068/
    # """
    local file from sed to
    koopa::assert_has_args_ge "$#" 3
    sed="$(koopa::locate_sed)"
    from="${1:?}"
    to="${2:?}"
    shift 2
    koopa::alert "Replacing '${from}' with '${to}' in ${#} files."
    if { \
        koopa::str_match "${from}" '/' && \
        ! koopa::str_match "${from}" '\/'; \
    } || { \
        koopa::str_match "${to}" '/' && \
        ! koopa::str_match "${to}" '\/'; \
    }
    then
        koopa::stop 'Unescaped slash detected.'
    fi
    for file in "$@"
    do
        [[ -f "$file" ]] || return 1
        koopa::alert_info "$file"
        "$sed" -i "s/${from}/${to}/g" "$file"
    done
    return 0
}

koopa::find_broken_symlinks() { # {{{1
    # """
    # Find broken symlinks.
    # @note Updated 2021-06-16.
    #
    # Note that 'grep -v' is more compatible with macOS and BusyBox than use of
    # 'grep --invert-match'.
    # """
    local find grep prefix sort x
    koopa::assert_has_args "$#"
    find="$(koopa::locate_find)"
    grep="$(koopa::locate_grep)"
    sort="$(koopa::locate_sort)"
    koopa::assert_is_dir "$@"
    for prefix in "$@"
    do
        prefix="$(koopa::realpath "$prefix")"
        x="$( \
            "$find" "$prefix" \
                -xdev \
                -mindepth 1 \
                -xtype l \
                -print \
                2>&1 \
            | "$grep" --invert-match 'Permission denied' \
            | "$sort" \
        )"
        [[ -n "$x" ]] || continue
        koopa::print "$x"
    done
    return 0
}

koopa::find_dotfiles() { # {{{1
    # """
    # Find dotfiles by type.
    # @note Updated 2021-05-21.
    #
    # This is used internally by 'koopa::list_dotfiles' script.
    #
    # 1. Type ('f' file; or 'd' directory).
    # 2. Header message (e.g. 'Files')
    # """
    local awk basename header sort type x xargs
    koopa::assert_has_args_eq "$#" 2
    awk="$(koopa::locate_awk)"
    basename="$(koopa::locate_basename)"
    sort="$(koopa::locate_sort)"
    xargs="$(koopa::locate_xargs)"
    type="${1:?}"
    header="${2:?}"
    # shellcheck disable=SC2016
    x="$( \
        koopa::find \
            --glob='.*' \
            --max-depth=1 \
            --prefix="${HOME:?}" \
            --print0 \
            --type="$type" \
        | "$xargs" -0 -n1 "$basename" \
        | "$sort" \
        | "$awk" '{print "    -",$0}' \
    )"
    koopa::h2 "${header}:"
    koopa::print "$x"
    return 0
}

koopa::find_empty_dirs() { # {{{1
    # """
    # Find empty directories.
    # @note Updated 2021-06-16.
    # """
    local find grep prefix sort x
    koopa::assert_has_args "$#"
    find="$(koopa::locate_find)"
    grep="$(koopa::locate_grep)"
    sort="$(koopa::locate_sort)"
    koopa::assert_is_dir "$@"
    for prefix in "$@"
    do
        prefix="$(koopa::realpath "$prefix")"
        x="$( \
            "$find" "$prefix" \
                -xdev \
                -mindepth 0 \
                -type d \
                -not -path '*/.*/*' \
                -empty \
                -print \
                2>&1 \
            | "$grep" --invert-match 'Permission denied' \
            | "$sort" \
        )"
        [[ -n "$x" ]] || continue
        koopa::print "$x"
    done
    return 0
}

koopa::find_files_without_line_ending() { # {{{1
    # """
    # Find files without line ending.
    # @note Updated 2021-06-16.
    #
    # @seealso
    # - https://stackoverflow.com/questions/4631068/
    # """
    local files find grep pcregrep prefix sort
    koopa::assert_has_args "$#"
    find="$(koopa::locate_find)"
    grep="$(koopa::locate_grep)"
    pcregrep="$(koopa::locate_pcregrep)"
    sort="$(koopa::locate_sort)"
    koopa::assert_is_dir "$@"
    for prefix in "$@"
    do
        prefix="$(koopa::realpath "$prefix")"
        readarray -t files <<< "$(
            "$find" "$prefix" \
                -mindepth 1 \
                -type 'f' \
                2>&1 \
            | "$grep" --invert-match 'Permission denied' \
            | "$sort" \
        )"
        koopa::is_array_non_empty "${files[@]:-}" || continue
        x="$("$pcregrep" -LMr '\n$' "${files[@]}")"
        [[ -n "$x" ]] || continue
        koopa::print "$x"
    done
    return 0
}

# FIXME This is OK to return with success on empty.
# FIXME Parameterize, supporting multiple dirs.
koopa::find_large_dirs() { # {{{1
    # """
    # Find large directories.
    # @note Updated 2021-05-24.
    # """
    local dir du head sort x
    koopa::assert_has_args_le "$#" 1
    du="$(koopa::locate_du)"
    head="$(koopa::locate_head)"
    sort="$(koopa::locate_sort)"
    dir="${1:-.}"
    dir="$(koopa::realpath "$dir")"
    x="$( \
        "$du" \
            --max-depth=20 \
            --threshold=100000000 \
            "${dir}"/* \
            2>/dev/null \
        | "$sort" -n \
        | "$head" -n 100 \
        || true \
    )"
    [[ -n "$x" ]] || return 1
    koopa::print "$x"
    return 0
}

# FIXME Parameterize, supporting multiple dirs.
koopa::find_large_files() { # {{{1
    # """
    # Find large files.
    # @note Updated 2021-05-24.
    #
    # Note that use of 'grep --null-data' requires GNU grep.
    #
    # Usage of '-size +100M' isn't POSIX.
    #
    # @seealso
    # https://unix.stackexchange.com/questions/140367/
    # """
    local dir du find grep sort tail x xargs
    koopa::assert_has_args_le "$#" 1
    du="$(koopa::locate_du)"
    find="$(koopa::locate_find)"
    grep="$(koopa::locate_grep)"
    sort="$(koopa::locate_sort)"
    tail="$(koopa::locate_tail)"
    xargs="$(koopa::locate_xargs)"
    dir="${1:-.}"
    dir="$(koopa::realpath "$dir")"
    x="$( \
        "$find" "$dir" \
            -xdev \
            -mindepth 1 \
            -type 'f' \
            -size '+100000000c' \
            -print0 \
            2>&1 \
        | "$grep" \
            --invert-match 'Permission denied' \
            --null-data \
        | "$xargs" -0 "$du" \
        | "$sort" -n \
        | "$tail" -n 100 \
    )"
    koopa::print "$x"
    return 0
}

koopa::find_non_symlinked_make_files() { # {{{1
    # """
    # Find non-symlinked make files.
    # @note Updated 2021-05-22.
    #
    # Standard directories: bin, etc, include, lib, lib64, libexec, man, sbin,
    # share, src.
    # """
    local app_prefix brew_prefix find find_args koopa_prefix make_prefix
    local opt_prefix sort x
    koopa::assert_has_no_args "$#"
    find="$(koopa::locate_find)"
    sort="$(koopa::locate_sort)"
    app_prefix="$(koopa::app_prefix)"
    koopa_prefix="$(koopa::koopa_prefix)"
    opt_prefix="$(koopa::opt_prefix)"
    make_prefix="$(koopa::make_prefix)"
    find_args=(
        "$make_prefix"
        -xdev
        -mindepth 1
        -type f
        -not -path "${app_prefix}/*"
        -not -path "${koopa_prefix}/*"
        -not -path "${opt_prefix}/*"
    )
    if koopa::is_linux
    then
        find_args+=(
            -not -path "${make_prefix}/share/applications/mimeinfo.cache"
            -not -path "${make_prefix}/share/emacs/site-lisp/*"
            -not -path "${make_prefix}/share/zsh/site-functions/*"
        )
    elif koopa::is_macos
    then
        # Current cruft (2021-05-21):
        # - /usr/local/etc/fonts/conf.d
        # - /usr/local/etc/httpd
        # - /usr/local/etc/openldap
        # - /usr/local/lib/node_modules/npm
        # - /usr/local/lib/python3.8/site-packages
        # - /usr/local/lib/python3.9/site-packages
        # - /usr/local/lib/ruby/site_ruby
        # - /usr/local/lib/tcl8.6
        # - /usr/local/lib/tk8.6
        # - /usr/local/share/texinfo
        brew_prefix="$(koopa::homebrew_prefix)"
        find_args+=(
            -not -path "${brew_prefix}/Caskroom/*"
            -not -path "${brew_prefix}/Cellar/*"
            -not -path "${brew_prefix}/Homebrew/*"
            -not -path "${make_prefix}/MacGPG2/*"
            -not -path "${make_prefix}/gfortran/*"
            -not -path "${make_prefix}/texlive/*"
        )
    fi
    x="$("$find" "${find_args[@]}" | "$sort")"
    koopa::print "$x"
    return 0
}
