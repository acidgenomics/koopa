#!/usr/bin/env bash
# shellcheck disable=SC2030,SC2031

# FIXME Need to rethink our auto-prefix and auto-version approach here.
# FIXME Need to rework '--link-include' array support here.

koopa:::install_app() { # {{{1
    # """
    # Install application into a versioned directory structure.
    # @note Updated 2021-11-16.
    # """
    local app clean_path_arr dict init_dir link_args
    local link_include link_include_arr pkgs pos
    koopa::assert_has_args "$#"
    koopa::assert_has_no_envs
    declare -A app=(
        [tee]="$(koopa::locate_tee)"
    )
    declare -A dict=(
        # When enabled, this will change permissions on the top level directory
        # of the automatically generated prefix.
        [auto_prefix]=1
        [auto_version]=1
        [homebrew_opt]=''
        [installer]=''
        [link_app]=0
        [make_prefix]="$(koopa::make_prefix)"
        [name_fancy]=''
        [opt]=''
        [platform]=''
        [prefix]=''
        # This override is useful for app packages configuration.
        [prefix_check]=1
        [reinstall]=0
        [shared]=0
        [system]=0
        [tmp_dir]="$(koopa::tmp_dir)"
        [tmp_log_file]="$(koopa::tmp_log_file)"
        [version]=''
    )
    clean_path_arr=('/usr/bin' '/bin' '/usr/sbin' '/sbin')
    link_include_arr=()
    koopa::is_shared_install && dict[shared]=1
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
            '--link-include='*)
                echo 'FIXME HELLO THERE'
                link_include_arr+=("${1#*=}")
                shift 1
                ;;
            '--link-include')
                echo 'FIXME HELLO THERE'
                link_include_arr+=("${2:?}")
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
            '--no-version')
                dict[auto_version]=0
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
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    [[ -z "${dict[name_fancy]}" ]] && dict[name_fancy]="${dict[name]}"
    if [[ "${dict[system]}" -eq 1 ]]
    then
        dict[auto_prefix]=0
        dict[shared]=0
    fi
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
    if [[ -z "${dict[version]}" ]] && [[ "${dict[auto_version]}" -eq 1 ]]
    then
        dict[version]="$(koopa::variable "${dict[name]}")"
    fi
    if [[ -z "${dict[prefix]}" ]] && [[ "${dict[auto_prefix]}" -eq 1 ]]
    then
        dict[prefix]="$(koopa::app_prefix)/${dict[name]}/${dict[version]}"
    fi
    if [[ -n "${dict[prefix]}" ]]
    then
        koopa::install_start "${dict[name_fancy]}" "${dict[prefix]}"
        if koopa::str_match_fixed "${dict[prefix]}" "${HOME:?}"
        then
            dict[shared]=0
        fi
        if [[ -d "${dict[prefix]}" ]] && [[ "${dict[prefix_check]}" -eq 1 ]]
        then
            dict[prefix]="$(koopa::realpath "${dict[prefix]}")"
            if [[ "${dict[reinstall]}" -eq 1 ]]
            then
                koopa::alert "Removing previous install at '${dict[prefix]}'."
                if [[ "${dict[system]}" -eq 1 ]]
                then
                    koopa::rm --sudo "${dict[prefix]}"
                elif [[ "${dict[shared]}" -eq 1 ]]
                then
                    koopa::sys_rm "${dict[prefix]}"
                else
                    koopa::rm "${dict[prefix]}"
                fi
            fi
            if [[ -d "${dict[prefix]}" ]]
            then
                koopa::alert_note "${dict[name_fancy]} is already installed \
at '${dict[prefix]}'."
                return 0
            fi
        fi
        init_dir=('koopa::init_dir')
        [[ "${dict[system]}" -eq 1 ]] && init_dir+=('--sudo')
        dict[prefix]="$("${init_dir[@]}" "${dict[prefix]}")"
    else
        koopa::install_start "${dict[name_fancy]}"
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
            koopa::linux_update_ldconfig
        fi
        # shellcheck disable=SC2030
        export INSTALL_LINK_APP="${dict[link_app]}"
        # shellcheck disable=SC2030
        export INSTALL_NAME="${dict[name]}"
        # shellcheck disable=SC2030
        export INSTALL_PREFIX="${dict[prefix]}"
        # shellcheck disable=SC2030
        export INSTALL_VERSION="${dict[version]}"
        "${dict[function]}" "$@"
    ) 2>&1 | "${app[tee]}" "${dict[tmp_log_file]}"
    koopa::rm "${dict[tmp_dir]}"
    echo 'FIXME A'
    if [[ "${dict[system]}" -eq 0 ]]
    then
        echo 'FIXME B'
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
        echo 'FIXME C'
        if [[ "${dict[link_app]}" -eq 1 ]]
        then
            echo 'FIXME D'
            koopa::delete_broken_symlinks "${dict[make_prefix]}"
            link_args=(
                "--name=${dict[name]}"
                "--version=${dict[version]}"
            )
            if koopa::is_array_non_empty "${link_include_arr[@]:-}"
            then
                echo 'FIXME E'
                for link_include in "${link_include_arr[@]}"
                do
                    link_args+=("--include=${link_include}")
                done
            fi
            # Including the 'true' catch here to avoid 'cp' issues on Arch.
            koopa::link_app "${link_args[@]}" || true
        elif [[ "${dict[auto_prefix]}" -eq 1 ]]
        then
            echo 'FIXME F'
            koopa::link_into_opt "${dict[prefix]}" "${dict[name]}"
        fi
    fi
    if koopa::is_linux && \
        { [[ "${dict[shared]}" -eq 1 ]] || \
            [[ "${dict[system]}" -eq 1 ]]; }
    then
        koopa::linux_update_ldconfig
    fi
    if [[ -d "${dict[prefix]}" ]]
    then
        koopa::install_success "${dict[name_fancy]}" "${dict[prefix]}"
    else
        koopa::install_success "${dict[name_fancy]}"
    fi
    return 0
}
