#!/usr/bin/env bash

koopa_configure_app_packages() { # {{{1
    # """
    # Configure language application.
    # @note Updated 2022-04-06.
    #
    # @examples
    # > koopa_configure_app_packages \
    # >     --app='/opt/koopa/app/python/3.10.3/bin/python3'
    # >     --name-fancy='Python' \
    # >     --name='python'
    # > koopa_configure_app_packages \
    # >     --name-fancy='Python' \
    # >     --name='python' \
    # >     --version='3.10.3'
    # > koopa_configure_app_packages \
    # >     --name-fancy='Python3' \
    # >     --name='python' \
    # >     --prefix='/opt/koopa/app/python-packages/3.10'
    # """
    local dict pos
    koopa_assert_has_args "$#"
    declare -A dict=(
        [app]=''
        [link_in_opt]=1
        [name]=''
        [name_fancy]=''
        [prefix]=''
        [version]=''
    )
    pos=()
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--app='*)
                dict[app]="${1#*=}"
                shift 1
                ;;
            '--app')
                dict[app]="${2:?}"
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
            '--link-in-opt')
                dict[link_in_opt]=1
                shift 1
                ;;
            '--no-link-in-opt')
                dict[link_in_opt]=0
                shift 1
                ;;
            # Other ------------------------------------------------------------
            '-'*)
                koopa_invalid_arg "$1"
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    if [[ "$#" -gt 0 ]]
    then
        koopa_assert_has_args_eq "$#" 1
        dict[app]="${1:?}"
    fi
    koopa_assert_is_set '--name' "${dict[name]}"
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
            if [[ -z "${dict[app]}" ]]
            then
                dict[locate_app_fun]="koopa_locate_${dict[name]}"
                koopa_assert_is_function "${dict[locate_app_fun]}"
                dict[app]="$("${dict[locate_app_fun]}")"
            fi
            koopa_assert_is_installed "${dict[app]}"
            dict[version]="$(koopa_get_version "${dict[app]}")"
        fi
        dict[prefix]="$("${dict[pkg_prefix_fun]}" "${dict[version]}")"
    fi
    koopa_alert_configure_start "${dict[name_fancy]}" "${dict[prefix]}"
    if [[ ! -d "${dict[prefix]}" ]]
    then
        koopa_sys_mkdir "${dict[prefix]}"
        koopa_sys_set_permissions "$(koopa_dirname "${dict[prefix]}")"
    fi
    if [[ "${dict[link_in_opt]}" -eq 1 ]]
    then
        koopa_link_in_opt "${dict[prefix]}" "${dict[name]}-packages"
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

# FIXME Our opt linker isn't working any more...what's up with that?

koopa_install_app() { # {{{1
    # """
    # Install application in a versioned directory structure.
    # @note Updated 2022-04-07.
    # """
    local bin_arr brew_opt_arr clean_path_arr dict i init_dir opt_arr pos
    koopa_assert_has_args "$#"
    koopa_assert_has_no_envs
    declare -A dict=(
        # When enabled, this will change permissions on the top level directory
        # of the automatically generated prefix.
        [auto_prefix]=1
        [installer]=''
        [installers_prefix]="$(koopa_installers_prefix)"
        [koopa_prefix]="$(koopa_koopa_prefix)"
        # Will any individual programs be linked into koopa 'bin/'?
        [link_in_bin]=0
        # When enabled, this will symlink all files into make prefix,
        # typically '/usr/local'.
        [link_in_make]=0
        # Create an unversioned symlink in koopa 'opt/' directory.
        [link_in_opt]=1
        [make_prefix]="$(koopa_make_prefix)"
        [name]=''
        [name_fancy]=''
        [platform]='common'
        [prefix]=''
        # This override is useful for app packages configuration.
        [prefix_check]=1
        # Push completed build to Acid Genomics S3 bucket.
        [push]=0
        # This is useful for avoiding duplicate alert messages inside of
        # nested install calls (e.g. Emacs installer handoff to GNU app).
        [quiet]=0
        [reinstall]=0
        [shared]=0
        [system]=0
        [tmp_dir]="$(koopa_tmp_dir)"
        [update_ldconfig]=0
        [verbose]=0
        [version]=''
        [version_key]=''
    )
    bin_arr=()
    brew_opt_arr=()
    clean_path_arr=('/usr/bin' '/bin' '/usr/sbin' '/sbin')
    opt_arr=()
    pos=()
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--activate-homebrew-opt='*)
                brew_opt_arr+=("${1#*=}")
                shift 1
                ;;
            '--activate-homebrew-opt')
                brew_opt_arr+=("${2:?}")
                shift 2
                ;;
            '--activate-opt='*)
                opt_arr+=("${1#*=}")
                shift 1
                ;;
            '--activate-opt')
                opt_arr+=("${2:?}")
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
            '--link-in-bin='*)
                bin_arr+=("${1#*=}")
                shift 1
                ;;
            '--link-in-bin')
                bin_arr+=("${2:?}")
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
            '--link-in-make')
                dict[link_in_make]=1
                shift 1
                ;;
            '--link-in-opt')
                dict[link_in_opt]=1
                shift 1
                ;;
            '--no-link-in-make')
                dict[link_in_make]=0
                shift 1
                ;;
            '--no-link-in-opt')
                dict[link_in_opt]=0
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
            '--push')
                dict[push]=1
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
                dict[verbose]=1
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
    [[ "${dict[verbose]}" -eq 1 ]] && set -o xtrace
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
        dict[link_in_make]=0
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
    if [[ ! -d "${dict[prefix]}" ]] || \
        [[ "${dict[auto_prefix]}" -eq 0 ]] || \
        [[ "${dict[shared]}" -eq 0 ]] || \
        [[ "${dict[system]}" -eq 1 ]]
    then
        dict[link_in_opt]=0
    fi
    if [[ "${dict[link_in_opt]}" -eq 1 ]]
    then
        koopa_link_in_opt "${dict[prefix]}" "${dict[name]}"
    fi
    if koopa_is_linux && \
        { [[ "${dict[shared]}" -eq 1 ]] || \
            [[ "${dict[system]}" -eq 1 ]]; }
    then
        dict[update_ldconfig]=1
    fi
    if [[ "${dict[shared]}" -eq 0 ]] || [[ "${dict[system]}" -eq 1 ]]
    then
        dict[link_in_make]=0
    fi
    if koopa_is_array_non_empty "${bin_arr[@]:-}"
    then
        dict[link_in_bin]=1
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
        if koopa_is_array_non_empty "${brew_opt_arr[@]:-}"
        then
            koopa_activate_homebrew_opt_prefix "${brew_opt_arr[@]}"
        fi
        # Activate packages installed in Koopa 'opt/' directory.
        if koopa_is_array_non_empty "${opt_arr[@]:-}"
        then
            koopa_activate_opt_prefix "${opt_arr[@]}"
        fi
        if [[ "${dict[update_ldconfig]}" -eq 1 ]]
        then
            koopa_linux_update_ldconfig
        fi
        # shellcheck disable=SC2030
        export INSTALL_LINK_IN_BIN="${dict[link_in_bin]}"
        # shellcheck disable=SC2030
        export INSTALL_LINK_IN_MAKE="${dict[link_in_make]}"
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
    fi
    if [[ "${dict[link_in_make]}" -eq 1 ]]
    then
        koopa_link_in_make --prefix="${dict[prefix]}"
    fi
    if [[ "${dict[update_ldconfig]}" -eq 1 ]]
    then
        koopa_linux_update_ldconfig
    fi
    if [[ "${dict[link_in_bin]}" -eq 1 ]]
    then
        for i in "${!bin_arr[@]}"
        do
            koopa_link_in_bin \
                "${dict[prefix]}/${bin_arr[i]}" \
                "$(koopa_basename "${bin_arr[i]}")"
        done
    fi
    if [[ "${dict[push]}" -eq 1 ]]
    then
        koopa_assert_is_set \
            '--name' "${dict[name]}" \
            '--prefix' "${dict[prefix]}" \
            '--version' "${dict[version]}"
        koopa_push_app_build \
            --app-name="${dict[name]}" \
            --app-version="${dict[version]}"
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

# FIXME Need to support parameterized '--link-in-bin' here.
koopa_install_app_packages() { # {{{1
    # """
    # Install application packages.
    # @note Updated 2022-03-30.
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
    # @note Updated 2022-03-29.
    #
    # @examples
    # > koopa_push_app_build --app-name='node' --app-version='17.8.0'
    # # s3://koopa.acidgenomics.com/app/ubuntu-20/amd64/node/17.8.0.tar.gz
    # """
    local app dict pos
    koopa_assert_has_args "$#"
    declare -A app=(
        [aws]="$(koopa_locate_aws)"
        [tar]="$(koopa_locate_tar)"
    )
    declare -A dict=(
        [app_name]=''
        [app_prefix]="$(koopa_app_prefix)"
        [app_version]=''
        [arch]="$(koopa_arch2)"
        [os_string]="$(koopa_os_string)"
        [s3_prefix]='s3://koopa.acidgenomics.com/app'
        [s3_profile]='acidgenomics'
        [tmp_dir]="$(koopa_tmp_dir)"
    )
    pos=()
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
            '-'*)
                koopa_invalid_arg "$1"
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    if [[ "$#" -gt 0 ]]
    then
        koopa_assert_has_args_eq "$#" 2
        dict[app_name]="${1:?}"
        dict[app_version]="${2:?}"
    fi
    koopa_assert_is_set \
        '--app-name' "${dict[app_name]}" \
        '--app-version' "${dict[app_version]}"
    dict[prefix]="${dict[app_prefix]}/${dict[app_name]}/${dict[app_version]}"
    dict[local_tarball]="${dict[tmp_dir]}/${dict[app_version]}.tar.gz"
    dict[remote_tarball]="${dict[s3_prefix]}/${dict[os_string]}/${dict[arch]}/\
${dict[app_name]}/${dict[app_version]}.tar.gz"
    koopa_alert "Pushing '${dict[prefix]}' to '${dict[remote_tarball]}'."
    "${app[tar]}" -Pczf "${dict[local_tarball]}" "${dict[prefix]}/"
    "${app[aws]}" --profile="${dict[s3_profile]}" \
        s3 cp "${dict[local_tarball]}" "${dict[remote_tarball]}"
    koopa_rm "${dict[tmp_dir]}"
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

# FIXME Need to support parameterized '--unlink-app-in-bin' here.
# FIXME Consider adding support for unlinker function.
# FIXME We don't need to remove opt link only in shared, right? Rethink...
# FIXME Consider adding '--unlink-app-from-bin' parameterized option here.

# FIXME Rework to use 'koopa_unlink_in_opt'.

koopa_uninstall_app() { # {{{1
    # """
    # Uninstall an application.
    # @note Updated 2022-03-30.
    # """
    local app dict pos
    declare -A app
    declare -A dict=(
        [app_prefix]="$(koopa_app_prefix)"
        [installers_prefix]="$(koopa_installers_prefix)"
        [koopa_prefix]="$(koopa_koopa_prefix)"
        [link_in_make]=1  # FIXME Need to rethink this.
        [make_prefix]="$(koopa_make_prefix)"
        [name_fancy]=''
        [opt_prefix]="$(koopa_opt_prefix)"
        [platform]='common'
        [prefix]=''
        [quiet]=0
        [shared]=0
        [system]=0
        [uninstaller]=''
    )
    pos=()
    while (("$#"))
    do
        case "$1" in
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
            '--uninstaller='*)
                dict[uninstaller]="${1#*=}"
                shift 1
                ;;
            '--uninstaller')
                dict[uninstaller]="${2:?}"
                shift 2
                ;;
            # Flags ------------------------------------------------------------
            '--quiet')
                dict[quiet]=1
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
    [[ -z "${dict[name_fancy]}" ]] && dict[name_fancy]="${dict[name]}"
    if [[ -n "${dict[prefix]}" ]]
    then
        if [[ ! -d "${dict[prefix]}" ]]
        then
            koopa_warn "${dict[name_fancy]} is not installed \
at '${dict[prefix]}'."
            return 1
        fi
        dict[prefix]="$(koopa_realpath "${dict[prefix]}")"
        if koopa_str_detect_regex \
            --string="${dict[prefix]}" \
            --pattern="^${dict[koopa_prefix]}"
        then
            dict[shared]=1
        else
            dict[shared]=0
        fi
    else
        if koopa_is_shared_install
        then
            dict[shared]=1
        else
            dict[shared]=0
        fi
    fi
    if [[ "${dict[system]}" -eq 1 ]]
    then
        dict[shared]=0
    fi
    if [[ "${dict[shared]}" -eq 1 ]] || [[ "${dict[system]}" -eq 1 ]]
    then
        koopa_assert_is_admin
    fi
    if [[ "${dict[system]}" -eq 1 ]]
    then
        if [[ "${dict[quiet]}" -eq 0 ]]
        then
            koopa_alert_uninstall_start "${dict[name_fancy]}"
        fi
        if [[ -n "${dict[prefix]}" ]]
        then
            koopa_rm --sudo "${dict[prefix]}"
        else
            [[ -z "${dict[uninstaller]}" ]] && dict[uninstaller]="${dict[name]}"
            dict[uninstaller]="$( \
                koopa_snake_case_simple "uninstall_${dict[uninstaller]}" \
            )"
            dict[uninstaller_file]="$( \
                koopa_kebab_case_simple "${dict[uninstaller]}" \
            )"
            dict[uninstaller_file]="${dict[installers_prefix]}/\
${dict[platform]}/${dict[uninstaller_file]}.sh"
            koopa_assert_is_file "${dict[uninstaller_file]}"
            # shellcheck source=/dev/null
            source "${dict[uninstaller_file]}"
            dict[function]="$(koopa_snake_case_simple "${dict[uninstaller]}")"
            if [[ "${dict[platform]}" != 'common' ]]
            then
                dict[function]="${dict[platform]}_${dict[function]}"
            fi
            dict[function]="${dict[function]}"
            koopa_assert_is_function "${dict[function]}"
            "${dict[function]}" "$@"
        fi
        if [[ "${dict[quiet]}" -eq 0 ]]
        then
            koopa_alert_uninstall_success "${dict[name_fancy]}"
        fi
    else
        koopa_assert_has_no_args "$#"
        if [[ -z "${dict[prefix]}" ]]
        then
            dict[prefix]="${dict[app_prefix]}/${dict[name]}"
        fi
        if [[ ! -d "${dict[prefix]}" ]]
        then
            koopa_warn "${dict[name_fancy]} is not installed \
at '${dict[prefix]}'."
            return 1
        fi
        if [[ "${dict[shared]}" -eq 1 ]]
        then
            app[rm]='koopa_sys_rm'
        else
            app[rm]='koopa_rm'
        fi
        if [[ "${dict[quiet]}" -eq 0 ]]
        then
            koopa_alert_uninstall_start \
                "${dict[name_fancy]}" "${dict[prefix]}"
        fi
        "${app[rm]}" "${dict[prefix]}"

        # FIXME Only do this if shared.
        if [[ "${dict[unlink_in_opt]}" -eq 1 ]]
        then
            koopa_unlink_in_opt "${dict[name]}"
        fi
        # FIXME Look for unlink function and always remove here.
        if [[ "${dict[quiet]}" -eq 0 ]]
        then
            koopa_alert_uninstall_success \
                "${dict[name_fancy]}" "${dict[prefix]}"
        fi
    fi
    return 0
}

koopa_update_app() { # {{{1
    # """
    # Update application.
    # @note Updated 2022-04-06.
    # """
    local brew_opt_arr clean_path_arr dict opt_arr pos
    koopa_assert_has_args "$#"
    koopa_assert_has_no_envs
    declare -A dict=(
        [homebrew_opt]=''
        [installers_prefix]="$(koopa_installers_prefix)"
        [koopa_prefix]="$(koopa_koopa_prefix)"
        [name_fancy]=''
        [opt]=''
        [opt_prefix]="$(koopa_opt_prefix)"
        [platform]='common'
        [prefix]=''
        [quiet]=0
        [shared]=0
        [system]=0
        [tmp_dir]="$(koopa_tmp_dir)"
        [update_ldconfig]=0
        [updater]=''
        [verbose]=0
        [version]=''
    )
    brew_opt_arr=()
    clean_path_arr=('/usr/bin' '/bin' '/usr/sbin' '/sbin')
    opt_arr=()
    pos=()
    while (("$#"))
    do
        case "$1" in
            '--activate-homebrew-opt='*)
                brew_opt_arr+=("${1#*=}")
                shift 1
                ;;
            '--activate-homebrew-opt')
                brew_opt_arr+=("${2:?}")
                shift 2
                ;;
            '--activate-opt='*)
                opt_arr+=("${1#*=}")
                shift 1
                ;;
            '--activate-opt')
                opt_arr+=("${2:?}")
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
            '--updater='*)
                dict[updater]="${1#*=}"
                shift 1
                ;;
            '--updater')
                dict[updater]="${2:?}"
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
            '--quiet')
                dict[quiet]=1
                shift 1
                ;;
            '--system')
                dict[system]=1
                shift 1
                ;;
            '--verbose')
                dict[verbose]=1
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
    [[ "${dict[verbose]}" -eq 1 ]] && set -o xtrace
    [[ -z "${dict[name_fancy]}" ]] && dict[name_fancy]="${dict[name]}"
    if [[ -n "${dict[prefix]}" ]]
    then
        if [[ ! -d "${dict[prefix]}" ]]
        then
            koopa_warn "${dict[name_fancy]} is not installed \
at '${dict[prefix]}'."
            return 1
        fi
        dict[prefix]="$(koopa_realpath "${dict[prefix]}")"
        if koopa_str_detect_regex \
            --string="${dict[prefix]}" \
            --pattern="^${dict[koopa_prefix]}"
        then
            dict[shared]=1
        else
            dict[shared]=0
        fi
    else
        if koopa_is_shared_install
        then
            dict[shared]=1
        else
            dict[shared]=0
        fi
    fi
    if [[ "${dict[system]}" -eq 1 ]]
    then
        dict[shared]=0
    fi
    if [[ "${dict[shared]}" -eq 1 ]] || [[ "${dict[system]}" -eq 1 ]]
    then
        koopa_assert_is_admin
    fi
    [[ -z "${dict[updater]}" ]] && dict[updater]="${dict[name]}"
    dict[updater]="$(koopa_snake_case_simple "update_${dict[updater]}")"
    dict[updater_file]="$(koopa_kebab_case_simple "${dict[updater]}")"
    dict[updater_file]="${dict[installers_prefix]}/\
${dict[platform]}/${dict[updater_file]}.sh"
    koopa_assert_is_file "${dict[updater_file]}"
    # shellcheck source=/dev/null
    source "${dict[updater_file]}"
    dict[function]="$(koopa_snake_case_simple "${dict[updater]}")"
    if [[ "${dict[platform]}" != 'common' ]]
    then
        dict[function]="${dict[platform]}_${dict[function]}"
    fi
    dict[function]="${dict[function]}"
    koopa_assert_is_function "${dict[function]}"
    if [[ -z "${dict[prefix]}" ]] && [[ "${dict[system]}" -eq 0 ]]
    then
        dict[prefix]="${dict[opt_prefix]}/${dict[name]}"
    fi
    if [[ -n "${dict[prefix]}" ]]
    then
        if [[ ! -d "${dict[prefix]}" ]]
        then
            koopa_warn "${dict[name_fancy]} is not installed \
at '${dict[prefix]}'."
            return 1
        fi
        dict[prefix]="$(koopa_realpath "${dict[prefix]}")"
        koopa_alert_update_start "${dict[name_fancy]}" "${dict[prefix]}"
    else
        koopa_alert_update_start "${dict[name_fancy]}"
    fi
    if koopa_is_linux && \
        { [[ "${dict[shared]}" -eq 1 ]] || \
            [[ "${dict[system]}" -eq 1 ]]; }
    then
        dict[update_ldconfig]=1
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
        if koopa_is_array_non_empty "${brew_opt_arr[@]:-}"
        then
            koopa_activate_homebrew_opt_prefix "${brew_opt_arr[@]}"
        fi
        # Activate packages installed in Koopa 'opt/' directory.
        if koopa_is_array_non_empty "${opt_arr[@]:-}"
        then
            koopa_activate_opt_prefix "${opt_arr[@]}"
        fi
        if [[ "${dict[update_ldconfig]}" -eq 1 ]]
        then
            koopa_linux_update_ldconfig
        fi
        # shellcheck disable=SC2030
        export UPDATE_PREFIX="${dict[prefix]}"
        "${dict[function]}" "$@"
    )
    koopa_rm "${dict[tmp_dir]}"
    if [[ -d "${dict[prefix]}" ]] && [[ "${dict[system]}" -eq 0 ]]
    then
        if [[ "${dict[shared]}" -eq 1 ]]
        then
            koopa_sys_set_permissions --recursive "${dict[prefix]}"
        fi
    fi
    if [[ "${dict[update_ldconfig]}" -eq 1 ]]
    then
        koopa_linux_update_ldconfig
    fi
    if [[ -d "${dict[prefix]}" ]]
    then
        koopa_alert_update_success "${dict[name_fancy]}" "${dict[prefix]}"
    else
        koopa_alert_update_success "${dict[name_fancy]}"
    fi
    return 0
}
