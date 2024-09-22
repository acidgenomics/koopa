#!/usr/bin/env bash

koopa_mkdir() {
    # """
    # Create directories with parents automatically.
    # @note Updated 2024-09-22.
    # """
    local -A app dict
    local -a mkdir mkdir_args pos
    app['mkdir']="$(koopa_locate_mkdir --allow-system --realpath)"
    dict['sudo']=0
    dict['verbose']=0
    pos=()
    while (("$#"))
    do
        case "$1" in
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
    mkdir_args=('-p')
    [[ "${dict['verbose']}" -eq 1 ]] && mkdir_args+=('-v')
    if [[ "${dict['sudo']}" -eq 1 ]]
    then
        mkdir=('koopa_sudo' "${app['mkdir']}")
    else
        mkdir=("${app['mkdir']}")
    fi
    koopa_assert_is_executable "${app[@]}"
    "${mkdir[@]}" "${mkdir_args[@]}" "$@"
    return 0
}
