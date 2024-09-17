#!/usr/bin/env bash

koopa_make_build() {
    # """
    # Build with GNU Make.
    # @note Updated 2024-09-17.
    # """
    local -A app dict
    local -a conf_args pos targets
    local target
    koopa_assert_has_args "$#"
    case "${KOOPA_INSTALL_NAME:?}" in
        'aws-cli')
            # Handle edge-case aws-cli bootstrap.
            app['make']="$(koopa_locate_make --allow-system)"
            ;;
        'make')
            app['make']="$(koopa_locate_make --only-system)"
            ;;
        *)
            # > koopa_activate_app --build-only 'make'
            app['make']="$(koopa_locate_make)"
            ;;
    esac
    koopa_assert_is_executable "${app[@]}"
    dict['jobs']="$(koopa_cpu_count)"
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--jobs='*)
                dict['jobs']="${1#*=}"
                shift 1
                ;;
            '--jobs')
                dict['jobs']="${2:?}"
                shift 2
                ;;
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
                shift 1
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    # Alternatively, can use '${arr[@]+"${arr[@]}"}' idiom here to support
    # Bash 4.2, which is common on some legacy HPC systems.
    # https://stackoverflow.com/questions/7577052
    if koopa_is_array_empty "${targets[@]:-}"
    then
        targets+=('install')
    fi
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
