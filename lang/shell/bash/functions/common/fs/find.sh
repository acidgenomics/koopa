#!/usr/bin/env bash

# FIXME Think about how we want to handle regex option here...
# FIXME Need to add a sort option here...
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
    if __koopa_is_installed 'fd'
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
        find='find'
        __koopa_is_installed 'gfind' && find='gfind'
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
    if ! __koopa_is_installed "$find"
    then
        __koopa_warning "Not installed: '${find}'."
        return 1
    fi
    "${find[@]}" "${find_args[@]}"
    return 0
}














koopa::find_and_move_in_sequence() { # {{{1
    # """
    # Find and move files in sequence.
    # @note Updated 2021-01-04.
    # """
    koopa::assert_has_args "$#"
    koopa::rscript 'findAndMoveInSequence' "$@"
    return 0
}

# FIXME Need to harden to GNU sed on macOS...
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
    local file from to
    koopa::assert_has_args_ge "$#" 3
    koopa::assert_has_gnu sed  # FIXME Rework this.
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
        sed -i "s/${from}/${to}/g" "$file"
    done
    return 0
}

# FIXME Harden this to GNU find on macOS...
# FIXME Can we use fd for this?
koopa::find_broken_symlinks() { # {{{1
    # """
    # Find broken symlinks.
    # @note Updated 2020-07-03.
    #
    # Note that 'grep -v' is more compatible with macOS and BusyBox than use of
    # 'grep --invert-match'.
    # """
    local dir
    koopa::assert_has_args_le "$#" 1
    koopa::assert_is_installed find grep
    dir="${1:-.}"
    [[ -d "$dir" ]] || return 0
    dir="$(koopa::realpath "$dir")"
    local x
    x="$( \
        find "$dir" \
            -xdev \
            -mindepth 1 \
            -xtype l \
            -print \
            2>&1 \
            | grep -v 'Permission denied' \
            | sort \
    )"
    koopa::print "$x"
    return 0
}

koopa::find_dotfiles() { # {{{1
    # """
    # Find dotfiles by type.
    # @note Updated 2021-05-20.
    #
    # This is used internally by 'koopa::list_dotfiles' script.
    #
    # 1. Type ('f' file; or 'd' directory).
    # 2. Header message (e.g. 'Files')
    # """
    local header type x
    koopa::assert_has_args_eq "$#" 2
    koopa::assert_is_installed awk find
    type="${1:?}"
    header="${2:?}"
    x="$( \
        koopa::find \
            --glob='.*' \
            --max-depth=1 \
            --prefix="${HOME:?}" \
            --print0 \
            --type="$type" \
        | xargs -0 -n1 basename \
        | sort \
        | awk '{print "    -",$0}' \
    )"
    koopa::h2 "${header}:"
    koopa::print "$x"
    return 0
}

koopa::find_empty_dirs() { # {{{1
    # """
    # Find empty directories.
    # @note Updated 2020-07-03.
    # """
    local dir x
    koopa::assert_has_args_le "$#" 1
    koopa::assert_is_installed find grep
    dir="${1:-.}"
    dir="$(koopa::realpath "$dir")"
    x="$( \
        find "$dir" \
            -xdev \
            -mindepth 1 \
            -type d \
            -not -path '*/.*/*' \
            -empty \
            -print \
            2>&1 \
            | grep -v 'Permission denied' \
            | sort \
    )"
    koopa::print "$x"
    return 0
}

koopa::find_files_without_line_ending() { # {{{1
    # """
    # Find files without line ending.
    # @note Updated 2021-05-08.
    #
    # @seealso
    # - https://stackoverflow.com/questions/4631068/
    # """
    local files prefix
    koopa::assert_has_args_le "$#" 1
    koopa::assert_is_installed find pcregrep
    prefix="${1:-.}"
    koopa::assert_is_dir "$prefix"
    readarray -t files <<< "$(
        find "$prefix" \
            -mindepth 1 \
            -type f \
    )"
    koopa::is_array_non_empty "${files[@]:-}" || return 1
    x="$(pcregrep -LMr '\n$' "${files[@]}")"
    [[ -n "$x" ]] || return 1
    koopa::print "$x"
    return 0
}

koopa::find_large_dirs() { # {{{1
    # """
    # Find large directories.
    # @note Updated 2021-05-08.
    # """
    local dir x
    koopa::assert_has_args_le "$#" 1
    koopa::assert_is_installed du
    dir="${1:-.}"
    dir="$(koopa::realpath "$dir")"
    x="$( \
        du \
            --max-depth=20 \
            --threshold=100000000 \
            "${dir}"/* \
            2>/dev/null \
        | sort -n \
        | head -n 100 \
        || true \
    )"
    [[ -n "$x" ]] || return 1
    koopa::print "$x"
    return 0
}

koopa::find_large_files() { # {{{1
    # """
    # Find large files.
    # @note Updated 2020-07-03.
    #
    # Note that use of 'grep --null-data' requires GNU grep.
    #
    # Usage of '-size +100M' isn't POSIX.
    #
    # @seealso
    # https://unix.stackexchange.com/questions/140367/
    # """
    local dir x
    koopa::assert_has_args_le "$#" 1
    koopa::assert_is_installed find grep
    dir="${1:-.}"
    dir="$(koopa::realpath "$dir")"
    x="$( \
        find "$dir" \
            -xdev \
            -mindepth 1 \
            -type f \
            -size +100000000c \
            -print0 \
            2>&1 \
            | grep \
                --null-data \
                --invert-match 'Permission denied' \
            | xargs -0 du \
            | sort -n \
            | tail -n 100 \
    )"
    koopa::print "$x"
    return 0
}

koopa::find_local_bin_dirs() { # {{{1
    # """
    # Find local bin directories.
    # @note Updated 2020-07-05.
    #
    # Should we exclude koopa from this search?
    #
    # See also:
    # - https://stackoverflow.com/questions/23356779
    # - https://stackoverflow.com/questions/7442417
    # """
    koopa::assert_has_no_args "$#"
    local prefix x
    prefix="$(koopa::make_prefix)"
    x="$( \
        find "$prefix" \
            -mindepth 2 \
            -maxdepth 3 \
            -type d \
            -name 'bin' \
            -not -path '*/Caskroom/*' \
            -not -path '*/Cellar/*' \
            -not -path '*/Homebrew/*' \
            -not -path '*/anaconda3/*' \
            -not -path '*/bcbio/*' \
            -not -path '*/conda/*' \
            -not -path '*/lib/*' \
            -not -path '*/miniconda3/*' \
            -not -path '*/opt/*' \
            -print | sort \
    )"
    koopa::print "$x"
    return 0
}

koopa::find_non_symlinked_make_files() { # {{{1
    # """
    # Find non-symlinked make files.
    # @note Updated 2021-01-19.
    #
    # Standard directories: bin, etc, include, lib, lib64, libexec, man, sbin,
    # share, src.
    # """
    local app_prefix koopa_prefix make_prefix opt_prefix x
    koopa::assert_has_no_args "$#"
    koopa::assert_is_installed find || return 1
    app_prefix="$(koopa::app_prefix)"
    koopa_prefix="$(koopa::koopa_prefix)"
    opt_prefix="$(koopa::opt_prefix)"
    make_prefix="$(koopa::make_prefix)"
    x="$( \
        find "$make_prefix" \
            -xdev \
            -mindepth 1 \
            -type f \
            -not -path "${app_prefix}/*" \
            -not -path "${koopa_prefix}/*" \
            -not -path "${opt_prefix}/*" \
            -not -path "${make_prefix}/share/applications/mimeinfo.cache" \
            -not -path "${make_prefix}/share/emacs/site-lisp/*" \
            -not -path "${make_prefix}/share/zsh/site-functions/*" \
        | sort \
    )"
    koopa::print "$x"
    return 0
}
