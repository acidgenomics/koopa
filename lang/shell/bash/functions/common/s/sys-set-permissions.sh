#!/usr/bin/env bash

koopa_sys_set_permissions() {
    # """
    # Set permissions on target prefix(es).
    # @note Updated 2022-04-07.
    #
    # Consider ensuring that nested directories are also executable.
    # e.g. 'app/julia-packages/1.6/registries/General'.
    # """
    koopa_assert_has_args "$#"
    local arg chmod_args chown_args dict pos
    declare -A dict=(
        [dereference]=1
        [recursive]=0
        [shared]=1
    )
    chmod_args=()
    chown_args=()
    pos=()
    while (("$#"))
    do
        case "$1" in
            '--dereference' | \
            '-H')
                dict[dereference]=1
                shift 1
                ;;
            '--no-dereference' | \
            '-h')
                dict[dereference]=0
                shift 1
                ;;
            '--recursive' | \
            '-R' | \
            '-r')
                dict[recursive]=1
                shift 1
                ;;
            '--user' | \
            '-u')
                dict[shared]=0
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
    case "${dict[shared]}" in
        '0')
            dict[group]="$(koopa_group)"
            dict[user]="$(koopa_user)"
            ;;
        '1')
            dict[group]="$(koopa_sys_group)"
            dict[user]="$(koopa_sys_user)"
            ;;
    esac
    chown_args+=('--no-dereference')
    if [[ "${dict[recursive]}" -eq 1 ]]
    then
        chmod_args+=('--recursive')
        chown_args+=('--recursive')
    fi
    if koopa_is_shared_install
    then
        chmod_args+=('u+rw,g+rw,o+r,o-w')
    else
        chmod_args+=('u+rw,g+r,g-w,o+r,o-w')
    fi
    chown_args+=("${dict[user]}:${dict[group]}")
    for arg in "$@"
    do
        if [[ "${dict[dereference]}" -eq 1 ]] && [[ -L "$arg" ]]
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
