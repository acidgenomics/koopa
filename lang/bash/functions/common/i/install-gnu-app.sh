#!/usr/bin/env bash

koopa_install_gnu_app() {
    # """
    # Build and install a GNU package from source.
    # @note Updated 2023-08-29.
    #
    # Positional arguments are passed to 'conf_args' array.
    # """
    local -A dict
    local -a conf_args
    koopa_assert_is_install_subshell
    dict['compress_ext']='gz'
    dict['jobs']="$(koopa_cpu_count)"
    dict['mirror']="$(koopa_gnu_mirror_url)"
    dict['name']="${KOOPA_INSTALL_NAME:?}"
    dict['parent_name']=''
    dict['pkg_name']=''
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    conf_args=()
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--compress-ext='*)
                dict['compress_ext']="${1#*=}"
                shift 1
                ;;
            '--compress-ext')
                dict['compress_ext']="${2:?}"
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
            '--mirror='*)
                dict['mirror']="${1#*=}"
                shift 1
                ;;
            '--mirror')
                dict['mirror']="${2:?}"
                shift 2
                ;;
            '--package-name='*)
                dict['pkg_name']="${1#*=}"
                shift 1
                ;;
            '--package-name')
                dict['pkg_name']="${2:?}"
                shift 2
                ;;
            '--parent-name='*)
                dict['parent_name']="${1#*=}"
                shift 1
                ;;
            '--parent-name')
                dict['parent_name']="${2:?}"
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
            '--version='*)
                dict['version']="${1#*=}"
                shift 1
                ;;
            '--version')
                dict['version']="${2:?}"
                shift 2
                ;;
            # Flags ------------------------------------------------------------
            '--non-gnu-mirror')
                # Alternative URLs:
                # - https://download.savannah.gnu.org/releases
                # - https://download.savannah.nongnu.org/releases
                dict['mirror']='https://mirrors.sarata.com/non-gnu'
                shift 1
                ;;
            # Configuration passthrough support --------------------------------
            # Inspired by CMake approach using '-D' prefix.
            '-D')
                conf_args+=("${2:?}")
                shift 2
                ;;
            # Other ------------------------------------------------------------
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    [[ -z "${dict['parent_name']}" ]] && dict['parent_name']="${dict['name']}"
    [[ -z "${dict['pkg_name']}" ]] && dict['pkg_name']="${dict['name']}"
    koopa_assert_is_set \
        '--mirror' "${dict['mirror']}" \
        '--name' "${dict['name']}" \
        '--package-name' "${dict['pkg_name']}" \
        '--parent-name' "${dict['parent_name']}" \
        '--prefix' "${dict['prefix']}" \
        '--version' "${dict['version']}"
    conf_args+=("--prefix=${dict['prefix']}")
    export FORCE_UNSAFE_CONFIGURE=1
    dict['url']="${dict['mirror']}/${dict['parent_name']}/\
${dict['pkg_name']}-${dict['version']}.tar.${dict['compress_ext']}"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    koopa_make_build "${conf_args[@]}"
    return 0
}
