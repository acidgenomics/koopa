#!/usr/bin/env bash

koopa_install_app_subshell() {
    # """
    # Install an application in a hardened subshell.
    # @note Updated 2022-09-08.
    # """
    local dict pos
    declare -A dict=(
        ['installer_bn']=''
        ['installer_fun']='main'
        ['koopa_prefix']="$(koopa_koopa_prefix)"
        ['mode']='shared'
        ['name']="${INSTALL_NAME:-}"
        ['platform']='common'
        ['prefix']="${INSTALL_PREFIX:-}"
        ['tmp_dir']="$(koopa_tmp_dir)"
        ['version']="${INSTALL_VERSION:-}"
    )
    pos=()
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--installer='*)
                dict['installer_bn']="${1#*=}"
                shift 1
                ;;
            '--installer')
                dict['installer_bn']="${2:?}"
                shift 2
                ;;
            '--mode='*)
                dict['mode']="${1#*=}"
                shift 1
                ;;
            '--mode')
                dict['mode']="${2:?}"
                shift 2
                ;;
            '--name='*)
                dict['name']="${1#*=}"
                shift 1
                ;;
            '--name')
                dict['name']="${2:?}"
                shift 2
                ;;
            '--platform='*)
                dict['platform']="${1#*=}"
                shift 1
                ;;
            '--platform')
                dict['platform']="${2:?}"
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
            # Internal flags ---------------------------------------------------
            '--system')
                dict['mode']='system'
                shift 1
                ;;
            '--user')
                dict['mode']='user'
                shift 1
                ;;
            # Configuration passthrough support --------------------------------
            # Inspired by CMake approach using '-D' prefix.
            '-D')
                pos+=("${2:?}")
                shift 2
                ;;
            # Other ------------------------------------------------------------
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    [[ -z "${dict['installer_bn']}" ]] && dict['installer_bn']="${dict['name']}"
    dict['installer_file']="${dict['koopa_prefix']}/lang/shell/bash/include/\
install/${dict['platform']}/${dict['mode']}/${dict['installer_bn']}.sh"
    koopa_assert_is_file "${dict['installer_file']}"
    (
        koopa_cd "${dict['tmp_dir']}"
        # shellcheck disable=SC2030
        export INSTALL_NAME="${dict['name']}"
        # shellcheck disable=SC2030
        export INSTALL_PREFIX="${dict['prefix']}"
        # shellcheck disable=SC2030
        export INSTALL_SCRIPT="${dict['installer_file']}"
        # shellcheck disable=SC2030
        export INSTALL_VERSION="${dict['version']}"
        # shellcheck source=/dev/null
        source "${dict['installer_file']}"
        koopa_assert_is_function "${dict['installer_fun']}"
        "${dict['installer_fun']}" "$@"
        case "${dict['mode']}" in
            'shared')
                koopa_alert_info "Environment variables for \
'$(koopa_basename "${dict['installer_file']}")'."
                declare -x
                ;;
            *)
                ;;
        esac
        return 0
    )
    koopa_rm "${dict['tmp_dir']}"
    return 0
}
