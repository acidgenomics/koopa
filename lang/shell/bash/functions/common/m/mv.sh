#!/usr/bin/env bash

koopa_mv() {
    # """
    # Move a file or directory with GNU mv.
    # @note Updated 2021-10-29.
    # @note '-t' flag is not supported for BSD variant.
    #
    # This function works on 1 file or directory at a time.
    # It ensures that the target parent directory exists automatically.
    #
    # Useful GNU mv args, for reference (non-POSIX):
    # * '--no-target-directory'
    # * '--strip-trailing-slashes'
    # """
    local app dict mkdir mv mv_args pos rm
    declare -A app=(
        [mkdir]='koopa_mkdir'
        [mv]="$(koopa_locate_mv)"
        [rm]='koopa_rm'
    )
    declare -A dict=(
        [sudo]=0
        [target_dir]=''
    )
    pos=()
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--target-directory='*)
                dict[target_dir]="${1#*=}"
                shift 1
                ;;
            '--target-directory' | \
            '-t')
                dict[target_dir]="${2:?}"
                shift 2
                ;;
            # Flags ------------------------------------------------------------
            '--sudo' | \
            '-S')
                dict[sudo]=1
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
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    koopa_assert_has_args "$#"
    if [[ "${dict[sudo]}" -eq 1 ]]
    then
        app[sudo]="$(koopa_locate_sudo)"
        mkdir=("${app[mkdir]}" '--sudo')
        mv=("${app[sudo]}" "${app[mv]}")
        rm=("${app[rm]}" '--sudo')
    else
        mkdir=("${app[mkdir]}")
        mv=("${app[mv]}")
        rm=("${app[rm]}")
    fi
    mv_args=('-f')
    mv_args+=("$@")
    if [[ -n "${dict[target_dir]}" ]]
    then
        koopa_assert_is_existing "$@"
        dict[target_dir]="$(koopa_strip_trailing_slash "${dict[target_dir]}")"
        if [[ ! -d "${dict[target_dir]}" ]]
        then
            "${mkdir[@]}" "${dict[target_dir]}"
        fi
        mv_args+=("${dict[target_dir]}")
    else
        koopa_assert_has_args_eq "$#" 2
        dict[source_file]="$(koopa_strip_trailing_slash "${1:?}")"
        koopa_assert_is_existing "${dict[source_file]}"
        dict[target_file]="$(koopa_strip_trailing_slash "${2:?}")"
        if [[ -e "${dict[target_file]}" ]]
        then
            "${rm[@]}" "${dict[target_file]}"
        fi
        dict[target_parent]="$(koopa_dirname "${dict[target_file]}")"
        if [[ ! -d "${dict[target_parent]}" ]]
        then
            "${mkdir[@]}" "${dict[target_parent]}"
        fi
    fi
    "${mv[@]}" "${mv_args[@]}"
    return 0
}
