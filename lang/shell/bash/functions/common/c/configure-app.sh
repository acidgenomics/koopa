#!/usr/bin/env bash

# FIXME Ensure that '/usr/sbin' and '/sbin' are in PATH for system config.

koopa_configure_app() {
    # """
    # Configure an application (inside a subshell).
    # @note Updated 2023-05-14.
    # """
    local -A bool dict
    local -a pos
    koopa_assert_is_owner
    bool['verbose']=0
    dict['config_fun']='main'
    dict['koopa_prefix']="$(koopa_koopa_prefix)"
    dict['mode']='shared'
    dict['name']=''
    dict['platform']='common'
    pos=()
    while (("$#"))
    do
        case "$1" in
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
            # CLI-accessible flags ---------------------------------------------
            '--verbose')
                bool['verbose']=1
                shift 1
                ;;
            # Flags ------------------------------------------------------------
            '--system')
                dict['mode']='system'
                shift 1
                ;;
            '--user')
                dict['mode']='user'
                shift 1
                ;;
            # Other ------------------------------------------------------------
            '-*')
                koopa_invalid_arg "$1"
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    koopa_assert_is_set '--name' "${dict['name']}"
    if [[ "${bool['verbose']}" -eq 1 ]]
    then
        export KOOPA_VERBOSE=1
        set -o xtrace
    fi
    case "${dict['mode']}" in
        'system')
            koopa_assert_is_admin
            ;;
    esac
    dict['config_file']="${dict['koopa_prefix']}/lang/shell/bash/include/\
configure/${dict['platform']}/${dict['mode']}/${dict['name']}.sh"
    # > koopa_alert "Configuring '${dict['name']}'."
    koopa_assert_is_file "${dict['config_file']}"
    dict['tmp_dir']="$(koopa_tmp_dir)"
    (
        koopa_cd "${dict['tmp_dir']}"
        # shellcheck source=/dev/null
        source "${dict['config_file']}"
        koopa_assert_is_function "${dict['config_fun']}"
        "${dict['config_fun']}" "$@"
    )
    koopa_rm "${dict['tmp_dir']}"
    # > koopa_alert_success "Configuration of '${dict['name']}' was successful."
    return 0
}
