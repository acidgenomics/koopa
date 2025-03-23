#!/usr/bin/env bash

koopa_mv() {
    # """
    # Move a file or directory with GNU mv.
    # @note Updated 2023-12-22.
    #
    # The '-t' flag is not supported for BSD variant.
    #
    # This function works on 1 file or directory at a time.
    # It ensures that the target parent directory exists automatically.
    #
    # Useful GNU mv args, for reference (non-POSIX):
    # * '--no-target-directory'
    # * '--strip-trailing-slashes'
    #
    # """
    local -A app dict
    local -a mkdir mv mv_args pos rm
    app['mv']="$(koopa_locate_mv --allow-system --realpath)"
    # GNU mv currently has issues with NFS shares on macOS.
    koopa_is_macos && app['mv']='/bin/mv'
    koopa_assert_is_executable "${app[@]}"
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
        mkdir=('koopa_mkdir' '--sudo')
        mv=('koopa_sudo' "${app['mv']}")
        rm=('koopa_rm' '--sudo')
    else
        mkdir=('koopa_mkdir')
        mv=("${app['mv']}")
        rm=('koopa_rm')
    fi
    mv_args=('-f')
    [[ "${dict['verbose']}" -eq 1 ]] && mv_args+=('-v')
    mv_args+=("$@")
    if [[ -n "${dict['target_dir']}" ]]
    then
        # NOTE This will error on broken symlinks, so disabling. Ran into this
        # assert check when attempting to install ICU4C 74.2 with broken
        # 'LICENSE' symlink.
        # > koopa_assert_is_existing "$@"
        dict['target_dir']="$( \
            koopa_strip_trailing_slash "${dict['target_dir']}" \
        )"
        if [[ ! -d "${dict['target_dir']}" ]]
        then
            "${mkdir[@]}" "${dict['target_dir']}"
        fi
        mv_args+=("${dict['target_dir']}")
    else
        koopa_assert_has_args_eq "$#" 2
        dict['source_file']="$(koopa_strip_trailing_slash "${1:?}")"
        koopa_assert_is_existing "${dict['source_file']}"
        dict['target_file']="$(koopa_strip_trailing_slash "${2:?}")"
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
    "${mv[@]}" "${mv_args[@]}"
    return 0
}
