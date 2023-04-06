#!/usr/bin/env bash

koopa_find() {
    # """
    # Find files using Rust fd (faster) or GNU findutils (slower).
    # @note Updated 2023-04-06.
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
    local -A app dict
    local -a exclude_arr find find_args results sorted_results
    local exclude_arg
    dict['days_modified_gt']=''
    dict['days_modified_lt']=''
    dict['empty']=0
    dict['engine']="${KOOPA_FIND_ENGINE:-}"
    dict['exclude']=0
    dict['max_depth']=''
    dict['min_depth']=1
    dict['pattern']=''
    dict['print0']=0
    dict['size']=''
    dict['sort']=0
    dict['sudo']=0
    dict['type']=''
    dict['verbose']=0
    exclude_arr=()
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--days-modified-before='*)
                dict['days_modified_gt']="${1#*=}"
                shift 1
                ;;
            '--days-modified-before')
                dict['days_modified_gt']="${2:?}"
                shift 2
                ;;
            '--days-modified-within='*)
                dict['days_modified_lt']="${1#*=}"
                shift 1
                ;;
            '--days-modified-within')
                dict['days_modified_lt']="${2:?}"
                shift 2
                ;;
            '--engine='*)
                dict['engine']="${1#*=}"
                shift 1
                ;;
            '--engine')
                dict['engine']="${2:?}"
                shift 2
                ;;
            '--exclude='*)
                dict['exclude']=1
                exclude_arr+=("${1#*=}")
                shift 1
                ;;
            '--exclude')
                dict['exclude']=1
                exclude_arr+=("${2:?}")
                shift 2
                ;;
            '--max-depth='*)
                dict['max_depth']="${1#*=}"
                shift 1
                ;;
            '--max-depth')
                dict['max_depth']="${2:?}"
                shift 2
                ;;
            '--min-depth='*)
                dict['min_depth']="${1#*=}"
                shift 1
                ;;
            '--min-depth')
                dict['min_depth']="${2:?}"
                shift 2
                ;;
            '--pattern='*)
                dict['pattern']="${1#*=}"
                shift 1
                ;;
            '--pattern')
                dict['pattern']="${2:?}"
                shift 2
                ;;
            '--prefix='*)
                dict['prefix']="${1#*=}"
                shift 1
                ;;
            '--prefix')
                dict['prefix']="${2:?}"
                shift 2
                ;;
            '--size='*)
                dict['size']="${1#*=}"
                shift 1
                ;;
            '--size')
                dict['size']="${2:?}"
                shift 2
                ;;
            '--type='*)
                dict['type']="${1#*=}"
                shift 1
                ;;
            '--type')
                dict['type']="${2:?}"
                shift 2
                ;;
            # Flags ------------------------------------------------------------
            '--empty')
                dict['empty']=1
                shift 1
                ;;
            '--print0')
                dict['print0']=1
                shift 1
                ;;
            '--sort')
                dict['sort']=1
                shift 1
                ;;
            '--sudo')
                dict['sudo']=1
                shift 1
                ;;
            '--verbose')
                dict['verbose']=1
                shift 1
                ;;
            # Other ------------------------------------------------------------
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_dir "${dict['prefix']}"
    dict['prefix']="$(koopa_realpath "${dict['prefix']}")"
    case "${dict['engine']}" in
        '')
            app['find']="$(koopa_locate_fd --allow-missing)"
            [[ -x "${app['find']}" ]] && dict['engine']='fd'
            if [[ -z "${dict['engine']}" ]]
            then
                dict['engine']='find'
                app['find']="$(koopa_locate_find --allow-system)"
            fi
            ;;
        'fd')
            app['find']="$(koopa_locate_fd)"
            ;;
        'find')
            app['find']="$(koopa_locate_find --allow-system)"
            ;;
    esac
    find=()
    if [[ "${dict['sudo']}" -eq 1 ]]
    then
        app['sudo']="$(koopa_locate_sudo)"
        find+=("${app['sudo']}")
    fi
    find+=("${app['find']}")
    case "${dict['engine']}" in
        'fd')
            find_args=(
                # Don't use '--full-path' here.
                '--absolute-path'
                '--base-directory' "${dict['prefix']}"
                '--case-sensitive'
                '--glob'
                '--hidden'
                '--no-follow'
                '--no-ignore'
                '--one-file-system'
            )
            if [[ -n "${dict['min_depth']}" ]]
            then
                find_args+=('--min-depth' "${dict['min_depth']}")
            fi
            if [[ -n "${dict['max_depth']}" ]]
            then
                find_args+=('--max-depth' "${dict['max_depth']}")
            fi
            if [[ -n "${dict['type']}" ]]
            then
                case "${dict['type']}" in
                    'd')
                        dict['type']='directory'
                        ;;
                    'f')
                        dict['type']='file'
                        ;;
                    'l')
                        dict['type']='symlink'
                        ;;
                    *)
                        koopa_stop 'Invalid type argument for Rust fd.'
                        ;;
                esac
                find_args+=('--type' "${dict['type']}")
            fi
            if [[ "${dict['empty']}" -eq 1 ]]
            then
                # This is additive with other '--type' calls.
                find_args+=('--type' 'empty')
            fi
            if [[ -n "${dict['days_modified_gt']}" ]]
            then
                find_args+=(
                    '--changed-before'
                    "${dict['days_modified_gt']}d"
                )
            fi
            if [[ -n "${dict['days_modified_lt']}" ]]
            then
                find_args+=(
                    '--changed-within'
                    "${dict['days_modified_lt']}d"
                )
            fi
            if [[ "${dict['exclude']}" -eq 1 ]]
            then
                for exclude_arg in "${exclude_arr[@]}"
                do
                    find_args+=('--exclude' "$exclude_arg")
                done
            fi
            if [[ -n "${dict['size']}" ]]
            then
                # Convert GNU find 'c' for bytes into 'b' convention here.
                dict['size']="$( \
                    koopa_sub \
                        --pattern='c$' \
                        --replacement='b' \
                        "${dict['size']}" \
                )"
                find_args+=('--size' "${dict['size']}")
            fi
            if [[ "${dict['print0']}" -eq 1 ]]
            then
                find_args+=('--print0')
            fi
            if [[ -n "${dict['pattern']}" ]]
            then
                find_args+=("${dict['pattern']}")
            fi
            ;;
        'find')
            find_args=(
                "${dict['prefix']}"
                '-xdev'
            )
            if [[ -n "${dict['min_depth']}" ]]
            then
                find_args+=('-mindepth' "${dict['min_depth']}")
            fi
            if [[ -n "${dict['max_depth']}" ]]
            then
                find_args+=('-maxdepth' "${dict['max_depth']}")
            fi
            if [[ -n "${dict['pattern']}" ]]
            then
                if koopa_str_detect_fixed \
                    --pattern="{" \
                    --string="${dict['pattern']}"
                then
                    # Look for '{aaa,bbb,ccc}' and convert to
                    # '( -name aaa -o -name bbb -o name ccc )'.
                    # Usage of '-O' here refers to array index origin.
                    # This is a really useful way to append an array.
                    readarray -O "${#find_args[@]}" -t find_args <<< "$( \
                        local -a globs1 globs2 globs3
                        local str
                        readarray -d ',' -t globs1 <<< "$( \
                            koopa_gsub \
                                --pattern='[{}]' \
                                --replacement='' \
                                "${dict['pattern']}" \
                        )"
                        globs2=()
                        for i in "${!globs1[@]}"
                        do
                            globs2+=(
                                "-name ${globs1[$i]}"
                            )
                        done
                        str="( $(koopa_paste --sep=' -o ' "${globs2[@]}") )"
                        readarray -d ' ' -t globs3 <<< "$(
                            koopa_print "$str"
                        )"
                        koopa_print "${globs3[@]}"
                    )"
                else
                    find_args+=('-name' "${dict['pattern']}")
                fi
            fi
            if [[ -n "${dict['type']}" ]]
            then
                case "${dict['type']}" in
                    'broken-symlink')
                        find_args+=('-xtype' 'l')
                        ;;
                    'd' | \
                    'f' | \
                    'l')
                        find_args+=('-type' "${dict['type']}")
                        ;;
                    *)
                        koopa_stop 'Invalid file type argument.'
                        ;;
                esac
            fi
            if [[ -n "${dict['days_modified_gt']}" ]]
            then
                find_args+=('-mtime' "+${dict['days_modified_gt']}")
            fi
            if [[ -n "${dict['days_modified_lt']}" ]]
            then
                find_args+=('-mtime' "-${dict['days_modified_lt']}")
            fi
            if [[ "${dict['exclude']}" -eq 1 ]]
            then
                for exclude_arg in "${exclude_arr[@]}"
                do
                    exclude_arg="$( \
                        koopa_sub \
                            --pattern='^' \
                            --replacement="${dict['prefix']}/" \
                            "$exclude_arg" \
                    )"
                    find_args+=('-not' '-path' "$exclude_arg")
                done
            fi
            if [[ "${dict['empty']}" -eq 1 ]]
            then
                find_args+=('-empty')
            fi
            if [[ -n "${dict['size']}" ]]
            then
                find_args+=('-size' "${dict['size']}")
            fi
            if [[ "${dict['print0']}" -eq 1 ]]
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
    if [[ "${dict['verbose']}" -eq 1 ]]
    then
        koopa_warn "Find command: ${find[*]} ${find_args[*]}"
    fi
    if [[ "${dict['sort']}" -eq 1 ]]
    then
        app['sort']="$(koopa_locate_sort --allow-system)"
    fi
    koopa_assert_is_executable "${app[@]}"
    if [[ "${dict['print0']}" -eq 1 ]]
    then
        # NULL-byte ('\0') approach (non-POSIX).
        # Bash complains about NULL butes when assigned to variables
        # (e.g. via '<<<' with readarray), but NULL bytes at process
        # substitution (e.g. '< <' with readarray) are handled correctly.
        readarray -t -d '' results < <( \
            "${find[@]}" "${find_args[@]}" 2>/dev/null \
        )
        koopa_is_array_non_empty "${results[@]:-}" || return 1
        if [[ "${dict['sort']}" -eq 1 ]]
        then
            readarray -t -d '' sorted_results < <( \
                printf '%s\0' "${results[@]}" | "${app['sort']}" -z \
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
        if [[ "${dict['sort']}" -eq 1 ]]
        then
            readarray -t sorted_results <<< "$( \
                koopa_print "${results[@]}" | "${app['sort']}" \
            )"
            results=("${sorted_results[@]}")
        fi
        koopa_print "${results[@]}"
    fi
    return 0
}
