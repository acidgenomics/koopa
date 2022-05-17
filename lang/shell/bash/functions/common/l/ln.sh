#!/usr/bin/env bash

koopa_ln() {
    # """
    # Hardened version of coreutils ln (symbolic link generator).
    # @note Updated 2021-10-29.
    # @note '-t' flag is not directly supported for BSD variant.
    # """
    local app dict ln ln_args mkdir pos rm
    declare -A app=(
        [ln]="$(koopa_locate_ln)"
        [mkdir]='koopa_mkdir'
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
        ln=("${app[sudo]}" "${app[ln]}")
        mkdir=("${app[mkdir]}" '--sudo')
        rm=("${app[rm]}" '--sudo')
    else
        ln=("${app[ln]}")
        mkdir=("${app[mkdir]}")
        rm=("${app[rm]}")
    fi
    ln_args=('-fns')
    ln_args+=("$@")
    if [[ -n "${dict[target_dir]}" ]]
    then
        koopa_assert_is_existing "$@"
        dict[target_dir]="$(koopa_strip_trailing_slash "${dict[target_dir]}")"
        if [[ ! -d "${dict[target_dir]}" ]]
        then
            "${mkdir[@]}" "${dict[target_dir]}"
        fi
        ln_args+=("${dict[target_dir]}")
    else
        koopa_assert_has_args_eq "$#" 2
        dict[source_file]="${1:?}"
        koopa_assert_is_existing "${dict[source_file]}"
        dict[target_file]="${2:?}"
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
    "${ln[@]}" "${ln_args[@]}"
    return 0
}
