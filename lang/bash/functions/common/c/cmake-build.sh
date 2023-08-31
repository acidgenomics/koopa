#!/usr/bin/env bash

# FIXME Ensure that we don't build inside the src directory...
# Need to build a level up from the input...rethink this.

koopa_cmake_build() {
    # """
    # Perform a standard CMake build.
    # @note Updated 2023-08-31.
    # """
    local -A app dict
    local -a build_deps cmake_args cmake_std_args pos
    koopa_assert_has_args "$#"
    build_deps=('cmake')
    app['cmake']="$(koopa_locate_cmake)"
    koopa_assert_is_executable "${app[@]}"
    dict['bin_dir']=''
    dict['build_dir']="build-$(koopa_random_string)"
    dict['generator']='Unix Makefiles'
    dict['include_dir']=''
    dict['jobs']="$(koopa_cpu_count)"
    dict['lib_dir']=''
    dict['prefix']=''
    cmake_std_args=()
    pos=()
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--bin-dir='*)
                dict['bin_dir']="${1#*=}"
                shift 1
                ;;
            '--bin-dir')
                dict['bin_dir']="${2:?}"
                shift 2
                ;;
            '--include-dir='*)
                dict['include_dir']="${1#*=}"
                shift 1
                ;;
            '--include-dir')
                dict['include_dir']="${2:?}"
                shift 2
                ;;
            '--jobs='*)
                dict['jobs']="${1#*=}"
                shift 1
                ;;
            '--jobs')
                dict['jobs']="${2:?}"
                shift 2
                ;;
            '--lib-dir='*)
                dict['lib_dir']="${1#*=}"
                shift 1
                ;;
            '--lib-dir')
                dict['lib_dir']="${2:?}"
                shift 2
                ;;
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
    cmake_std_args+=("--prefix=${dict['prefix']}")
    [[ -n "${dict['bin_dir']}" ]] && \
        cmake_std_args+=("--bin-dir=${dict['bin_dir']}")
    [[ -n "${dict['include_dir']}" ]] && \
        cmake_std_args+=("--include-dir=${dict['include_dir']}")
    [[ -n "${dict['lib_dir']}" ]] && \
        cmake_std_args+=("--lib-dir=${dict['lib_dir']}")
    readarray -t cmake_args <<< "$(koopa_cmake_std_args "${cmake_std_args[@]}")"
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
        '-B' "${dict['build_dir']}" \
        '-G' "${dict['generator']}" \
        '-S' '.' \
        "${cmake_args[@]}"
    "${app['cmake']}" \
        --build "${dict['build_dir']}" \
        --parallel "${dict['jobs']}"
    "${app['cmake']}" \
        --install "${dict['build_dir']}" \
        --prefix "${dict['prefix']}"
    return 0
}
