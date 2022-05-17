#!/usr/bin/env bash

koopa_cp() {
    # """
    # Hardened version of coreutils cp (copy).
    # @note Updated 2022-01-19.
    # @note '-t' flag is not directly supported for BSD variant.
    #
    # @seealso
    # - GNU cp man:
    #   https://man7.org/linux/man-pages/man1/cp.1.html
    # - BSD cp man:
    #   https://www.freebsd.org/cgi/man.cgi?cp
    #
    # getopts info:
    # - http://mywiki.wooledge.org/BashFAQ/035#getopts
    # - https://wiki.bash-hackers.org/howto/getopts_tutorial
    # """
    local app cp cp_args dict mkdir pos rm
    declare -A app=(
        [cp]="$(koopa_locate_cp)"
        [mkdir]='koopa_mkdir'
        [rm]='koopa_rm'
    )
    declare -A dict=(
        [sudo]=0
        [symlink]=0
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
            '--symbolic-link' | \
            '--symlink' | \
            '-s')
                dict[symlink]=1
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
        cp=("${app[sudo]}" "${app[cp]}")
        mkdir=("${app[mkdir]}" '--sudo')
        rm=("${app[rm]}" '--sudo')
    else
        cp=("${app[cp]}")
        mkdir=("${app[mkdir]}")
        rm=("${app[rm]}")
    fi
    cp_args=('-af')
    [[ "${dict[symlink]}" -eq 1 ]] && cp_args+=('-s')
    cp_args+=("$@")
    if [[ -n "${dict[target_dir]}" ]]
    then
        koopa_assert_is_existing "$@"
        dict[target_dir]="$(koopa_strip_trailing_slash "${dict[target_dir]}")"
        if [[ ! -d "${dict[target_dir]}" ]]
        then
            "${mkdir[@]}" "${dict[target_dir]}"
        fi
        cp_args+=("${dict[target_dir]}")
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
    "${cp[@]}" "${cp_args[@]}"
    return 0
}
