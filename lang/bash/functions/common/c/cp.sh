#!/usr/bin/env bash

koopa_cp() {
    # """
    # Hardened version of coreutils cp (copy).
    # @note Updated 2023-05-01.
    #
    # Note that '-t' flag is not directly supported for BSD variant.
    #
    # @seealso
    # - GNU cp man:
    #   https://man7.org/linux/man-pages/man1/cp.1.html
    # - BSD cp man:
    #   https://www.freebsd.org/cgi/man.cgi?cp
    # getopts info:
    # - http://mywiki.wooledge.org/BashFAQ/035#getopts
    # - https://wiki.bash-hackers.org/howto/getopts_tutorial
    # """
    local -A app dict
    local -a cp cp_args mkdir pos rm
    app['cp']="$(koopa_locate_cp --allow-system --realpath)"
    dict['sudo']=0
    dict['symlink']=0
    dict['target_dir']=''
    dict['verbose']=0
    pos=()
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--target-directory='*)
                dict['target_dir']="${1#*=}"
                shift 1
                ;;
            '--target-directory' | \
            '-t')
                dict['target_dir']="${2:?}"
                shift 2
                ;;
            # Flags ------------------------------------------------------------
            '--quiet' | \
            '-q')
                dict['verbose']=0
                shift 1
                ;;
            '--sudo' | \
            '-S')
                dict['sudo']=1
                shift 1
                ;;
            '--symbolic-link' | \
            '--symlink' | \
            '-s')
                dict['symlink']=1
                shift 1
                ;;
            '--verbose' | \
            '-v')
                dict['verbose']=1
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
    if [[ "${dict['sudo']}" -eq 1 ]]
    then
        cp=('koopa_sudo' "${app['cp']}")
        mkdir=('koopa_mkdir' '--sudo')
        rm=('koopa_rm' '--sudo')
    else
        cp=("${app['cp']}")
        mkdir=('koopa_mkdir')
        rm=('koopa_rm')
    fi
    cp_args=(
        # > '-a'
        '-f'
        '-r'
    )
    [[ "${dict['symlink']}" -eq 1 ]] && cp_args+=('-s')
    [[ "${dict['verbose']}" -eq 1 ]] && cp_args+=('-v')
    cp_args+=("$@")
    if [[ -n "${dict['target_dir']}" ]]
    then
        koopa_assert_is_existing "$@"
        dict['target_dir']="$( \
            koopa_strip_trailing_slash "${dict['target_dir']}" \
        )"
        if [[ ! -d "${dict['target_dir']}" ]]
        then
            "${mkdir[@]}" "${dict['target_dir']}"
        fi
        cp_args+=("${dict['target_dir']}")
    else
        koopa_assert_has_args_eq "$#" 2
        dict['source_file']="${1:?}"
        koopa_assert_is_existing "${dict['source_file']}"
        dict['target_file']="${2:?}"
        if [[ -e "${dict['target_file']}" ]]
        then
            "${rm[@]}" "${dict['target_file']}"
        fi
        dict['target_parent']="$(koopa_dirname "${dict['target_file']}")"
        if [[ ! -d "${dict['target_parent']}" ]]
        then
            "${mkdir[@]}" "${dict['target_parent']}"
        fi
    fi
    koopa_assert_is_executable "${app[@]}"
    "${cp[@]}" "${cp_args[@]}"
    return 0
}
