#!/usr/bin/env bash

_koopa_ln() {
    # """
    # Hardened version of coreutils ln (symbolic link generator).
    # @note Updated 2023-04-06.
    #
    # Note that '-t' flag is not directly supported for BSD variant.
    # """
    local -A app dict
    local -a ln ln_args mkdir pos rm
    app['ln']="$(_koopa_locate_ln --allow-system --realpath)"
    dict['sudo']=0
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
            '--verbose' | \
            '-v')
                dict['verbose']=1
                shift 1
                ;;
            # Other ------------------------------------------------------------
            '-'*)
                _koopa_invalid_arg "$1"
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    _koopa_assert_has_args "$#"
    if [[ "${dict['sudo']}" -eq 1 ]]
    then
        ln=('_koopa_sudo' "${app['ln']}")
        mkdir=('_koopa_mkdir' '--sudo')
        rm=('_koopa_rm' '--sudo')
    else
        ln=("${app['ln']}")
        mkdir=('_koopa_mkdir')
        rm=('_koopa_rm')
    fi
    ln_args=('-f' '-n' '-s')
    [[ "${dict['verbose']}" -eq 1 ]] && ln_args+=('-v')
    ln_args+=("$@")
    if [[ -n "${dict['target_dir']}" ]]
    then
        _koopa_assert_is_existing "$@"
        dict['target_dir']="$( \
            _koopa_strip_trailing_slash "${dict['target_dir']}" \
        )"
        if [[ ! -d "${dict['target_dir']}" ]]
        then
            "${mkdir[@]}" "${dict['target_dir']}"
        fi
        ln_args+=("${dict['target_dir']}")
    else
        _koopa_assert_has_args_eq "$#" 2
        dict['source_file']="${1:?}"
        _koopa_assert_is_existing "${dict['source_file']}"
        dict['target_file']="${2:?}"
        if [[ -e "${dict['target_file']}" ]]
        then
            "${rm[@]}" "${dict['target_file']}"
        fi
        dict['target_parent']="$(_koopa_dirname "${dict['target_file']}")"
        if [[ ! -d "${dict['target_parent']}" ]]
        then
            "${mkdir[@]}" "${dict['target_parent']}"
        fi
    fi
    _koopa_assert_is_executable "${app[@]}"
    "${ln[@]}" "${ln_args[@]}"
    return 0
}
