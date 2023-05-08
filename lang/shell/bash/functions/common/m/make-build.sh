#!/usr/bin/env bash

koopa_make_build() {
    # """
    # Build with GNU Make.
    # @note Updated 2023-05-08.
    # """
    local -A app dict
    local -a conf_args
    koopa_assert_has_args "$#"
    if [[ -d "${dict['make']}" ]]
    then
        koopa_activate_app --build-only 'make'
        app['make']="$(koopa_locate_make)"
    else
        app['make']="$(koopa_locate_make --only-system)"
    fi
    koopa_assert_is_executable "${app[@]}"
    dict['jobs']="$(koopa_cpu_count)"
    conf_args+=("$@")
    koopa_print_env
    koopa_dl 'configure args' "${conf_args[*]}"
    koopa_assert_is_executable './configure'
    ./configure --help || true
    ./configure "${conf_args[@]}"
    "${app['make']}" VERBOSE=1 --jobs="${dict['jobs']}"
    "${app['make']}" install
    return 0
}
