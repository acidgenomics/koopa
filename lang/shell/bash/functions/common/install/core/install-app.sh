#!/usr/bin/env bash

# FIXME Add support for '--system', similar to update function.
# FIXME Migrate tee, tmp_dir, and temp_log_file into arrays.

koopa:::install_app() { # {{{1
    # """
    # Install application into a versioned directory structure.
    # @note Updated 2021-10-05.
    #
    # The 'dict' array approach has the benefit of avoiding passing unwanted
    # local variables to the internal installer function call below.
    # """
    local arr conf_bak dict link_args pkgs pos rm str tee
    koopa::assert_has_args "$#"
    koopa::assert_has_no_envs
    declare -A conf_bak=(
        [LD_LIBRARY_PATH]="${LD_LIBRARY_PATH:-}"
        [PATH]="${PATH:-}"
        [PKG_CONFIG_PATH]="${PKG_CONFIG_PATH:-}"
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
        [version]=''
    )
    koopa::is_shared_install && dict[shared]=1
    tee="$(koopa::locate_tee)"
    pos=()
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
    if [[ "${dict[shared]}" -eq 1 ]]
    then
        koopa::assert_is_admin
    else
        dict[link_app]=0
    fi
    if koopa::is_macos
    then
        dict[link_app]=0
    fi
    if [[ -z "${dict[installer]}" ]]
    then
        dict[installer]="${dict[name]}"
    fi
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
    if [[ -z "${dict[name_fancy]}" ]]
    then
        dict[name_fancy]="${dict[name]}"
    fi
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
            koopa::alert_note "Removing previous install at '${dict[prefix]}'."
            if [[ "${dict[shared]}" -eq 1 ]]
            then
                rm='koopa::sys_rm'
            else
                rm='koopa::rm'
            fi
            "$rm" "${dict[prefix]}"
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
    # Ensure configuration is minimal before proceeding, when desirable.
    unset -v LD_LIBRARY_PATH
    # Ensure clean minimal 'PATH'.
    arr=('/usr/bin' '/bin' '/usr/sbin' '/sbin')
    str="$(koopa::paste0 ':' "${arr[@]}")"
    PATH="$str"
    export PATH
    # Ensure clean minimal 'PKG_CONFIG_PATH'.
    unset -v PKG_CONFIG_PATH
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
    if [[ "${dict[shared]}" -eq 1 ]] && koopa::is_linux
    then
        koopa::update_ldconfig
    fi
    dict[tmp_dir]="$(koopa::tmp_dir)"
    (
        koopa::cd "${dict[tmp_dir]}"
        # shellcheck disable=SC2030
        export INSTALL_LINK_APP="${dict[link_app]}"
        # shellcheck disable=SC2030
        export INSTALL_NAME="${dict[name]}"
        # shellcheck disable=SC2030
        export INSTALL_PREFIX="${dict[prefix]}"
        # shellcheck disable=SC2030
        export INSTALL_VERSION="${dict[version]}"
        "${dict[function]}" "$@"
    ) 2>&1 | "$tee" "$(koopa::tmp_log_file)"
    koopa::rm "${dict[tmp_dir]}"
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
        # Including the 'true' catch here to avoid 'cp' issues on Arch Linux.
        koopa::link_app "${link_args[@]}" || true
    elif [[ "${dict[auto_prefix]}" -eq 1 ]]
    then
        koopa::link_into_opt "${dict[prefix]}" "${dict[name]}"
    fi
    # Reset global variables, if applicable.
    if [[ -n "${conf_bak[LD_LIBRARY_PATH]}" ]]
    then
        LD_LIBRARY_PATH="${conf_bak[LD_LIBRARY_PATH]}"
        export LD_LIBRARY_PATH
    fi
    if [[ -n "${conf_bak[PATH]}" ]]
    then
        PATH="${conf_bak[PATH]}"
        export PATH
    fi
    if [[ -n "${conf_bak[PKG_CONFIG_PATH]}" ]]
    then
        PKG_CONFIG_PATH="${conf_bak[PKG_CONFIG_PATH]}"
        export PKG_CONFIG_PATH
    fi
    if [[ "${dict[shared]}" -eq 1 ]] && koopa::is_linux
    then
        koopa::update_ldconfig
    fi
    koopa::install_success "${dict[name_fancy]}" "${dict[prefix]}"
    return 0
}
