#!/usr/bin/env bash

koopa_cmake_build() {
    # """
    # Perform a standard CMake build.
    # @note Updated 2023-03-31.
    # """
    local app build_deps cmake_args dict pos
    declare -A app dict
    koopa_assert_has_args "$#"
    build_deps=('cmake')
    app['cmake']="$(koopa_locate_cmake)"
    [[ -x "${app['cmake']}" ]] || return 1
    dict['builddir']="builddir-$(koopa_random_string)"
    dict['generator']='Unix Makefiles'
    dict['jobs']="$(koopa_cpu_count)"
    pos=()
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--prefix='*)
                dict['prefix']="${1#*=}"
                shift 1
                ;;
            '--prefix')
                dict['prefix']="${2:?}"
                shift 2
                ;;
            # Flags ------------------------------------------------------------
            '--ninja')
                dict['generator']='Ninja'
                shift 1
                ;;
            # Configuration passthrough support --------------------------------
            '-D'*)
                pos+=("$1")
                shift 1
                ;;
            # Other ------------------------------------------------------------
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    koopa_assert_is_set '--prefix' "${dict['prefix']}"
    readarray -t cmake_args <<< "$(koopa_cmake_std_args "${dict['prefix']}")"
    [[ "$#" -gt 0 ]] && cmake_args+=("$@")
    case "${dict['generator']}" in
        'Ninja')
            build_deps+=('ninja')
            ;;
        'Unix Makefiles')
            build_deps+=('make')
            ;;
        *)
            koopa_stop 'Unsupported generator.'
            ;;
    esac
    koopa_activate_app --build-only "${build_deps[@]}"
    koopa_print_env
    koopa_dl 'CMake args' "${cmake_args[*]}"
    "${app['cmake']}" -LH \
        '-B' "${dict['builddir']}" \
        '-G' "${dict['generator']}" \
        '-S' '.' \
        "${cmake_args[@]}"
    "${app['cmake']}" \
        --build "${dict['builddir']}" \
        --parallel "${dict['jobs']}"
    "${app['cmake']}" --install "${dict['builddir']}"
    return 0
}
