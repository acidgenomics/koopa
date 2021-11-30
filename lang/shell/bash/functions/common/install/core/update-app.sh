#!/usr/bin/env bash

# FIXME Need to rework, looping across opt and homebrew-opt.

koopa::update_app() { # {{{1
    # """
    # Update application.
    # @note Updated 2021-11-29.
    # """
    local clean_path_arr dict pkgs pos
    koopa::assert_has_args "$#"
    koopa::assert_has_no_envs
    declare -A dict=(
        [homebrew_opt]=''
        [name_fancy]=''
        [opt]=''
        [opt_prefix]="$(koopa::opt_prefix)"
        [platform]=''
        [prefix]=''
        [shared]=0
        [system]=0
        [tmp_dir]="$(koopa::tmp_dir)"
        [version]=''
    )
    clean_path_arr=('/usr/bin' '/bin' '/usr/sbin' '/sbin')
    koopa::is_shared_install && dict[shared]=1
    pos=()
    while (("$#"))
    do
        case "$1" in
            '--homebrew-opt='*)
                dict[homebrew_opt]="${1#*=}"
                shift 1
                ;;
            '--homebrew-opt')
                dict[homebrew_opt]="${2:?}"
                shift 2
                ;;
            '--name='*)
                dict[name]="${1#*=}"
                shift 1
                ;;
            '--name')
                dict[name]="${2:?}"
                shift 2
                ;;
            '--name-fancy='*)
                dict[name_fancy]="${1#*=}"
                shift 1
                ;;
            '--name-fancy')
                dict[name_fancy]="${2:?}"
                shift 2
                ;;
            '--opt='*)
                dict[opt]="${1#*=}"
                shift 1
                ;;
            '--opt')
                dict[opt]="${2:?}"
                shift 2
                ;;
            '--platform='*)
                dict[platform]="${1#*=}"
                shift 1
                ;;
            '--platform')
                dict[platform]="${2:?}"
                shift 2
                ;;
            '--prefix='*)
                dict[prefix]="${1#*=}"
                shift 1
                ;;
            '--prefix')
                dict[prefix]="${2:?}"
                shift 2
                ;;
            '--version='*)
                dict[version]="${1#*=}"
                shift 1
                ;;
            '--version')
                dict[version]="${2:?}"
                shift 2
                ;;
            # Flags ------------------------------------------------------------
            '--no-shared')
                dict[shared]=0
                shift 1
                ;;
            '--shared')
                dict[shared]=1
                shift 1
                ;;
            '--system')
                dict[system]=1
                shift 1
                ;;
            '--verbose')
                set -x
                shift 1
                ;;
            # Other ------------------------------------------------------------
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    [[ -z "${dict[name_fancy]}" ]] && dict[name_fancy]="${dict[name]}"
    [[ "${dict[system]}" -eq 1 ]] && dict[shared]=0
    if [[ "${dict[shared]}" -eq 1 ]] || [[ "${dict[system]}" -eq 1 ]]
    then
        koopa::assert_is_admin
    fi
    dict[function]="$(koopa::snake_case_simple "${dict[name]}")"
    dict[function]="update_${dict[function]}"
    if [[ -n "${dict[platform]}" ]]
    then
        dict[function]="${dict[platform]}_${dict[function]}"
    fi
    dict[function]="koopa:::${dict[function]}"
    if ! koopa::is_function "${dict[function]}"
    then
        koopa::stop 'Unsupported command.'
    fi
    if [[ -z "${dict[prefix]}" ]] && [[ "${dict[system]}" -eq 0 ]]
    then
        dict[prefix]="${dict[opt_prefix]}/${dict[name]}"
    fi
    if [[ -n "${dict[prefix]}" ]]
    then
        koopa::alert_update_start "${dict[name_fancy]}" "${dict[prefix]}"
        koopa::assert_is_dir "${dict[prefix]}"
    else
        koopa::alert_update_start "${dict[name_fancy]}"
    fi
    if koopa::is_linux && \
        { [[ "${dict[shared]}" -eq 1 ]] || \
            [[ "${dict[system]}" -eq 1 ]]; }
    then
        koopa::linux_update_ldconfig
    fi
    (
        koopa::cd "${dict[tmp_dir]}"
        unset -v LD_LIBRARY_PATH PKG_CONFIG_PATH
        PATH="$(koopa::paste0 ':' "${clean_path_arr[@]}")"
        export PATH
        if [[ -x '/usr/bin/pkg-config' ]]
        then
            _koopa_add_to_pkg_config_path_start_2 \
                '/usr/bin/pkg-config'
        fi
        if [[ -n "${dict[homebrew_opt]}" ]]
        then
            IFS=',' read -r -a pkgs <<< "${dict[homebrew_opt]}"
            koopa::activate_homebrew_opt_prefix "${pkgs[@]}"
        fi
        if [[ -n "${dict[opt]}" ]]
        then
            IFS=',' read -r -a pkgs <<< "${dict[opt]}"
            koopa::activate_opt_prefix "${pkgs[@]}"
        fi
        # shellcheck disable=SC2030
        export UPDATE_PREFIX="${dict[prefix]}"
        "${dict[function]}" "$@"
    )
    koopa::rm "${dict[tmp_dir]}"
    if [[ -d "${dict[prefix]}" ]] && [[ "${dict[system]}" -eq 0 ]]
    then
        if [[ "${dict[shared]}" -eq 1 ]]
        then
            koopa::sys_set_permissions --recursive "${dict[prefix]}"
        fi
        koopa::delete_empty_dirs "${dict[prefix]}"
    fi
    if koopa::is_linux && \
        { [[ "${dict[shared]}" -eq 1 ]] || \
            [[ "${dict[system]}" -eq 1 ]]; }
    then
        koopa::linux_update_ldconfig
    fi
    if [[ -d "${dict[prefix]}" ]]
    then
        koopa::alert_update_success "${dict[name_fancy]}" "${dict[prefix]}"
    else
        koopa::alert_update_success "${dict[name_fancy]}"
    fi
    return 0
}
