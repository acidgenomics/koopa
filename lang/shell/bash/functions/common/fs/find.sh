#!/usr/bin/env bash

koopa_find() {
    # """
    # Find files using Rust fd (faster) or GNU findutils (slower).
    # @note Updated 2022-02-24.
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
    # - NULL-byte handling in Bash.
    #   https://unix.stackexchange.com/questions/174016/
    # - https://stackoverflow.com/questions/55015044/
    # - https://unix.stackexchange.com/questions/356045/
    # - Prune option ('-prune') to ignore traversing into a directory.
    #   https://stackoverflow.com/a/24565095
    # - Bash array sorting.
    #   https://stackoverflow.com/questions/7442417/
    #   https://unix.stackexchange.com/questions/247655/
    # """
    local app dict exclude_arg exclude_arr find find_args results sorted_results
    declare -A app
    declare -A dict=(
        [days_modified_gt]=''
        [days_modified_lt]=''
        [empty]=0
        [engine]="${KOOPA_FIND_ENGINE:-}"
        [exclude]=0
        [max_depth]=''
        [min_depth]=1
        [pattern]=''
        [print0]=0
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
            '--days-modified-before='*)
                dict[days_modified_gt]="${1#*=}"
                shift 1
                ;;
            '--days-modified-before')
                dict[days_modified_gt]="${2:?}"
                shift 2
                ;;
            '--days-modified-within='*)
                dict[days_modified_lt]="${1#*=}"
                shift 1
                ;;
            '--days-modified-within')
                dict[days_modified_lt]="${2:?}"
                shift 2
                ;;
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
            '--pattern='*)
                dict[pattern]="${1#*=}"
                shift 1
                ;;
            '--pattern')
                dict[pattern]="${2:?}"
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
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_dir "${dict[prefix]}"
    dict[prefix]="$(koopa_realpath "${dict[prefix]}")"
    if [[ -z "${dict[engine]}" ]]
    then
        app[find]="$(koopa_locate_fd --allow-missing)"
        [[ ! -x "${app[find]}" ]] && app[find]="$(koopa_locate_find)"
        dict[engine]="$(koopa_basename "${app[find]}")"
    else
        app[find]="$(koopa_locate_"${dict[engine]}")"
    fi
    koopa_assert_is_installed "${app[find]}"
    find=()
    if [[ "${dict[sudo]}" -eq 1 ]]
    then
        app[sudo]="$(koopa_locate_sudo)"
        find+=("${app[sudo]}")
    fi
    find+=("${app[find]}")
    case "${dict[engine]}" in
        'fd')
            find_args=(
                # Don't use '--full-path' here.
                '--absolute-path'
                '--base-directory' "${dict[prefix]}"
                '--case-sensitive'
                '--glob'
                '--hidden'
                '--no-follow'
                '--no-ignore'
                '--one-file-system'
            )
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
                        koopa_stop 'Invalid type argument for Rust fd.'
                        ;;
                esac
                find_args+=('--type' "${dict[type]}")
            fi
            if [[ "${dict[empty]}" -eq 1 ]]
            then
                # This is additive with other '--type' calls.
                find_args+=('--type' 'empty')
            fi
            if [[ -n "${dict[days_modified_gt]}" ]]
            then
                find_args+=(
                    '--changed-before'
                    "${dict[days_modified_gt]}d"
                )
            fi
            if [[ -n "${dict[days_modified_lt]}" ]]
            then
                find_args+=(
                    '--changed-within'
                    "${dict[days_modified_lt]}d"
                )
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
                    koopa_sub \
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
            if [[ -n "${dict[pattern]}" ]]
            then
                find_args+=("${dict[pattern]}")
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
            if [[ -n "${dict[pattern]}" ]]
            then
                if koopa_str_detect_fixed \
                    --pattern="{" \
                    --string="${dict[pattern]}"
                then
                    # Look for '{aaa,bbb,ccc}' and convert to
                    # '( -name aaa -o -name bbb -o name ccc )'.
                    # Usage of '-O' here refers to array index origin.
                    # This is a really useful way to append an array.
                    readarray -O "${#find_args[@]}" -t find_args <<< "$( \
                        local globs1 globs2 globs3 str
                        readarray -d ',' -t globs1 <<< "$( \
                            koopa_gsub \
                                --pattern='[{}]' \
                                --replacement='' \
                                "${dict[pattern]}" \
                        )"
                        globs2=()
                        for i in "${!globs1[@]}"
                        do
                            globs2+=(
                                "-name ${globs1[i]}"
                            )
                        done
                        str="( $(koopa_paste --sep=' -o ' "${globs2[@]}") )"
                        readarray -d ' ' -t globs3 <<< "$(
                            koopa_print "$str"
                        )"
                        koopa_print "${globs3[@]}"
                    )"
                else
                    find_args+=('-name' "${dict[pattern]}")
                fi
            fi
            if [[ -n "${dict[type]}" ]]
            then
                case "${dict[type]}" in
                    'broken-symlink')
                        find_args+=('-xtype' 'l')
                        ;;
                    'd' | \
                    'f' | \
                    'l')
                        find_args+=('-type' "${dict[type]}")
                        ;;
                    *)
                        koopa_stop 'Invalid file type argument.'
                        ;;
                esac
            fi
            if [[ -n "${dict[days_modified_gt]}" ]]
            then
                find_args+=('-mtime' "+${dict[days_modified_gt]}")
            fi
            if [[ -n "${dict[days_modified_lt]}" ]]
            then
                find_args+=('-mtime' "-${dict[days_modified_lt]}")
            fi
            if [[ "${dict[exclude]}" -eq 1 ]]
            then
                for exclude_arg in "${exclude_arr[@]}"
                do
                    exclude_arg="$( \
                        koopa_sub \
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
            koopa_stop 'Invalid find engine.'
            ;;
    esac
    if [[ "${dict[verbose]}" -eq 1 ]]
    then
        koopa_warn "Find command: ${find[*]} ${find_args[*]}"
    fi
    if [[ "${dict[sort]}" -eq 1 ]]
    then
        app[sort]="$(koopa_locate_sort)"
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
        koopa_is_array_non_empty "${results[@]:-}" || return 1
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
        koopa_is_array_non_empty "${results[@]:-}" || return 1
        if [[ "${dict[sort]}" -eq 1 ]]
        then
            readarray -t sorted_results <<< "$( \
                koopa_print "${results[@]}" | "${app[sort]}" \
            )"
            results=("${sorted_results[@]}")
        fi
        koopa_print "${results[@]}"
    fi
    return 0
}

koopa_find_and_replace_in_file() {
    # """
    # Find and replace inside files.
    # @note Updated 2022-04-22.
    #
    # Parameterized, supporting multiple files.
    #
    # This step requires GNU sed and won't work with BSD sed currently installed
    # by default on macOS.
    #
    # @seealso
    # - koopa_sub
    # - https://stackoverflow.com/questions/4247068/
    # - https://stackoverflow.com/questions/5720385/
    # - https://stackoverflow.com/questions/2922618/
    # - Use '-0' for multiline replacement
    #   https://stackoverflow.com/questions/1030787/
    # - https://unix.stackexchange.com/questions/334216/
    #
    # @usage
    # > koopa_find_and_replace_in_file \
    # >     [--fixed|--regex] \
    # >     --pattern=PATTERN \
    # >     --replacement=REPLACEMENT \
    # >     FILE...
    #
    # @examples
    # > koopa_find_and_replace_in_file \
    # >     --fixed \
    # >     --pattern='XXX' \
    # >     --replacement='YYY' \
    # >     'file1' 'file2' 'file3'
    # """
    local app dict pos
    koopa_assert_has_args "$#"
    declare -A app=(
        [perl]="$(koopa_locate_perl)"
    )
    declare -A dict=(
        [pattern]=''
        [regex]=0
        [replacement]=''
    )
    pos=()
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--pattern='*)
                dict[pattern]="${1#*=}"
                shift 1
                ;;
            '--pattern')
                dict[pattern]="${2:?}"
                shift 2
                ;;
            '--replacement='*)
                dict[replacement]="${1#*=}"
                shift 1
                ;;
            '--replacement')
                # Allowing empty string passthrough here.
                dict[replacement]="${2:-}"
                shift 2
                ;;
            # Flags ------------------------------------------------------------
            '--fixed')
                dict[regex]=0
                shift 1
                ;;
            '--regex')
                dict[regex]=1
                shift 1
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
    koopa_assert_is_set '--pattern' "${dict[pattern]}"
    [[ "${#pos[@]}" -eq 0 ]] && pos=("$(</dev/stdin)")
    set -- "${pos[@]}"
    koopa_assert_has_args "$#"
    koopa_assert_is_file "$@"
    if [[ "${dict[regex]}" -eq 1 ]]
    then
        dict[expr]="s/${dict[pattern]}/${dict[replacement]}/g"
    else
        dict[expr]=" \
            \$pattern = quotemeta '${dict[pattern]}'; \
            \$replacement = '${dict[replacement]}'; \
            s/\$pattern/\$replacement/g; \
        "
    fi
    # Consider using '-0' here for multi-line matching. This makes regular
    # expression matching with line endings more difficult, so disabled.
    "${app[perl]}" -i -p -e "${dict[expr]}" "$@"
    return 0
}

koopa_find_broken_symlinks() {
    # """
    # Find broken symlinks.
    # @note Updated 2022-02-17.
    #
    # Currently requires GNU findutils to be installed.
    # """
    local prefix str
    koopa_assert_has_args "$#"
    koopa_assert_is_dir "$@"
    for prefix in "$@"
    do
        str="$( \
            koopa_find \
                --engine='find' \
                --min-depth=1 \
                --prefix="$prefix" \
                --sort \
                --type='broken-symlink' \
        )"
        [[ -n "$str" ]] || continue
        koopa_print "$str"
    done
    return 0
}

koopa_find_dotfiles() {
    # """
    # Find dotfiles by type.
    # @note Updated 2022-02-17.
    #
    # This is used internally by 'koopa_list_dotfiles' script.
    #
    # 1. Type ('f' file; or 'd' directory).
    # 2. Header message (e.g. 'Files')
    # """
    local app dict
    koopa_assert_has_args_eq "$#" 2
    declare -A app=(
        [awk]="$(koopa_locate_awk)"
        [basename]="$(koopa_locate_basename)"
        [xargs]="$(koopa_locate_xargs)"
    )
    declare -A dict=(
        [type]="${1:?}"
        [header]="${2:?}"
    )
    # shellcheck disable=SC2016
    dict[str]="$( \
        koopa_find \
            --max-depth=1 \
            --pattern='.*' \
            --prefix="${HOME:?}" \
            --print0 \
            --sort \
            --type="${dict[type]}" \
        | "${app[xargs]}" -0 -n 1 "${app[basename]}" \
        | "${app[awk]}" '{print "    -",$0}' \
    )"
    [[ -n "${dict[str]}" ]] || return 1
    koopa_h2 "${dict[header]}:"
    koopa_print "${dict[str]}"
    return 0
}

koopa_find_empty_dirs() {
    # """
    # Find empty directories.
    # @note Updated 2022-02-24.
    # """
    local prefix
    koopa_assert_has_args "$#"
    koopa_assert_is_dir "$@"
    for prefix in "$@"
    do
        local str
        str="$( \
            koopa_find \
                --empty \
                --prefix="$prefix" \
                --sort \
                --type='d' \
        )"
        [[ -n "$str" ]] || continue
        koopa_print "$str"
    done
    return 0
}

koopa_find_files_without_line_ending() {
    # """
    # Find files without line ending.
    # @note Updated 2022-02-16.
    #
    # @seealso
    # - https://stackoverflow.com/questions/4631068/
    # """
    local app files prefix
    koopa_assert_has_args "$#"
    declare -A app=(
        [pcregrep]="$(koopa_locate_pcregrep)"
    )
    koopa_assert_is_dir "$@"
    for prefix in "$@"
    do
        local str
        readarray -t files <<< "$(
            koopa_find \
                --min-depth=1 \
                --prefix="$(koopa_realpath "$prefix")" \
                --sort \
                --type='f' \
        )"
        koopa_is_array_non_empty "${files[@]:-}" || continue
        str="$("${app[pcregrep]}" -LMr '\n$' "${files[@]}")"
        [[ -n "$str" ]] || continue
        koopa_print "$str"
    done
    return 0
}

koopa_find_large_dirs() {
    # """
    # Find large directories.
    # @note Updated 2022-02-16.
    #
    # Results are reverse sorted by size.
    #
    # @examples
    # > koopa_find_large_dirs "${HOME}/monorepo"
    # """
    local app prefix
    koopa_assert_has_args "$#"
    declare -A app=(
        [du]="$(koopa_locate_du)"
        [sort]="$(koopa_locate_sort)"
        [tail]="$(koopa_locate_tail)"
    )
    koopa_assert_is_dir "$@"
    for prefix in "$@"
    do
        local str
        prefix="$(koopa_realpath "$prefix")"
        str="$( \
            "${app[du]}" \
                --max-depth=10 \
                --threshold=100000000 \
                "${prefix}"/* \
                2>/dev/null \
            | "${app[sort]}" --numeric-sort \
            | "${app[tail]}" -n 50 \
            || true \
        )"
        [[ -n "$str" ]] || continue
        koopa_print "$str"
    done
    return 0
}

koopa_find_large_files() {
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
    # > koopa_find_large_files "${HOME}/monorepo"
    # """
    local app prefix str
    koopa_assert_has_args "$#"
    declare -A app=(
        [head]="$(koopa_locate_head)"
    )
    koopa_assert_is_dir "$@"
    for prefix in "$@"
    do
        str="$( \
            koopa_find \
                --min-depth=1 \
                --prefix="$prefix" \
                --size='+100000000c' \
                --sort \
                --type='f' \
            | "${app[head]}" -n 50 \
        )"
        [[ -n "$str" ]] || continue
        koopa_print "$str"
    done
    return 0
}

koopa_find_non_symlinked_make_files() {
    # """
    # Find non-symlinked make files.
    # @note Updated 2022-02-24.
    # """
    local dict find_args
    koopa_assert_has_no_args "$#"
    declare -A dict=(
        [brew_prefix]="$(koopa_homebrew_prefix)"
        [make_prefix]="$(koopa_make_prefix)"
    )
    find_args=(
        '--min-depth' 1
        '--prefix' "${dict[make_prefix]}"
        '--sort'
        '--type' 'f'
    )
    if koopa_is_linux
    then
        find_args+=(
            '--exclude' 'share/applications/**'
            '--exclude' 'share/emacs/site-lisp/**'
            '--exclude' 'share/zsh/site-functions/**'
        )
    elif koopa_is_macos
    then
        find_args+=(
            '--exclude' 'MacGPG2/**'
            '--exclude' 'gfortran/**'
            '--exclude' 'texlive/**'
        )
    fi
    if [[ "${dict[brew_prefix]}" == "${dict[make_prefix]}" ]]
    then
        find_args+=(
            '--exclude' 'Caskroom/**'
            '--exclude' 'Cellar/**'
            '--exclude' 'Homebrew/**'
            '--exclude' 'var/homebrew/**'
        )
    fi
    dict[out]="$(koopa_find "${find_args[@]}")"
    koopa_print "${dict[out]}"
    return 0
}

# NOTE Is there a way to speed this up using GNU find or something?

koopa_find_symlinks() {
    # """
    # Find symlinks matching a specified source prefix.
    # @note Updated 2022-04-01.
    #
    # @examples
    # > koopa_find_symlinks \
    # >     --source-prefix="$(koopa_app_prefix)/python" \
    # >     --target-prefix="$(koopa_make_prefix)"
    # > koopa_find_symlinks \
    # >     --source-prefix="$(koopa_macos_r_prefix)" \
    # >     --target-prefix="$(koopa_koopa_prefix)/bin"
    # """
    local dict hits symlink symlinks
    koopa_assert_has_args "$#"
    declare -A dict=(
        [source_prefix]=''
        [target_prefix]=''
        [verbose]=0
    )
    hits=()
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--source-prefix='*)
                dict[source_prefix]="${1#*=}"
                shift 1
                ;;
            '--source-prefix')
                dict[source_prefix]="${2:?}"
                shift 2
                ;;
            '--target-prefix='*)
                dict[target_prefix]="${1#*=}"
                shift 1
                ;;
            '--target-prefix')
                dict[target_prefix]="${2:?}"
                shift 2
                ;;
            # Flags ------------------------------------------------------------
            '--verbose')
                dict[verbose]=1
                shift 1
                ;;
            # Other ------------------------------------------------------------
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set \
        '--source-prefix' "${dict[source_prefix]}" \
        '--target-prefix' "${dict[target_prefix]}"
    koopa_assert_is_dir "${dict[source_prefix]}" "${dict[target_prefix]}"
    dict[source_prefix]="$(koopa_realpath "${dict[source_prefix]}")"
    dict[target_prefix]="$(koopa_realpath "${dict[target_prefix]}")"
    readarray -t symlinks <<< "$(
        koopa_find \
            --prefix="${dict[target_prefix]}" \
            --sort \
            --type='l' \
    )"
    for symlink in "${symlinks[@]}"
    do
        local symlink_real
        symlink_real="$(koopa_realpath "$symlink")"
        if koopa_str_detect_regex \
            --pattern="^${dict[source_prefix]}/" \
            --string="$symlink_real"
        then
            if [[ "${dict[verbose]}" -eq 1 ]]
            then
                koopa_warn "${symlink} -> ${symlink_real}"
            fi
            hits+=("$symlink")
        fi
    done
    koopa_is_array_empty "${hits[@]}" && return 1
    koopa_print "${hits[@]}"
    return 0
}
