#!/usr/bin/env bash

# FIXME glob matching against full path is broken for fd.
# FIXME How to resolve this? Currently an issue with roff tests.

koopa::find() { # {{{1
    # """
    # Find files using Rust fd (faster) or GNU findutils (slower).
    # @note Updated 2022-02-24.
    #
    # Consider updating the variant defined in the Bash header upon any
    # changes to this function.
    #
    # @section Supported regex types for GNU find:
    #
    # - findutils-default
    # - ed
    # - emacs
    # - gnu-awk
    # - grep
    # - posix-awk
    # - awk
    # - posix-basic
    # - posix-egrep
    # - egrep
    # - posix-extended
    # - posix-minimal-basic
    # - sed
    #
    # Check for supported regex types with:
    # > find . -regextype type
    #
    # @seealso
    # - NULL-byte handling in Bash
    #   https://unix.stackexchange.com/questions/174016/
    # - https://stackoverflow.com/questions/55015044/
    # - https://unix.stackexchange.com/questions/356045/
    # - Prune option ('-prune') to ignore dirs in GNU find (see also '-path').
    #   https://stackoverflow.com/a/24565095
    #
    # Bash array sorting:
    # - https://stackoverflow.com/questions/7442417/
    # - https://unix.stackexchange.com/questions/247655/
    # """
    local app dict exclude_arg exclude_arr find find_args
    local results sorted_results
    declare -A app
    declare -A dict=(
        [case_sensitive]=1
        [empty]=0
        [engine]="${KOOPA_FIND_ENGINE:-}"
        [exclude]=0
        [glob]=''
        [max_depth]=''
        [min_days_old]=0
        [min_depth]=''
        [print0]=0
        [regex]=''
        [size]=''
        [sort]=0
        [sudo]=0
        [type]=''
        [verbose]=0
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
                dict[exclude]=1
                exclude_arr+=("${1#*=}")
                shift 1
                ;;
            '--exclude')
                dict[exclude]=1
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
            '--min-days-old='*)
                dict[min_days_old]="${1#*=}"
                shift 1
                ;;
            '--min-days-old')
                dict[min_days_old]="${2:?}"
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
            '--regex='*)
                dict[regex]="${1#*=}"
                shift 1
                ;;
            '--regex')
                dict[regex]="${2:?}"
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
            '--case-sensitive')
                dict[case_sensitive]=1
                shift 1
                ;;
            '--empty')
                dict[empty]=1
                shift 1
                ;;
            '--ignore-case')
                dict[case_sensitive]=0
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
            '--sudo')
                dict[sudo]=1
                shift 1
                ;;
            '--verbose')
                dict[verbose]=1
                shift 1
                ;;
            # Other ------------------------------------------------------------
            *)
                koopa::invalid_arg "$1"
                ;;
        esac
    done
    if [[ -n "${dict[glob]}" ]] && [[ -n "${dict[regex]}" ]]
    then
        koopa::stop "Specify '--glob' or '--regex' but not both."
    fi
    koopa::assert_is_dir "${dict[prefix]}"
    dict[prefix]="$(koopa::realpath "${dict[prefix]}")"
    if [[ -z "${dict[engine]}" ]]
    then
        app[find]="$(koopa::locate_fd 2>/dev/null || true)"
        [[ ! -x "${app[find]}" ]] && app[find]="$(koopa::locate_find)"
        dict[engine]="$(koopa::basename "${app[find]}")"
    else
        app[find]="$(koopa::locate_"${dict[engine]}")"
    fi
    koopa::assert_is_installed "${app[find]}"
    find=()
    if [[ "${dict[sudo]}" -eq 1 ]]
    then
        app[sudo]="$(koopa::locate_sudo)"
        find+=("${app[sudo]}")
    fi
    find+=("${app[find]}")
    case "${dict[engine]}" in
        'fd')
            find_args=(
                # > '--full-path'  # Need to use '**' for glob with this.
                '--absolute-path'
                '--base-directory' "${dict[prefix]}"
                '--hidden'
                '--no-ignore'
                '--one-file-system'
            )
            if [[ "${dict[case_sensitive]}" -eq 1 ]]
            then
                find_args+=('--case-sensitive')
            else
                find_args+=('--ignore-case')
            fi
            if [[ -n "${dict[glob]}" ]]
            then
                find_args+=('--glob' "${dict[glob]}")
            elif [[ -n "${dict[regex]}" ]]
            then
                find_args+=('--regex' "${dict[regex]}")
            fi
            if [[ -n "${dict[min_depth]}" ]]
            then
                find_args+=('--min-depth' "${dict[min_depth]}")
            fi
            if [[ -n "${dict[max_depth]}" ]]
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
                    'l')
                        dict[type]='symlink'
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
            if [[ "${dict[min_days_old]}" -gt 0 ]]
            then
                find_args+=('--changed-before' "${dict[min_days_old]}d")
            fi
            if [[ "${dict[exclude]}" -eq 1 ]]
            then
                for exclude_arg in "${exclude_arr[@]}"
                do
                    find_args+=('--exclude' "$exclude_arg")
                done
            fi
            if [[ -n "${dict[size]}" ]]
            then
                # Convert GNU find 'c' for bytes into 'b' convention here.
                dict[size]="$( \
                    koopa::sub \
                        --pattern='c$' \
                        --replacement='b' \
                        "${dict[size]}" \
                )"
                find_args+=('--size' "${dict[size]}")
            fi
            if [[ "${dict[print0]}" -eq 1 ]]
            then
                find_args+=('--print0')
            fi
            ;;
        'find')
            find_args=(
                "${dict[prefix]}"
                '-xdev'
            )
            if [[ -n "${dict[min_depth]}" ]]
            then
                find_args+=('-mindepth' "${dict[min_depth]}")
            fi
            if [[ -n "${dict[max_depth]}" ]]
            then
                find_args+=('-maxdepth' "${dict[max_depth]}")
            fi
            # FIXME Need to test support for this change in tests/roff:80.
            if [[ -n "${dict[glob]}" ]]
            then
                if [[ "${dict[case_sensitive]}" -eq 1 ]]
                then
                    dict[glob_key]='name'
                else
                    dict[glob_key]='iname'
                fi
                if koopa::str_detect_fixed \
                    --pattern="{" \
                    --string="${dict[glob]}"
                then
                    # Look for '{aaa,bbb,ccc}' and convert to
                    # '( -name aaa -o -name bbb -o name ccc )'.
                    # Usage of '-O' here refers to array index origin.
                    # This is a really useful way to append an array.
                    readarray -O "${#find_args[@]}" -t find_args <<< "$( \
                        local globs_1 globs_2 globs_3 str
                        readarray -d ',' -t globs_1 <<< "$( \
                            koopa::gsub \
                                --pattern='[{}]' \
                                --replacement='' \
                                "${dict[glob]}" \
                        )"
                        globs_2=()
                        for i in "${!globs_1[@]}"
                        do
                            globs_2+=(
                                "-${dict[glob_key]} ${globs_1[i]}"
                            )
                        done
                        str="$( \
                            koopa::paste --sep=' -o ' "${globs_2[@]}"
                        )"
                        str="( ${str} )"
                        readarray -d ' ' -t globs_3 <<< "$(
                            koopa::print "$str"
                        )"
                        koopa::print "${globs_3[@]}"
                    )"
                else
                    find_args+=("-${dict[glob_key]}" "${dict[glob]}")
                fi
            elif [[ -n "${dict[regex]}" ]]
            then
                # GNU file '-regex' argument matches against the entire file
                # path, so we need to adjust our match here.
                dict[regex]="$( \
                    koopa::sub \
                        --pattern='^' \
                        --replacement="^${dict[prefix]}/" \
                        "${dict[regex]}" \
                )"
                # NOTE '-regextype' must come before '-regex' here.
                find_args+=(
                    '-regextype' 'posix-egrep'
                    '-regex' "${dict[regex]}"
                )
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
                        koopa::stop 'Invalid type argument for find.'
                esac
            fi
            if [[ "${dict[min_days_old]}" -gt 0 ]]
            then
                find_args+=('-ctime' "+${dict[min_days_old]}")
            fi
            # NB To ignore a directory and the files under it, consider
            # calling '-prune' here instead.
            if [[ "${dict[exclude]}" -eq 1 ]]
            then
                for exclude_arg in "${exclude_arr[@]}"
                do
                    exclude_arg="$( \
                        koopa::sub \
                            --pattern='^' \
                            --replacement="${dict[prefix]}/" \
                            "$exclude_arg" \
                    )"
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
        *)
            koopa::stop 'Invalid find engine.'
            ;;
    esac
    if [[ "${dict[verbose]}" -eq 1 ]]
    then
        koopa::warn "Find command: ${find[*]} ${find_args[*]}"
    fi
    if [[ "${dict[sort]}" -eq 1 ]]
    then
        app[sort]="$(koopa::locate_sort)"
    fi
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
                printf '%s\0' "${results[@]}" | "${app[sort]}" -z \
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
                koopa::print "${results[@]}" | "${app[sort]}" \
            )"
            results=("${sorted_results[@]}")
        fi
        koopa::print "${results[@]}"
    fi
    return 0
}

koopa::find_and_replace_in_files() { # {{{1
    # """
    # Find and replace inside files.
    # @note Updated 2022-02-17.
    #
    # Parameterized, supporting multiple files.
    #
    # This step requires GNU sed and won't work with BSD sed currently installed
    # by default on macOS.
    #
    # @seealso
    # - https://stackoverflow.com/questions/4247068/
    #
    # @examples
    # koopa::find_and_replace_in_files 'XXX' 'YYY' 'file1' 'file2' 'file3'
    # """
    local app dict file
    koopa::assert_has_args_ge "$#" 3
    declare -A app=(
        [sed]="$(koopa::locate_sed)"
    )
    declare -A dict=(
        [from]="${1:?}"
        [to]="${2:?}"
    )
    shift 2
    koopa::alert "$(koopa::ngettext \
        --prefix="Replacing '${dict[from]}' with '${dict[to]}' in " \
        --num="${#}" \
        --msg1='file' \
        --msg2='files' \
        --suffix='.' \
    )"
    if { \
        koopa::str_detect_fixed \
            --string="${dict[from]}" \
            --pattern='/' && \
        ! koopa::str_detect_fixed \
            --string="${dict[from]}" \
            --pattern='\/'; \
    } || { \
        koopa::str_detect_fixed \
            --string="${dict[to]}" \
            --pattern='/' && \
        ! koopa::str_detect_fixed \
            --string="${dict[to]}" \
            --pattern='\/'; \
    }
    then
        koopa::stop 'Unescaped slash detected.'
    fi
    koopa::assert_is_file "$@"
    for file in "$@"
    do
        koopa::alert "$file"
        "${app[sed]}" --in-place "s/${dict[from]}/${dict[to]}/g" "$file"
    done
    return 0
}

koopa::find_broken_symlinks() { # {{{1
    # """
    # Find broken symlinks.
    # @note Updated 2022-02-17.
    # """
    local prefix str
    koopa::assert_has_args "$#"
    koopa::assert_is_dir "$@"
    for prefix in "$@"
    do
        str="$( \
            koopa::find \
                --engine='find' \
                --min-depth=1 \
                --prefix="$prefix" \
                --sort \
                --type='broken-symlink' \
        )"
        [[ -n "$str" ]] || continue
        koopa::print "$str"
    done
    return 0
}

koopa::find_dotfiles() { # {{{1
    # """
    # Find dotfiles by type.
    # @note Updated 2022-02-17.
    #
    # This is used internally by 'koopa::list_dotfiles' script.
    #
    # 1. Type ('f' file; or 'd' directory).
    # 2. Header message (e.g. 'Files')
    # """
    local app dict
    koopa::assert_has_args_eq "$#" 2
    declare -A app=(
        [awk]="$(koopa::locate_awk)"
        [basename]="$(koopa::locate_basename)"
        [xargs]="$(koopa::locate_xargs)"
    )
    declare -A dict=(
        [type]="${1:?}"
        [header]="${2:?}"
    )
    # shellcheck disable=SC2016
    dict[str]="$( \
        koopa::find \
            --glob='.*' \
            --max-depth=1 \
            --prefix="${HOME:?}" \
            --print0 \
            --sort \
            --type="${dict[type]}" \
        | "${app[xargs]}" \
            --max-args=1 \
            --no-run-if-empty \
            --null \
            "${app[basename]}" \
        | "${app[awk]}" '{print "    -",$0}' \
    )"
    [[ -n "${dict[str]}" ]] || return 1
    koopa::h2 "${dict[header]}:"
    koopa::print "${dict[str]}"
    return 0
}

koopa::find_empty_dirs() { # {{{1
    # """
    # Find empty directories.
    # @note Updated 2022-02-17.
    # """
    local prefix str
    koopa::assert_has_args "$#"
    koopa::assert_is_dir "$@"
    for prefix in "$@"
    do
        str="$( \
            koopa::find \
                --empty \
                --exclude='*/.*/*' \
                --min-depth=0 \
                --prefix="$prefix" \
                --sort \
                --type='d' \
        )"
        [[ -n "$str" ]] || continue
        koopa::print "$str"
    done
    return 0
}

koopa::find_files_without_line_ending() { # {{{1
    # """
    # Find files without line ending.
    # @note Updated 2022-02-16.
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
        local str
        readarray -t files <<< "$(
            koopa::find \
                --min-depth=1 \
                --prefix="$(koopa::realpath "$prefix")" \
                --sort \
                --type='f' \
        )"
        koopa::is_array_non_empty "${files[@]:-}" || continue
        str="$("${app[pcregrep]}" -LMr '\n$' "${files[@]}")"
        [[ -n "$str" ]] || continue
        koopa::print "$str"
    done
    return 0
}

koopa::find_large_dirs() { # {{{1
    # """
    # Find large directories.
    # @note Updated 2022-02-16.
    #
    # Results are reverse sorted by size.
    #
    # @examples
    # # > koopa::find_large_dirs "${HOME}/monorepo"
    # """
    local app prefix
    koopa::assert_has_args "$#"
    declare -A app=(
        [du]="$(koopa::locate_du)"
        [sort]="$(koopa::locate_sort)"
        [tail]="$(koopa::locate_tail)"
    )
    koopa::assert_is_dir "$@"
    for prefix in "$@"
    do
        local str
        prefix="$(koopa::realpath "$prefix")"
        str="$( \
            "${app[du]}" \
                --max-depth=10 \
                --threshold=100000000 \
                "${prefix}"/* \
                2>/dev/null \
            | "${app[sort]}" --numeric-sort \
            | "${app[tail]}" --lines=50 \
            || true \
        )"
        [[ -n "$str" ]] || continue
        koopa::print "$str"
    done
    return 0
}

koopa::find_large_files() { # {{{1
    # """
    # Find large files.
    # @note Updated 2022-02-16.
    #
    # Results are sorted alphabetically currently, not by size.
    #
    # @seealso
    # - https://unix.stackexchange.com/questions/140367/
    #
    # @examples
    # > koopa::find_large_files "${HOME}/monorepo"
    # """
    local app prefix str
    koopa::assert_has_args "$#"
    declare -A app=(
        [head]="$(koopa::locate_head)"
    )
    koopa::assert_is_dir "$@"
    for prefix in "$@"
    do
        str="$( \
            koopa::find \
                --min-depth=1 \
                --prefix="$prefix" \
                --size='+100000000c' \
                --sort \
                --type='f' \
            | "${app[head]}" --lines=50 \
        )"
        [[ -n "$str" ]] || continue
        koopa::print "$str"
    done
    return 0
}

# FIXME This doesn't seem to be working when we switch engine to rust.
koopa::find_non_symlinked_make_files() { # {{{1
    # """
    # Find non-symlinked make files.
    # @note Updated 2022-02-17.
    #
    # Standard directories: bin, etc, include, lib, lib64, libexec, man, sbin,
    # share, src.
    # """
    local dict find_args
    koopa::assert_has_no_args "$#"
    declare -A dict=(
        [brew_prefix]="$(koopa::homebrew_prefix)"
        [make_prefix]="$(koopa::make_prefix)"
    )
    find_args=(
        '--min-depth' 1
        '--prefix' "${dict[make_prefix]}"
        '--sort'
        '--type' 'f'
    )
    if koopa::is_linux
    then
        find_args+=(
            '--exclude' 'share/applications/mimeinfo.cache'
            '--exclude' 'share/emacs/site-lisp/*'
            '--exclude' 'share/zsh/site-functions/*'
        )
    elif koopa::is_macos
    then
        find_args+=(
            '--exclude' 'MacGPG2/*'
            '--exclude' 'gfortran/*'
            '--exclude' 'texlive/*'
        )
    fi
    if [[ "${dict[brew_prefix]}" == "${dict[make_prefix]}" ]]
    then
        find_args+=(
            '--exclude' 'Caskroom/*'
            '--exclude' 'Cellar/*'
            '--exclude' 'Homebrew/*'
            '--exclude' 'var/homebrew/*'
        )
    fi
    dict[out]="$(koopa::find "${find_args[@]}")"
    koopa::print "${dict[out]}"
    return 0
}
