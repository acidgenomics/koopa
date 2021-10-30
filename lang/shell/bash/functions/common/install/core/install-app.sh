#!/usr/bin/env bash
# shellcheck disable=SC2030,SC2031

koopa:::install_app() { # {{{1
    # """
    # Install application into a versioned directory structure.
    # @note Updated 2021-10-30.
    # """
    local app clean_path_arr dict link_args pkgs
    koopa::assert_has_args "$#"
    koopa::assert_has_no_envs
    declare -A app=(
        [tee]="$(koopa::locate_tee)"
    )
    clean_path_arr=(
        '/usr/bin'
        '/bin'
        '/usr/sbin'
        '/sbin'
    )
    declare -A dict=(
        [auto_prefix]=1
        [homebrew_opt]=''
        [installer]=''
        [link_app]=1
        [link_include_dirs]=''
        [make_prefix]="$(koopa::make_prefix)"
        [name_fancy]=''
        [opt]=''
        [platform]=''
        [prefix]=''
        [prefix_check]=1
        [reinstall]=0
        [shared]=0
        [system]=0
        [tmp_dir]="$(koopa::tmp_dir)"
        [tmp_log_file]="$(koopa::tmp_log_file)"
        [version]=''
    )
    koopa::is_shared_install && dict[shared]=1
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--homebrew-opt='*)
                dict[homebrew_opt]="${1#*=}"
                shift 1
                ;;
            '--homebrew-opt')
                dict[homebrew_opt]="${2:?}"
                shift 2
                ;;
            '--installer='*)
                dict[installer]="${1#*=}"
                shift 1
                ;;
            '--installer')
                dict[installer]="${2:?}"
                shift 2
                ;;
            '--link-include-dirs='*)
                dict[link_include_dirs]="${1#*=}"
                shift 1
                ;;
            '--link-include-dirs')
                dict[link_include_dirs]="${2:?}"
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
            '--force' | \
            '--reinstall')
                dict[reinstall]=1
                shift 1
                ;;
            '--link')
                dict[link_app]=1
                shift 1
                ;;
            '--no-link')
                dict[link_app]=0
                shift 1
                ;;
            '--no-prefix-check')
                dict[prefix_check]=0
                shift 1
                ;;
            '--no-shared')
                dict[shared]=0
                shift 1
                ;;
            '--prefix-check')
                dict[prefix_check]=1
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
                koopa::invalid_arg "$1"
                ;;
        esac
    done
    [[ -z "${dict[name_fancy]}" ]] && dict[name_fancy]="${dict[name]}"
    [[ "${dict[system]}" -eq 1 ]] && dict[shared]=0
    if [[ "${dict[shared]}" -eq 1 ]] || [[ "${dict[system]}" -eq 1 ]]
    then
        koopa::assert_is_admin
    fi
    if [[ "${dict[shared]}" -eq 0 ]] || koopa::is_macos
    then
        dict[link_app]=0
    fi
    [[ -z "${dict[installer]}" ]] && dict[installer]="${dict[name]}"
    dict[function]="$(koopa::snake_case_simple "${dict[installer]}")"
    dict[function]="install_${dict[function]}"
    if [[ -n "${dict[platform]}" ]]
    then
        dict[function]="${dict[platform]}_${dict[function]}"
    fi
    dict[function]="koopa:::${dict[function]}"
    if ! koopa::is_function "${dict[function]}"
    then
        koopa::stop 'Unsupported command.'
    fi
    if [[ "${dict[system]}" -eq 1 ]]
    then
        koopa::install_start "${dict[name_fancy]}"
    else
        if [[ -z "${dict[version]}" ]]
        then
            dict[version]="$(koopa::variable "${dict[name]}")"
        fi
        if [[ -z "${dict[prefix]}" ]]
        then
            dict[prefix]="$(koopa::app_prefix)/${dict[name]}/${dict[version]}"
        else
            dict[auto_prefix]=0
            dict[link_app]=0
        fi
        if [[ -d "${dict[prefix]}" ]] && [[ "${dict[prefix_check]}" -eq 1 ]]
        then
            dict[prefix]="$(koopa::realpath "${dict[prefix]}")"
            if [[ "${dict[reinstall]}" -eq 1 ]]
            then
                koopa::alert "Removing previous install at '${dict[prefix]}'."
                if [[ "${dict[shared]}" -eq 1 ]]
                then
                    app[rm]='koopa::sys_rm'
                else
                    app[rm]='koopa::rm'
                fi
                "${app[rm]}" "${dict[prefix]}"
            fi
            if [[ -d "${dict[prefix]}" ]]
            then
                koopa::alert_note "${dict[name_fancy]} is already installed \
at '${dict[prefix]}'."
                return 0
            fi
        else
            dict[prefix]="$(koopa::init_dir "${dict[prefix]}")"
        fi
        if koopa::str_match_fixed "${dict[prefix]}" "${HOME:?}"
        then
            dict[shared]=0
        fi
        koopa::install_start "${dict[name_fancy]}" "${dict[prefix]}"
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
        # Activate packages installed in Homebrew 'opt/' directory.
        if [[ -n "${dict[homebrew_opt]}" ]]
        then
            IFS=',' read -r -a pkgs <<< "${dict[homebrew_opt]}"
            koopa::activate_homebrew_opt_prefix "${pkgs[@]}"
        fi
        # Activate packages installed in Koopa 'opt/' directory.
        if [[ -n "${dict[opt]}" ]]
        then
            IFS=',' read -r -a pkgs <<< "${dict[opt]}"
            koopa::activate_opt_prefix "${pkgs[@]}"
        fi
        if koopa::is_linux && \
            { [[ "${dict[shared]}" -eq 1 ]] || \
                [[ "${dict[system]}" -eq 1 ]]; }
        then
            koopa::update_ldconfig
        fi
        if [[ "${dict[system]}" -eq 1 ]]
        then
            # shellcheck disable=SC2030
            export INSTALL_VERSION="${dict[version]:-}"
        else
            # shellcheck disable=SC2030
            export INSTALL_LINK_APP="${dict[link_app]}"
            # shellcheck disable=SC2030
            export INSTALL_NAME="${dict[name]}"
            # shellcheck disable=SC2030
            export INSTALL_PREFIX="${dict[prefix]}"
            # shellcheck disable=SC2030
            export INSTALL_VERSION="${dict[version]}"
        fi
        "${dict[function]}"
    ) 2>&1 | "${app[tee]}" "${dict[tmp_log_file]}"
    koopa::rm "${dict[tmp_dir]}"
    if [[ "${dict[system]}" -eq 0 ]]
    then
        if [[ "${dict[shared]}" -eq 1 ]]
        then
            if [[ "${dict[auto_prefix]}" -eq 1 ]]
            then
                koopa::sys_set_permissions "$(koopa::dirname "${dict[prefix]}")"
            fi
            koopa::sys_set_permissions --recursive "${dict[prefix]}"
        else
            koopa::sys_set_permissions --recursive --user "${dict[prefix]}"
        fi
        koopa::delete_empty_dirs "${dict[prefix]}"
        if [[ "${dict[link_app]}" -eq 1 ]]
        then
            koopa::delete_broken_symlinks "${dict[make_prefix]}"
            link_args=(
                "--name=${dict[name]}"
                "--version=${dict[version]}"
            )
            if [[ -n "${dict[link_include_dirs]}" ]]
            then
                link_args+=("--include-dirs=${dict[link_include_dirs]}")
            fi
            # Including the 'true' catch here to avoid 'cp' issues on Arch.
            koopa::link_app "${link_args[@]}" || true
        elif [[ "${dict[auto_prefix]}" -eq 1 ]]
        then
            koopa::link_into_opt "${dict[prefix]}" "${dict[name]}"
        fi
    fi
    if koopa::is_linux && \
        { [[ "${dict[shared]}" -eq 1 ]] || \
            [[ "${dict[system]}" -eq 1 ]]; }
    then
        koopa::update_ldconfig
    fi
    if [[ "${dict[system]}" -eq 1 ]]
    then
        koopa::install_success "${dict[name_fancy]}"
    else
        koopa::install_success "${dict[name_fancy]}" "${dict[prefix]}"
    fi
    return 0
}
