#!/usr/bin/env bash

koopa_sys_set_permissions() {
    # """
    # Set permissions on target prefix(es).
    # @note Updated 2023-10-06.
    #
    # Consider ensuring that nested directories are also executable.
    # e.g. 'app/julia-packages/1.6/registries/General'.
    # """
    local -A bool
    local -a chmod_args chown_args pos
    local arg
    koopa_assert_has_args "$#"
    bool['dereference']=1
    bool['recursive']=0
    bool['shared']=1
    bool['sudo']=0
    chmod_args=()
    chown_args=()
    pos=()
    while (("$#"))
    do
        case "$1" in
            '--dereference' | \
            '-H')
                bool['dereference']=1
                shift 1
                ;;
            '--no-dereference' | \
            '-h')
                bool['dereference']=0
                shift 1
                ;;
            '--recursive' | \
            '-R' | \
            '-r')
                bool['recursive']=1
                shift 1
                ;;
            '--sudo' | \
            '-S')
                bool['sudo']=1
                shift 1
                ;;
            '--user' | \
            '-u')
                bool['shared']=0
                shift 1
                ;;
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
    case "${bool['shared']}" in
        '0')
            bool['group']="$(koopa_group_name)"
            bool['user']="$(koopa_user_name)"
            ;;
        '1')
            bool['group']="$(koopa_sys_group_name)"
            bool['user']="$(koopa_sys_user_name)"
            ;;
    esac
    chown_args+=('--no-dereference')
    if [[ "${bool['recursive']}" -eq 1 ]]
    then
        chmod_args+=('--recursive')
        chown_args+=('--recursive')
    fi
    if [[ "${bool['sudo']}" -eq 1 ]]
    then
        chmod_args+=('--sudo')
        chown_args+=('--sudo')
    fi
    if koopa_is_shared_install
    then
        chmod_args+=('u+rw,g+rw,o+r,o-w')
    else
        chmod_args+=('u+rw,g+r,g-w,o+r,o-w')
    fi
    chown_args+=("${bool['user']}:${bool['group']}")
    for arg in "$@"
    do
        if [[ "${bool['dereference']}" -eq 1 ]] && [[ -L "$arg" ]]
        then
            arg="$(koopa_realpath "$arg")"
        fi
        chmod_args+=("$arg")
        chown_args+=("$arg")
        koopa_chmod "${chmod_args[@]}"
        koopa_chown "${chown_args[@]}"
    done
    return 0
}
