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
        | "${app[tail]}" -n 1 \
    )"
    [[ -d "${dict[hit]}" ]] || return 1
    dict[hit_bn]="$(koopa_basename "${dict[hit]}")"
    koopa_print "${dict[hit_bn]}"
    return 0
}

koopa_install_app() { # {{{1
    # """
    # Install application in a versioned directory structure.
    # @note Updated 2022-04-10.
    # """
    local bin_arr brew_opt_arr clean_path_arr dict i opt_arr pos
    koopa_assert_has_args "$#"
    koopa_assert_has_no_envs
    declare -A dict=(
        [app_prefix]="$(koopa_app_prefix)"
        # When enabled, this will change permissions on the top level directory
        # of the automatically generated prefix.
        [auto_prefix]=0
        # Download pre-built binary from our S3 bucket. Inspired by the
        # Homebrew bottle approach.
        [binary]=0
        [installer_bn]=''
        [installer_fun]='main'
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
        [mode]='shared'
        [name]=''
        [name_fancy]=''
        [platform]='common'
        [prefix]=''
        # This override is useful for app packages configuration.
        [prefix_check]=1
        # Push completed build to AWS S3 bucket.
        [push]=0
        # This is useful for avoiding duplicate alert messages inside of
        # nested install calls (e.g. Emacs installer handoff to GNU app).
        [quiet]=0
        [reinstall]=0
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
                dict[installer_bn]="${1#*=}"
                shift 1
                ;;
            '--installer')
                dict[installer_bn]="${2:?}"
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
            '--binary')
                dict[binary]=1
                shift 1
                ;;
            '--link-in-make')
                dict[link_in_make]=1
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
                dict[mode]='system'
                shift 1
                ;;
            '--user')
                dict[mode]='user'
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
    [[ -z "${dict[version_key]}" ]] && dict[version_key]="${dict[name]}"
    if [[ -z "${dict[version]}" ]]
    then
        dict[version]="$(\
            koopa_variable "${dict[version_key]}" 2>/dev/null || true \
        )"
    fi
    case "${dict[mode]}" in
        'shared')
            if [[ -z "${dict[prefix]}" ]]
            then
                dict[auto_prefix]=1
                dict[prefix]="${dict[app_prefix]}/${dict[name]}/\
${dict[version]}"
            fi
            ;;
        'system')
            koopa_assert_is_admin
            dict[link_in_make]=0
            dict[link_in_opt]=0
            koopa_is_linux && dict[update_ldconfig]=1
            ;;
        'user')
            dict[link_in_make]=0
            dict[link_in_opt]=0
            ;;
    esac
    koopa_is_array_non_empty "${bin_arr[@]:-}" && dict[link_in_bin]=1
    [[ -z "${dict[name_fancy]}" ]] && dict[name_fancy]="${dict[name]}"
    [[ -d "${dict[prefix]}" ]] && \
        dict[prefix]="$(koopa_realpath "${dict[prefix]}")"
    [[ -z "${dict[installer_bn]}" ]] && dict[installer_bn]="${dict[name]}"
    dict[installer_file]="${dict[installers_prefix]}/${dict[platform]}/\
${dict[mode]}/install-${dict[installer_bn]}.sh"
    koopa_assert_is_file "${dict[installer_file]}"
    # shellcheck source=/dev/null
    source "${dict[installer_file]}"
    koopa_assert_is_function "${dict[installer_fun]}"
    if [[ "${dict[quiet]}" -eq 0 ]]
    then
        if [[ -n "${dict[prefix]}" ]]
        then
            koopa_alert_install_start "${dict[name_fancy]}" "${dict[prefix]}"
        else
            koopa_alert_install_start "${dict[name_fancy]}"
        fi
    fi
    if [[ -n "${dict[prefix]}" ]]
    then
        if [[ -d "${dict[prefix]}" ]] && [[ "${dict[prefix_check]}" -eq 1 ]]
        then
            if [[ "${dict[reinstall]}" -eq 1 ]] || \
                koopa_is_empty_dir "${dict[prefix]}"
            then
                case "${dict[mode]}" in
                    'system')
                        koopa_rm --sudo "${dict[prefix]}"
                        ;;
                    *)
                        koopa_rm "${dict[prefix]}"
                        ;;
                esac
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
        case "${dict[mode]}" in
            'system')
                dict[prefix]="$(koopa_init_dir --sudo "${dict[prefix]}")"
                ;;
            *)
                dict[prefix]="$(koopa_init_dir "${dict[prefix]}")"
                ;;
        esac
    fi
    if [[ "${dict[link_in_opt]}" -eq 1 ]]
    then
        koopa_link_in_opt "${dict[prefix]}" "${dict[name]}"
    fi
    (
        koopa_cd "${dict[tmp_dir]}"
        if [[ "${dict[binary]}" -eq 1 ]]
        then
            koopa_install_app_from_binary_package \
                --name="${dict[name]}" \
                --version="${dict[version]}"
            return 0
        fi
        # > unset -v \
        # >     CFLAGS \
        # >     CPPFLAGS \
        # >     LDFLAGS \
        # >     LD_LIBRARY_PATH \
        # >     PKG_CONFIG_PATH
        PATH="$(koopa_paste --sep=':' "${clean_path_arr[@]}")"
        export PATH
        if koopa_is_linux && \
            [[ -x '/usr/bin/pkg-config' ]]
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
        # > [[ -n "${CFLAGS:-}" ]] && \
        # >     koopa_dl 'CFLAGS' "${CFLAGS:?}"
        # > [[ -n "${CPPFLAGS:-}" ]] && \
        # >     koopa_dl 'CPPFLAGS' "${CPPFLAGS:?}"
        # > [[ -n "${LD_LIBRARY_PATH:-}" ]] && \
        # >     koopa_dl 'LD_LIBRARY_PATH' "${LD_LIBRARY_PATH:?}"
        # > [[ -n "${LDFLAGS:-}" ]] && \
        # >     koopa_dl 'LDFLAGS' "${LDFLAGS:?}"
        # > [[ -n "${PKG_CONFIG_PATH:-}" ]] && \
        # >     koopa_dl 'PKG_CONFIG_PATH' "${PKG_CONFIG_PATH:?}"
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
        "${dict[installer_fun]}" "$@"
    )
    koopa_rm "${dict[tmp_dir]}"
    case "${dict[mode]}" in
        'shared')
            if [[ "${dict[auto_prefix]}" -eq 1 ]]
            then
                koopa_sys_set_permissions "$(koopa_dirname "${dict[prefix]}")"
            fi
            koopa_sys_set_permissions --recursive "${dict[prefix]}"
            ;;
        'user')
            koopa_sys_set_permissions --recursive --user "${dict[prefix]}"
            ;;
    esac
    if [[ "${dict[link_in_bin]}" -eq 1 ]]
    then
        for i in "${!bin_arr[@]}"
        do
            koopa_link_in_bin \
                "${dict[prefix]}/${bin_arr[i]}" \
                "$(koopa_basename "${bin_arr[i]}")"
        done
    fi
    if [[ "${dict[link_in_make]}" -eq 1 ]]
    then
        koopa_link_in_make --prefix="${dict[prefix]}"
    fi
    if [[ "${dict[update_ldconfig]}" -eq 1 ]]
    then
        koopa_linux_update_ldconfig
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
        if [[ -n "${dict[prefix]}" ]]
        then
            koopa_alert_install_success "${dict[name_fancy]}" "${dict[prefix]}"
        else
            koopa_alert_install_success "${dict[name_fancy]}"
        fi
    fi
    return 0
}

koopa_install_app_from_binary_package() { # {{{1
    # """
    # Install app from pre-built binary package.
    # @note Updated 2022-04-07.
    # """
    local app dict
    koopa_assert_has_args "$#"
    declare -A app=(
        [tar]="$(koopa_locate_tar)"
    )
    # FIXME Rework koopa_koopa_app_binary_url here.
    declare -A dict=(
        [arch]="$(koopa_arch2)"
        [binary_prefix]='/opt/koopa'
        [koopa_prefix]="$(koopa_koopa_prefix)"
        [name]=''
        [os_string]="$(koopa_os_string)"
        [url_stem]="$(koopa_koopa_app_binary_url)"
        [version]=''
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
            '--version='*)
                dict[version]="${1#*=}"
                shift 1
                ;;
            '--version')
                dict[version]="${2:?}"
                shift 2
                ;;
            # Other ------------------------------------------------------------
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set \
        '--name' "${dict[name]}" \
        '--version' "${dict[version]}"
    if [[ "${dict[koopa_prefix]}" != "${dict[binary_prefix]}" ]]
    then
        koopa_stop "Binary package installation not supported for koopa \
install located at '${dict[koopa_prefix]}'. Koopa must be installed at \
default '${dict[binary_prefix]}' location."
    fi
    dict[tarball_file]="${dict[name]}-${dict[version]}.tar.gz"
    dict[tarball_url]="${dict[url_stem]}/${dict[os_string]}/${dict[arch]}/\
${dict[name]}/${dict[version]}.tar.gz"
    if ! koopa_is_url_active "${dict[tarball_url]}"
    then
        koopa_stop "No package at '${dict[tarball_url]}'."
    fi
    koopa_download "${dict[tarball_url]}" "${dict[tarball_file]}"
    "${app[tar]}" -Pxzvf "${dict[tarball_file]}"
    return 0
}

koopa_install_app_packages() { # {{{1
    # """
    # Install application packages.
    # @note Updated 2022-04-09.
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
            '--prefix='* | '--prefix' | \
            '--version='* | '--version' | \
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
        koopa_rm "${dict[prefix]}"
    fi
    koopa_install_app \
        --name-fancy="${dict[name_fancy]} packages" \
        --name="${dict[name]}-packages" \
        --no-prefix-check \
        --prefix="${dict[prefix]}" \
        --version='rolling' \
        "$@"
    return 0
}

# FIXME This needs to also invalidate cloud cache.
# FIXME Rework using koopa_koopa_app_binary with 's3://' instead of 'https://'

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

koopa_uninstall_app() { # {{{1
    # """
    # Uninstall an application.
    # @note Updated 2022-04-07.
    # """
    local app bin_arr dict pos
    declare -A app
    declare -A dict=(
        [app_prefix]="$(koopa_app_prefix)"
        [installers_prefix]="$(koopa_installers_prefix)"
        [koopa_prefix]="$(koopa_koopa_prefix)"
        [make_prefix]="$(koopa_make_prefix)"
        [mode]='shared'
        [name_fancy]=''
        [opt_prefix]="$(koopa_opt_prefix)"
        [platform]='common'
        [prefix]=''
        [quiet]=0
        [uninstaller_bn]=''
        [uninstaller_fun]='main'
        [unlink_in_bin]=0
        [unlink_in_make]=0
        [unlink_in_opt]=1
        [verbose]=0
    )
    bin_arr=()
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
                dict[uninstaller_bn]="${1#*=}"
                shift 1
                ;;
            '--uninstaller')
                dict[uninstaller_bn]="${2:?}"
                shift 2
                ;;
            '--unlink-in-bin='*)
                bin_arr+=("${1#*=}")
                shift 1
                ;;
            '--unlink-in-bin')
                bin_arr+=("${2:?}")
                shift 2
                ;;
            # Flags ------------------------------------------------------------
            '--no-unlink-in-opt')
                dict[unlink_in_opt]=0
                shift 1
                ;;
            '--quiet')
                dict[quiet]=1
                shift 1
                ;;
            '--system')
                dict[mode]='system'
                shift 1
                ;;
            '--unlink-in-make')
                dict[unlink_in_make]=1
                shift 1
                ;;
            '--user')
                dict[mode]='user'
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
    case "${dict[mode]}" in
        'shared')
            dict[unlink_in_opt]=1
            if [[ -z "${dict[prefix]}" ]]
            then
                dict[prefix]="${dict[app_prefix]}/${dict[name]}"
            fi
            ;;
        'system')
            koopa_assert_is_admin
            dict[unlink_in_opt]=0
            ;;
        'user')
            dict[unlink_in_opt]=0
            ;;
    esac
    koopa_is_array_non_empty "${bin_arr[@]:-}" && dict[unlink_in_bin]=1
    [[ -z "${dict[name_fancy]}" ]] && dict[name_fancy]="${dict[name]}"
    if [[ -n "${dict[prefix]}" ]]
    then
        if [[ ! -d "${dict[prefix]}" ]]
        then
            koopa_alert_is_not_installed "${dict[name_fancy]}" "${dict[prefix]}"
            return 1
        fi
        dict[prefix]="$(koopa_realpath "${dict[prefix]}")"
    fi
    if [[ "${dict[quiet]}" -eq 0 ]]
    then
        if [[ -n "${dict[prefix]}" ]]
        then
            koopa_alert_uninstall_start "${dict[name_fancy]}" "${dict[prefix]}"
        else
            koopa_alert_uninstall_start "${dict[name_fancy]}"
        fi
    fi
    [[ -z "${dict[uninstaller_bn]}" ]] && dict[uninstaller_bn]="${dict[name]}"
    dict[uninstaller_file]="${dict[installers_prefix]}/${dict[platform]}/\
${dict[mode]}/uninstall-${dict[uninstaller_bn]}.sh"
    if [[ -f "${dict[uninstaller_file]}" ]]
    then
        dict[tmp_dir]="$(koopa_tmp_dir)"
        (
            koopa_cd "${dict[tmp_dir]}"
            # shellcheck source=/dev/null
            source "${dict[uninstaller_file]}"
            koopa_assert_is_function "${dict[uninstaller_fun]}"
            "${dict[uninstaller_fun]}" "$@"
        )
        koopa_rm "${dict[tmp_dir]}"
    fi
    if [[ -d "${dict[prefix]}" ]]
    then
        case "${dict[mode]}" in
            'system')
                koopa_rm --sudo "${dict[prefix]}"
                ;;
            *)
                koopa_rm "${dict[prefix]}"
                ;;
        esac
    fi
    if [[ "${dict[unlink_in_bin]}" -eq 1 ]]
    then
        koopa_unlink_in_bin "${bin_arr[@]}"
    fi
    if [[ "${dict[unlink_in_opt]}" -eq 1 ]]
    then
        koopa_unlink_in_opt "${dict[name]}"
    fi
    if [[ "${dict[unlink_in_make]}" -eq 1 ]]
    then
        koopa_unlink_in_make "${dict[prefix]}"
    fi
    if [[ "${dict[quiet]}" -eq 0 ]]
    then
        if [[ -n "${dict[prefix]}" ]]
        then
            koopa_alert_uninstall_success \
                "${dict[name_fancy]}" "${dict[prefix]}"
        else
            koopa_alert_uninstall_success "${dict[name_fancy]}"
        fi
    fi
    return 0
}

koopa_update_app() { # {{{1
    # """
    # Update application.
    # @note Updated 2022-04-07.
    # """
    local brew_opt_arr clean_path_arr dict opt_arr pos
    koopa_assert_has_args "$#"
    koopa_assert_has_no_envs
    declare -A dict=(
        [installers_prefix]="$(koopa_installers_prefix)"
        [koopa_prefix]="$(koopa_koopa_prefix)"
        [mode]='shared'
        [name_fancy]=''
        [opt_prefix]="$(koopa_opt_prefix)"
        [platform]='common'
        [prefix]=''
        [quiet]=0
        [tmp_dir]="$(koopa_tmp_dir)"
        [update_ldconfig]=0
        [updater_bn]=''
        [updater_fun]='main'
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
                dict[updater_bn]="${1#*=}"
                shift 1
                ;;
            '--updater')
                dict[updater_bn]="${2:?}"
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
                dict[mode]='system'
                shift 1
                ;;
            '--user')
                dict[mode]='user'
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
    case "${dict[mode]}" in
        'shared')
            if [[ -z "${dict[prefix]}" ]]
            then
                dict[prefix]="${dict[opt_prefix]}/${dict[name]}"
            fi
            ;;
        'system')
            koopa_assert_is_admin
            koopa_is_linux && dict[update_ldconfig]=1
            ;;
    esac
    [[ -z "${dict[name_fancy]}" ]] && dict[name_fancy]="${dict[name]}"
    if [[ -n "${dict[prefix]}" ]]
    then
        if [[ ! -d "${dict[prefix]}" ]]
        then
            koopa_alert_is_not_installed "${dict[name_fancy]}" "${dict[prefix]}"
            return 1
        fi
        dict[prefix]="$(koopa_realpath "${dict[prefix]}")"
    fi
    [[ -z "${dict[updater_bn]}" ]] && dict[updater_bn]="${dict[name]}"
    dict[updater_file]="${dict[installers_prefix]}/${dict[platform]}/\
${dict[mode]}/update-${dict[updater_bn]}.sh"
    koopa_assert_is_file "${dict[updater_file]}"
    # shellcheck source=/dev/null
    source "${dict[updater_file]}"
    koopa_assert_is_function "${dict[updater_fun]}"
    if [[ "${dict[quiet]}" -eq 0 ]]
    then
        if [[ -n "${dict[prefix]}" ]]
        then
            koopa_alert_update_start "${dict[name_fancy]}" "${dict[prefix]}"
        else
            koopa_alert_update_start "${dict[name_fancy]}"
        fi
    fi
    (
        koopa_cd "${dict[tmp_dir]}"
        unset -v \
            CFLAGS \
            CPPFLAGS \
            LDFLAGS \
            LD_LIBRARY_PATH \
            PKG_CONFIG_PATH
        PATH="$(koopa_paste --sep=':' "${clean_path_arr[@]}")"
        export PATH
        if koopa_is_linux && \
            [[ -x '/usr/bin/pkg-config' ]]
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
        "${dict[updater_fun]}" "$@"
    )
    koopa_rm "${dict[tmp_dir]}"
    if [[ -d "${dict[prefix]}" ]]
    then
        case "${dict[mode]}" in
            'shared')
                koopa_sys_set_permissions \
                    --recursive "${dict[prefix]}"
                ;;
            # > 'user')
            # >     koopa_sys_set_permissions \
            # >         --recursive --user "${dict[prefix]}"
            # >     ;;
        esac
    fi
    if [[ "${dict[update_ldconfig]}" -eq 1 ]]
    then
        koopa_linux_update_ldconfig
    fi
    if [[ "${dict[quiet]}" -eq 0 ]]
    then
        if [[ -n "${dict[prefix]}" ]]
        then
            koopa_alert_update_success "${dict[name_fancy]}" "${dict[prefix]}"
        else
            koopa_alert_update_success "${dict[name_fancy]}"
        fi
    fi
    return 0
}
