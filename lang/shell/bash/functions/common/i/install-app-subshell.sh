#!/usr/bin/env bash

koopa_install_app_subshell() {
    # """
    # Install an application in a hardened subshell.
    # @note Updated 2022-09-06.
    # """
    local app bool dict pos
    declare -A app=(
        ['tee']="$(koopa_locate_tee --allow-system)"
    )
    [[ -x "${app['tee']}" ]] || return 1
    declare -A bool=(
        ['copy_log_file']=0
    )
    declare -A dict=(
        ['installer_bn']=''
        ['installer_fun']='main'
        ['koopa_prefix']="$(koopa_koopa_prefix)"
        ['log_file']="$(koopa_tmp_log_file)"
        ['tmp_dir']="$(koopa_tmp_dir)"
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
            # Other ------------------------------------------------------------
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    [[ -z "${dict['installer_bn']}" ]] && dict['installer_bn']="${dict['name']}"
    dict['installer_file']="${dict['koopa_prefix']}/lang/shell/bash/include/\
install/${dict['platform']}/${dict['mode']}/${dict['installer_bn']}.sh"
    koopa_assert_is_file "${dict['installer_file']}"
    if [[ -d "${dict['prefix']}" ]] && [[ "${dict['mode']}" != 'system' ]]
    then
        bool['copy_log_file']=1
    fi
    (
        koopa_cd "${dict['tmp_dir']}"
        PATH='/usr/bin:/bin'
        export PATH
        if koopa_is_linux && [[ -x '/usr/bin/pkg-config' ]]
        then
            koopa_activate_pkg_config '/usr/bin/pkg-config'
        fi
        # shellcheck disable=SC2030
        export INSTALL_NAME="${dict['name']}"
        # shellcheck disable=SC2030
        export INSTALL_PREFIX="${dict['prefix']}"
        # shellcheck disable=SC2030
        export INSTALL_VERSION="${dict['version']}"
        # shellcheck source=/dev/null
        source "${dict['installer_file']}"
        koopa_assert_is_function "${dict['installer_fun']}"
        "${dict['installer_fun']}" "$@"
        case "${dict['mode']}" in
            'shared')
                declare -x
                ;;
            *)
                ;;
        esac
        return 0
    ) 2>&1 | "${app['tee']}" "${dict['log_file']}"
    if [[ "${bool['copy_log_file']}" -eq 1 ]]
    then
        koopa_cp \
            "${dict['log_file']}" \
            "${dict['prefix']}/.koopa-install.log"
    fi
    koopa_rm "${dict['tmp_dir']}"
    return 0
}
