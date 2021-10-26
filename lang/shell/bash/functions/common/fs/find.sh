#!/usr/bin/env bash

# FIXME I think multiple exclude calls aren't working here currently.

koopa::find() { # {{{1
    # """
    # Find files using Rust fd (faster) or GNU findutils (slower).
    # @note Updated 2021-10-26.
    #
    # Consider updating the variant defined in the Bash header upon any
    # changes to this function.
    #
    # @seealso
    # - NULL-byte handling in Bash
    #   https://unix.stackexchange.com/questions/174016/
    # - https://stackoverflow.com/questions/55015044/
    # - https://unix.stackexchange.com/questions/356045/
    #
    # Bash array sorting:
    # - https://stackoverflow.com/questions/7442417/
    # - https://unix.stackexchange.com/questions/247655/
    # """
    local dict exclude_arg exclude_arr find find_args
    local results sort sorted_results
    declare -A dict=(
        [empty]=0
        [engine]=''
        [glob]=''
        [max_depth]=0
        [min_depth]=1
        [print0]=0
        [size]=''
        [sort]=0
        [type]=''
    )
    exclude_arr=()
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--engine='*)
                dict[engine]="${1#*=}"
                shift 1
                ;;
            '--engine')
                dict[engine]="${2:?}"
                shift 2
                ;;
            '--exclude='*)
                exclude_arr+=("${1#*=}")
                shift 1
                ;;
            '--exclude')
                exclude_arr+=("${2:?}")
                shift 2
                ;;
            '--glob='*)
                dict[glob]="${1#*=}"
                shift 1
                ;;
            '--glob')
                dict[glob]="${2:?}"
                shift 2
                ;;
            '--max-depth='*)
                dict[max_depth]="${1#*=}"
                shift 1
                ;;
            '--max-depth')
                dict[max_depth]="${2:?}"
                shift 2
                ;;
            '--min-depth='*)
                dict[min_depth]="${1#*=}"
                shift 1
                ;;
            '--min-depth')
                dict[min_depth]="${2:?}"
                shift 2
                ;;
            '--prefix='*)
                dict[prefix]="${1#*=}"
                shift 1
                ;;
            '--prefix')
                dict[prefix]="${2:?}"
                shift 2
                ;;
            '--size='*)
                dict[size]="${1#*=}"
                shift 1
                ;;
            '--size')
                dict[size]="${2:?}"
                shift 2
                ;;
            '--type='*)
                dict[type]="${1#*=}"
                shift 1
                ;;
            '--type')
                dict[type]="${2:?}"
                shift 2
                ;;
            # Flags ------------------------------------------------------------
            '--empty')
                dict[empty]=1
                shift 1
                ;;
            '--print0')
                dict[print0]=1
                shift 1
                ;;
            '--sort')
                dict[sort]=1
                shift 1
                ;;
            # Other ------------------------------------------------------------
            *)
                koopa::invalid_arg "$1"
                ;;
        esac
    done
    koopa::assert_has_no_args "$#"
    koopa::assert_is_dir "${dict[prefix]}"
    dict[prefix]="$(koopa::realpath "${dict[prefix]}")"
    if [[ -z "${dict[engine]}" ]]
    then
        find="$(koopa::locate_fd 2>/dev/null || true)"
        [[ ! -x "$find" ]] && find="$(koopa::locate_find)"
        case "$(koopa::basename "$find")" in
            'fd')
                dict[engine]='rust-fd'
                ;;
            'find')
                dict[engine]='gnu-find'
                ;;
            *)
                koopa::stop 'Unable to locate supported find engine.'
                ;;
        esac
    else
        case "${dict[engine]}" in
            'gnu-find')
                find="$(koopa::locate_find)"
                ;;
            'rust-fd')
                find="$(koopa::locate_fd)"
                ;;
        esac
    fi
    case "${dict[engine]}" in
        'gnu-find')
            find_args=(
                "${dict[prefix]}"
                '-xdev'
            )
            if [[ "${dict[min_depth]}" -gt 0 ]]
            then
                find_args+=('-mindepth' "${dict[min_depth]}")
            fi
            if [[ "${dict[max_depth]}" -gt 0 ]]
            then
                find_args+=('-maxdepth' "${dict[max_depth]}")
            fi
            if [[ -n "${dict[glob]}" ]]
            then
                find_args+=('-name' "${dict[glob]}")
            fi
            if [[ -n "${dict[type]}" ]]
            then
                case "${dict[type]}" in
                    'broken-symlink')
                        find_args+=('-xtype' 'l')
                        ;;
                    'd' | \
                    'f')
                        find_args+=('-type' "${dict[type]}")
                        ;;
                    *)
                        koopa::stop 'Invalid type argument for GNU find.'
                esac
            fi
            if koopa::is_array_non_empty "${exclude_arr[@]:-}"
            then
                for exclude_arg in "${exclude_arr[@]}"
                do
                    find_args+=('-not' '-path' "$exclude_arg")
                done
            fi
            if [[ "${dict[empty]}" -eq 1 ]]
            then
                find_args+=('-empty')
            fi
            if [[ -n "${dict[size]}" ]]
            then
                find_args+=('-size' "${dict[size]}")
            fi
            if [[ "${dict[print0]}" -eq 1 ]]
            then
                find_args+=('-print0')
            else
                find_args+=('-print')
            fi
            ;;
        'rust-fd')
            find_args=(
                '--absolute-path'
                '--base-directory' "${dict[prefix]}"
                '--case-sensitive'
                '--hidden'
                '--no-ignore'
                '--one-file-system'
            )
            if [[ -n "${dict[glob]}" ]]
            then
                find_args+=('--glob' "${dict[glob]}")
            fi
            if [[ "${dict[min_depth]}" -gt 0 ]]
            then
                find_args+=('--min-depth' "${dict[min_depth]}")
            fi
            if [[ "${dict[max_depth]}" -gt 0 ]]
            then
                find_args+=('--max-depth' "${dict[max_depth]}")
            fi
            if [[ -n "${dict[type]}" ]]
            then
                case "${dict[type]}" in
                    'd')
                        dict[type]='directory'
                        ;;
                    'f')
                        dict[type]='file'
                        ;;
                    *)
                        koopa::stop 'Invalid type argument for Rust fd.'
                        ;;
                esac
                find_args+=('--type' "${dict[type]}")
            fi
            if [[ "${dict[empty]}" -eq 1 ]]
            then
                # This is additive with other '--type' calls.
                find_args+=('--type' 'empty')
            fi
            if koopa::is_array_non_empty "${exclude_arr[@]:-}"
            then
                for exclude_arg in "${exclude_arr[@]}"
                do
                    find_args+=('--exclude' "$exclude_arg")
                done
            fi
            if [[ -n "${dict[size]}" ]]
            then
                # Convert GNU find 'c' for bytes into 'b' convention here.
                dict[size]="$(koopa::sub 'c^' 'b' "${dict[size]}")"
                find_args+=('--size' "${dict[size]}")
            fi
            if [[ "${dict[print0]}" -eq 1 ]]
            then
                find_args+=('--print0')
            fi
            ;;
        *)
            koopa::stop 'Invalid find engine.'
            ;;
    esac
    koopa::assert_is_installed "$find"
    [[ "${dict[sort]}" -eq 1 ]] && sort="$(koopa::locate_sort)"
    if [[ "${dict[print0]}" -eq 1 ]]
    then
        # NULL-byte ('\0') approach (non-POSIX).
        # Bash complains about NULL butes when assigned to variables
        # (e.g. via '<<<' with readarray), but NULL bytes at process
        # substitution (e.g. '< <' with readarray) are handled correctly.
        readarray -t -d '' results < <( \
            "${find[@]}" "${find_args[@]}" 2>/dev/null \
        )
        koopa::is_array_non_empty "${results[@]:-}" || return 1
        if [[ "${dict[sort]}" -eq 1 ]]
        then
            readarray -t -d '' sorted_results < <( \
                printf '%s\0' "${results[@]}" | "$sort" -z \
            )
            results=("${sorted_results[@]}")
        fi
        printf '%s\0' "${results[@]}"
    else
        # Line-break ('\n') approach (POSIX).
        readarray -t results <<< "$( \
            "${find[@]}" "${find_args[@]}" 2>/dev/null \
        )"
        koopa::is_array_non_empty "${results[@]:-}" || return 1
        if [[ "${dict[sort]}" -eq 1 ]]
        then
            readarray -t sorted_results <<< "$( \
                koopa::print "${results[@]}" | "$sort" \
            )"
            results=("${sorted_results[@]}")
        fi
        koopa::print "${results[@]}"
    fi
    return 0
}

koopa::find_and_move_in_sequence() { # {{{1
    # """
    # Find and move files in sequence.
    # @note Updated 2021-08-14.
    # """
    koopa::assert_has_args "$#"
    koopa::r_koopa 'cliFindAndMoveInSequence' "$@"
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
        koopa::str_match_fixed "${from}" '/' && \
        ! koopa::str_match_fixed "${from}" '\/'; \
    } || { \
        koopa::str_match_fixed "${to}" '/' && \
        ! koopa::str_match_fixed "${to}" '\/'; \
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
    # @note Updated 2021-10-26.
    # """
    local prefix x
    koopa::assert_has_args "$#"
    koopa::assert_is_dir "$@"
    for prefix in "$@"
    do
        x="$( \
            koopa::find \
                --engine='gnu-find' \
                --min-depth=1 \
                --prefix="$(koopa::realpath "$prefix")" \
                --sort \
                --type='broken-symlink' \
        )"
        [[ -n "$x" ]] || continue
        koopa::print "$x"
    done
    return 0
}

koopa::find_dotfiles() { # {{{1
    # """
    # Find dotfiles by type.
    # @note Updated 2021-10-26.
    #
    # This is used internally by 'koopa::list_dotfiles' script.
    #
    # 1. Type ('f' file; or 'd' directory).
    # 2. Header message (e.g. 'Files')
    # """
    local app header sort type x
    koopa::assert_has_args_eq "$#" 2
    declare -A app=(
        [awk]="$(koopa::locate_awk)"
        [basename]="$(koopa::locate_basename)"
        [xargs]="$(koopa::locate_xargs)"
    )
    type="${1:?}"
    header="${2:?}"
    # shellcheck disable=SC2016
    x="$( \
        koopa::find \
            --glob='.*' \
            --max-depth=1 \
            --prefix="${HOME:?}" \
            --print0 \
            --sort \
            --type="$type" \
        | "${app[xargs]}" -0 -n1 "${app[basename]}" \
        | "${app[awk]}" '{print "    -",$0}' \
    )"
    koopa::h2 "${header}:"
    koopa::print "$x"
    return 0
}

koopa::find_empty_dirs() { # {{{1
    # """
    # Find empty directories.
    # @note Updated 2021-10-26.
    # """
    local prefix x
    koopa::assert_has_args "$#"
    koopa::assert_is_dir "$@"
    for prefix in "$@"
    do
        x="$( \
            koopa::find \
                --empty \
                --exclude='*/.*/*' \
                --min-depth=0 \
                --prefix="$(koopa::realpath "$prefix")" \
                --sort \
                --type='d' \
        )"
        [[ -n "$x" ]] || continue
        koopa::print "$x"
    done
    return 0
}

koopa::find_files_without_line_ending() { # {{{1
    # """
    # Find files without line ending.
    # @note Updated 2021-10-25.
    #
    # @seealso
    # - https://stackoverflow.com/questions/4631068/
    # """
    local app files prefix
    koopa::assert_has_args "$#"
    declare -A app=(
        [pcregrep]="$(koopa::locate_pcregrep)"
    )
    koopa::assert_is_dir "$@"
    for prefix in "$@"
    do
        readarray -t files <<< "$(
            koopa::find \
                --min-depth=1 \
                --prefix="$(koopa::realpath "$prefix")" \
                --sort \
                --type='f' \
        )"
        koopa::is_array_non_empty "${files[@]:-}" || continue
        x="$("${app[pcregrep]}" -LMr '\n$' "${files[@]}")"
        [[ -n "$x" ]] || continue
        koopa::print "$x"
    done
    return 0
}

koopa::find_large_dirs() { # {{{1
    # """
    # Find large directories.
    # @note Updated 2021-10-26.
    # """
    local app prefix x
    koopa::assert_has_args "$#"
    declare -A app=(
        [du]="$(koopa::locate_du)"
        [sort]="$(koopa::locate_sort)"
        [tail]="$(koopa::locate_tail)"
    )
    koopa::assert_is_dir "$@"
    for prefix in "$@"
    do
        prefix="$(koopa::realpath "$prefix")"
        x="$( \
            "${app[du]}" \
                --max-depth=10 \
                --threshold=100000000 \
                "${prefix}"/* \
                2>/dev/null \
            | "${app[sort]}" -n \
            | "${app[tail]}" -n 50 \
            || true \
        )"
        [[ -n "$x" ]] || continue
        koopa::print "$x"
    done
    return 0
}

koopa::find_large_files() { # {{{1
    # """
    # Find large files.
    # @note Updated 2021-10-26.
    #
    # @seealso
    # https://unix.stackexchange.com/questions/140367/
    # """
    local app prefix x
    koopa::assert_has_args "$#"
    declare -A app=(
        [du]="$(koopa::locate_du)"
        [sort]="$(koopa::locate_sort)"
        [tail]="$(koopa::locate_tail)"
        [xargs]="$(koopa::locate_xargs)"
    )
    koopa::assert_is_dir "$@"
    for prefix in "$@"
    do
        x="$( \
            koopa::find \
                --min-depth=1 \
                --prefix="$(koopa::realpath "$prefix")" \
                --print0 \
                --size='+100000000c' \
                --type='f' \
            | "${app[xargs]}" -0 "${app[du]}" \
            | "${app[sort]}" -n \
            | "${app[tail]}" -n 50 \
        )"
        [[ -n "$x" ]] || continue
        koopa::print "$x"
    done
    return 0
}

koopa::find_non_symlinked_make_files() { # {{{1
    # """
    # Find non-symlinked make files.
    # @note Updated 2021-10-26.
    #
    # Standard directories: bin, etc, include, lib, lib64, libexec, man, sbin,
    # share, src.
    #
    # NOTE Exclusion patterns must be relative to glob for rust-fd to work.
    # """
    local app_prefix brew_prefix find_args koopa_prefix make_prefix opt_prefix x
    koopa::assert_has_no_args "$#"
    app_prefix="$(koopa::app_prefix)"
    koopa_prefix="$(koopa::koopa_prefix)"
    opt_prefix="$(koopa::opt_prefix)"
    make_prefix="$(koopa::make_prefix)"
    find_args=(
        '--engine' 'gnu-find'
        '--min-depth' 1
        '--prefix' "$make_prefix"
        '--sort'
        '--type' 'f'
    )
    find_args+=(
        '--exclude' "${app_prefix}/*"
        '--exclude' "${koopa_prefix}/*"
        '--exclude' "${opt_prefix}/*"
    )
    if koopa::is_linux
    then
        find_args+=(
            '--exclude' "${make_prefix}/share/applications/mimeinfo.cache"
            '--exclude' "${make_prefix}/share/emacs/site-lisp/*"
            '--exclude' "${make_prefix}/share/zsh/site-functions/*"
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
            '--exclude' "${brew_prefix}/Caskroom/*"
            '--exclude' "${brew_prefix}/Cellar/*"
            '--exclude' "${brew_prefix}/Homebrew/*"
            '--exclude' "${make_prefix}/MacGPG2/*"
            '--exclude' "${make_prefix}/gfortran/*"
            '--exclude' "${make_prefix}/texlive/*"
        )
    fi
    x="$(koopa::find "${find_args[@]}")"
    koopa::print "$x"
    return 0
}
