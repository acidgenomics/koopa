#!/usr/bin/env bash

# FIXME Intercept --target argument.

koopa_make_build() {
    # """
    # Build with GNU Make.
    # @note Updated 2023-05-08.
    # """
    local -A app dict
    local -a conf_args pos targets
    local target
    koopa_assert_has_args "$#"
    dict['make']="$(koopa_app_prefix 'make' --allow-missing)"
    if [[ -d "${dict['make']}" ]]
    then
        koopa_activate_app --build-only 'make'
        app['make']="$(koopa_locate_make)"
    else
        app['make']="$(koopa_locate_make --only-system)"
    fi
    koopa_assert_is_executable "${app[@]}"
    dict['jobs']="$(koopa_cpu_count)"
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--target='*)
                targets+=("${1#*=}")
                shift 1
                ;;
            '--target')
                targets+=("${2:?}")
                shift 2
                ;;
            # Other ------------------------------------------------------------
            *)
                pos+=("$1")
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    koopa_is_array_empty "${targets[@]}" && targets+=('install')
    conf_args+=("$@")
    koopa_print_env
    koopa_dl 'configure args' "${conf_args[*]}"
    koopa_assert_is_executable './configure'
    ./configure --help || true
    ./configure "${conf_args[@]}"
    "${app['make']}" VERBOSE=1 --jobs="${dict['jobs']}"
    for target in "${targets[@]}"
    do
        "${app['make']}" "$target"
    done
    return 0
}
