#!/usr/bin/env bash

koopa_configure_app_packages() { # {{{1
    # """
    # Configure language application.
    # @note Updated 2022-02-09.
    # """
    local dict
    declare -A dict=(
        [link_app]=1
        [name]=''
        [name_fancy]=''
        [prefix]=''
        [version]=''
        [which_app]=''
    )
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
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
            '--which-app='*)
                dict[which_app]="${1#*=}"
                shift 1
                ;;
            '--which-app')
                dict[which_app]="${2:?}"
                shift 2
                ;;
            # Flags ------------------------------------------------------------
            '--link')
                dict[link_app]=1
                shift 1
                ;;
            '--no-link')
                dict[link_app]=0
                shift 1
                ;;
            # Other ------------------------------------------------------------
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    if [[ -z "${dict[name_fancy]}" ]]
    then
        dict[name_fancy]="${dict[name]}"
    fi
    dict[pkg_prefix_fun]="koopa_${dict[name]}_packages_prefix"
    koopa_assert_is_function "${dict[pkg_prefix_fun]}"
    if [[ -z "${dict[prefix]}" ]]
    then
        if [[ -z "${dict[version]}" ]]
        then
            dict[version]="$(koopa_get_version "${dict[which_app]}")"
        fi
        dict[prefix]="$("${dict[pkg_prefix_fun]}" "${dict[version]}")"
    fi
    koopa_alert_configure_start "${dict[name_fancy]}" "${dict[prefix]}"
    if [[ ! -d "${dict[prefix]}" ]]
    then
        koopa_sys_mkdir "${dict[prefix]}"
        koopa_sys_set_permissions "$(koopa_dirname "${dict[prefix]}")"
    fi
    if [[ "${dict[link_app]}" -eq 1 ]]
    then
        koopa_link_app_into_opt "${dict[prefix]}" "${dict[name]}-packages"
    fi
    koopa_alert_configure_success "${dict[name_fancy]}" "${dict[prefix]}"
    return 0
}

koopa_find_app_version() { # {{{1
    # """
    # Find the latest application version.
    # @note Updated 2021-11-11.
    # """
    local app dict
    koopa_assert_has_args_eq "$#" 1
    declare -A app=(
        [sort]="$(koopa_locate_sort)"
        [tail]="$(koopa_locate_tail)"
    )
    declare -A dict=(
        [app_prefix]="$(koopa_app_prefix)"
        [name]="${1:?}"
    )
    dict[prefix]="${dict[app_prefix]}/${dict[name]}"
    koopa_assert_is_dir "${dict[prefix]}"
    dict[hit]="$( \
        koopa_find \
            --max-depth=1 \
            --min-depth=1 \
            --prefix="${dict[prefix]}" \
            --type='d' \
        | "${app[sort]}" \
        | "${app[tail]}" --lines=1 \
    )"
    [[ -d "${dict[hit]}" ]] || return 1
    dict[hit_bn]="$(koopa_basename "${dict[hit]}")"
    koopa_print "${dict[hit_bn]}"
    return 0
}

koopa_install_app() { # {{{1
    # """
    # Install application into a versioned directory structure.
    # @note Updated 2022-03-17.
    # """
    local clean_path_arr dict homebrew_opt_arr init_dir link_args link_include
    local link_include_arr opt_arr pos
    koopa_assert_has_args "$#"
    koopa_assert_has_no_envs
    declare -A dict=(
        # When enabled, this will change permissions on the top level directory
        # of the automatically generated prefix.
        [auto_prefix]=1
        [installer]=''
        [installers_prefix]="$(koopa_installers_prefix)"
        [koopa_prefix]="$(koopa_koopa_prefix)"
        [link_app]=1
        [link_opt]=1
        [make_prefix]="$(koopa_make_prefix)"
        [name]=''
        [name_fancy]=''
        [platform]='common'
        [prefix]=''
        # This override is useful for app packages configuration.
        [prefix_check]=1
        # This is useful for avoiding duplicate alert messages inside of
        # nested install calls (e.g. Emacs installer handoff to GNU app).
        [quiet]=0
        [reinstall]=0
        [shared]=0
        [system]=0
        [tmp_dir]="$(koopa_tmp_dir)"
        [version]=''
        [version_key]=''
    )
    clean_path_arr=('/usr/bin' '/bin' '/usr/sbin' '/sbin')
    homebrew_opt_arr=()
    link_include_arr=()
    opt_arr=()
    pos=()
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--homebrew-opt='*)
                homebrew_opt_arr+=("${1#*=}")
                shift 1
                ;;
            '--homebrew-opt')
                homebrew_opt_arr+=("${2:?}")
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
                link_include_arr+=("${1#*=}")
                shift 1
                ;;
            '--link-include')
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
                opt_arr+=("${1#*=}")
                shift 1
                ;;
            '--opt')
                opt_arr+=("${2:?}")
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
            '--version-key='*)
                dict[version_key]="${1#*=}"
                shift 1
                ;;
            '--version-key')
                dict[version_key]="${2:?}"
                shift 2
                ;;
            # Flags ------------------------------------------------------------
            '--link')
                dict[link_app]=1
                shift 1
                ;;
            '--no-link')
                dict[link_app]=0
                shift 1
                ;;
            '--no-link-opt')
                dict[link_opt]=0
                shift 1
                ;;
            '--no-prefix-check')
                dict[prefix_check]=0
                shift 1
                ;;
            '--prefix-check')
                dict[prefix_check]=1
                shift 1
                ;;
            '--quiet')
                dict[quiet]=1
                shift 1
                ;;
            '--reinstall')
                dict[reinstall]=1
                shift 1
                ;;
            '--system')
                dict[system]=1
                shift 1
                ;;
            '--verbose')
                set -o xtrace
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
    koopa_assert_is_set '--name' "${dict[name]}"
    [[ -z "${dict[name_fancy]}" ]] && dict[name_fancy]="${dict[name]}"
    [[ -z "${dict[version_key]}" ]] && dict[version_key]="${dict[name]}"
    if [[ -n "${dict[prefix]}" ]]
    then
        dict[auto_prefix]=0
        if [[ -d "${dict[prefix]}" ]]
        then
            dict[prefix]="$(koopa_realpath "${dict[prefix]}")"
        fi
        if koopa_str_detect_regex \
            --string="${dict[prefix]}" \
            --pattern="^${dict[koopa_prefix]}"
        then
            dict[shared]=1
        else
            dict[shared]=0
        fi
    else
        dict[auto_prefix]=1
        if koopa_is_shared_install
        then
            dict[shared]=1
        else
            dict[shared]=0
        fi
    fi
    if [[ "${dict[system]}" -eq 1 ]]
    then
        dict[auto_prefix]=0
        dict[shared]=0
    fi
    if [[ "${dict[shared]}" -eq 1 ]] || [[ "${dict[system]}" -eq 1 ]]
    then
        koopa_assert_is_admin
    fi
    if [[ "${dict[shared]}" -eq 0 ]] || koopa_is_macos
    then
        dict[link_app]=0
    fi
    [[ -z "${dict[installer]}" ]] && dict[installer]="${dict[name]}"
    dict[installer]="$(koopa_snake_case_simple "install_${dict[installer]}")"
    dict[installer_file]="$(koopa_kebab_case_simple "${dict[installer]}")"
    dict[installer_file]="${dict[installers_prefix]}/\
${dict[platform]}/${dict[installer_file]}.sh"
    koopa_assert_is_file "${dict[installer_file]}"
    # shellcheck source=/dev/null
    source "${dict[installer_file]}"
    dict[function]="$(koopa_snake_case_simple "${dict[installer]}")"
    if [[ "${dict[platform]}" != 'common' ]]
    then
        dict[function]="${dict[platform]}_${dict[function]}"
    fi
    dict[function]="${dict[function]}"
    koopa_assert_is_function "${dict[function]}"
    if [[ -z "${dict[version]}" ]]
    then
        dict[version]="$(\
            koopa_variable "${dict[version_key]}" \
                2>/dev/null \
                || true \
        )"
    fi
    if [[ -z "${dict[prefix]}" ]] && [[ "${dict[auto_prefix]}" -eq 1 ]]
    then
        dict[prefix]="$(koopa_app_prefix)/${dict[name]}/${dict[version]}"
    fi
    if [[ -n "${dict[prefix]}" ]]
    then
        if [[ "${dict[quiet]}" -eq 0 ]]
        then
            koopa_alert_install_start "${dict[name_fancy]}" "${dict[prefix]}"
        fi
        if [[ -d "${dict[prefix]}" ]] && [[ "${dict[prefix_check]}" -eq 1 ]]
        then
            if [[ "${dict[reinstall]}" -eq 1 ]] || \
                koopa_is_empty_dir "${dict[prefix]}"
            then
                if [[ "${dict[system]}" -eq 1 ]]
                then
                    koopa_rm --sudo "${dict[prefix]}"
                elif [[ "${dict[shared]}" -eq 1 ]]
                then
                    koopa_sys_rm "${dict[prefix]}"
                else
                    koopa_rm "${dict[prefix]}"
                fi
            fi
            if [[ -d "${dict[prefix]}" ]]
            then
                if [[ "${dict[quiet]}" -eq 0 ]]
                then
                    koopa_alert_is_installed \
                        "${dict[name_fancy]}" "${dict[prefix]}"
                fi
                return 0
            fi
        fi
        init_dir=('koopa_init_dir')
        [[ "${dict[system]}" -eq 1 ]] && init_dir+=('--sudo')
        dict[prefix]="$("${init_dir[@]}" "${dict[prefix]}")"
    else
        if [[ "${dict[quiet]}" -eq 0 ]]
        then
            koopa_alert_install_start "${dict[name_fancy]}"
        fi
    fi
    if [[ -d "${dict[prefix]}" ]] && \
        [[ "${dict[link_opt]}" -eq 1 ]] && \
        [[ "${dict[auto_prefix]}" -eq 1 ]] && \
        [[ "${dict[shared]}" -eq 1 ]] && \
        [[ "${dict[system]}" -eq 0 ]]
    then
        koopa_link_app_into_opt "${dict[prefix]}" "${dict[name]}"
    fi
    (
        koopa_cd "${dict[tmp_dir]}"
        unset -v LD_LIBRARY_PATH PKG_CONFIG_PATH
        PATH="$(koopa_paste --sep=':' "${clean_path_arr[@]}")"
        export PATH
        if [[ -x '/usr/bin/pkg-config' ]]
        then
            koopa_add_to_pkg_config_path_start_2 \
                '/usr/bin/pkg-config'
        fi
        # Activate packages installed in Homebrew 'opt/' directory.
        if koopa_is_array_non_empty "${homebrew_opt_arr[@]:-}"
        then
            koopa_activate_homebrew_opt_prefix "${homebrew_opt_arr[@]}"
        fi
        # Activate packages installed in Koopa 'opt/' directory.
        if koopa_is_array_non_empty "${opt_arr[@]:-}"
        then
            koopa_activate_opt_prefix "${opt_arr[@]}"
        fi
        if koopa_is_linux && \
            { [[ "${dict[shared]}" -eq 1 ]] || \
                [[ "${dict[system]}" -eq 1 ]]; }
        then
            koopa_linux_update_ldconfig
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
    )
    koopa_rm "${dict[tmp_dir]}"
    if [[ "${dict[system]}" -eq 0 ]]
    then
        if [[ "${dict[shared]}" -eq 1 ]]
        then
            if [[ "${dict[auto_prefix]}" -eq 1 ]]
            then
                koopa_sys_set_permissions "$(koopa_dirname "${dict[prefix]}")"
            fi
            koopa_sys_set_permissions --recursive "${dict[prefix]}"
        else
            koopa_sys_set_permissions --recursive --user "${dict[prefix]}"
        fi
        # > koopa_delete_empty_dirs "${dict[prefix]}"
        if [[ "${dict[link_app]}" -eq 1 ]]
        then
            koopa_delete_broken_symlinks "${dict[make_prefix]}"
            link_args=(
                "--name=${dict[name]}"
                "--version=${dict[version]}"
            )
            if koopa_is_array_non_empty "${link_include_arr[@]:-}"
            then
                for link_include in "${link_include_arr[@]}"
                do
                    link_args+=("--include=${link_include}")
                done
            fi
            # Including the 'true' catch here to avoid 'cp' issues on Arch.
            koopa_link_app "${link_args[@]}" || true
        fi
    fi
    if koopa_is_linux && \
        { [[ "${dict[shared]}" -eq 1 ]] || \
            [[ "${dict[system]}" -eq 1 ]]; }
    then
        koopa_linux_update_ldconfig
    fi
    if [[ "${dict[quiet]}" -eq 0 ]]
    then
        if [[ -d "${dict[prefix]}" ]]
        then
            koopa_alert_install_success "${dict[name_fancy]}" "${dict[prefix]}"
        else
            koopa_alert_install_success "${dict[name_fancy]}"
        fi

    fi
    return 0
}

koopa_install_app_packages() { # {{{1
    # """
    # Install application packages.
    # @note Updated 2022-02-03.
    # """
    local name name_fancy pos
    koopa_assert_has_args "$#"
    declare -A dict=(
        [name]=''
        [name_fancy]=''
        [reinstall]=0
    )
    pos=()
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
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
            # Flags ------------------------------------------------------------
            '--reinstall')
                dict[reinstall]=1
                shift 1
                ;;
            # Internally defined arguments -------------------------------------
            '--prefix='* | \
            '--prefix' | \
            '--version='* | \
            '--version' | \
            '--link' | \
            '--no-link' | \
            '--no-prefix-check' | \
            '--prefix-check')
                koopa_invalid_arg "$1"
                ;;
            # Other ------------------------------------------------------------
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    koopa_assert_is_set '--name' "${dict[name]}"
    # Configure the language.
    dict[configure_fun]="koopa_configure_${dict[name]}"
    "${dict[configure_fun]}"
    koopa_assert_is_function "${dict[configure_fun]}"
    # Detect the linked package prefix, defined in 'opt'.
    dict[prefix_fun]="koopa_${dict[name]}_packages_prefix"
    koopa_assert_is_function "${dict[prefix_fun]}"
    dict[prefix]="$("${dict[prefix_fun]}")"
    if [[ -d "${dict[prefix]}" ]]
    then
        dict[prefix]="$(koopa_realpath "${dict[prefix]}")"
    fi
    if [[ "${dict[reinstall]}" -eq 1 ]]
    then
        koopa_sys_rm "${dict[prefix]}"
    fi
    koopa_install_app \
        --name-fancy="${dict[name_fancy]} packages" \
        --name="${dict[name]}-packages" \
        --no-link \
        --no-prefix-check \
        --prefix="${dict[prefix]}" \
        --version='rolling' \
        "$@"
    return 0
}

koopa_push_app_build() { # {{{1
    # """
    # Create a tarball of app build, and push to S3 bucket.
    # @note Updated 2022-03-28.
    #
    # @examples
    # > koopa_push_app_build --app-name='node' --app-version='17.8.0'
    # """
    local app dict
    koopa_assert_has_args "$#"
    declare -A app=(
        [aws]="$(koopa_locate_aws)"
        [tar]="$(koopa_locate_tar)"
    )
    declare -A dict=(
        [app_name]=''
        [app_prefix]="$(koopa_app_prefix)"
        [app_version]=''
        [os_string]="$(koopa_os_string)"
        [s3_prefix]='s3://koopa.acidgenomics.com/app'
        [s3_profile]='acidgenomics'
        [tmp_dir]="$(koopa_tmp_dir)"
    )
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--app-name='*)
                dict[app_name]="${1#*=}"
                shift 1
                ;;
            '--app-name')
                dict[app_name]="${2:?}"
                shift 2
                ;;
            '--app-version='*)
                dict[app_version]="${1#*=}"
                shift 1
                ;;
            '--app-version')
                dict[app_version]="${2:?}"
                shift 2
                ;;
            # Other ------------------------------------------------------------
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set \
        '--app-name' "${dict[app_name]}" \
        '--app-version' "${dict[app_version]}"
    dict[prefix]="${dict[app_prefix]}/${dict[app_name]}/${dict[app_version]}"
    dict[local_tarball]="${dict[tmp_dir]}/${dict[app_version]}.tar.gz"
    dict[remote_tarball]="${dict[s3_prefix]}/${dict[os_string]}/\
${dict[app_name]}/${dict[app_version]}.tar.gz"
    koopa_alert "Pushing '${dict[local_tarball]}' to ${dict[remote_tarball]}'."
    "${app[tar]}" -czvf "${dict[local_tarball]}" "${dict[prefix]}/"
    "${app[aws]}" --profile="${dict[s3_profile]}" \
        s3 cp "${dict[local_tarball]}" "${dict[remote_tarball]}"
    return 0
}

koopa_reinstall_app() { # {{{1
    # """
    # Reinstall an application (alias).
    # @note Updated 2022-01-21.
    # """
    koopa_assert_has_args "$#"
    koopa_koopa install "$@" --reinstall
}
