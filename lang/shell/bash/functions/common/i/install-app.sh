#!/usr/bin/env bash

koopa_install_app() {
    # """
    # Install application in a versioned directory structure.
    # @note Updated 2022-05-10.
    # """
    local app bin_arr build_opt_arr clean_path_arr dict i opt_arr pos
    koopa_assert_has_args "$#"
    koopa_assert_has_no_envs
    declare -A app=(
        [tee]="$(koopa_locate_tee)"
    )
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
    build_opt_arr=()
    clean_path_arr=('/usr/bin' '/bin' '/usr/sbin' '/sbin')
    opt_arr=()
    pos=()
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--activate-build-opt='*)
                build_opt_arr+=("${1#*=}")
                shift 1
                ;;
            '--activate-build-opt')
                build_opt_arr+=("${2:?}")
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
            if [[ "${dict[reinstall]}" -eq 1 ]]
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
    if [[ -d "${dict[prefix]}" ]] && \
        [[ "${dict[mode]}" != 'system' ]]
    then
        dict[log_file]="${dict[prefix]}/.install.log"
    else
        dict[log_file]="$(koopa_tmp_log_file)"
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
        # >     LDLIBS \
        # >     LD_LIBRARY_PATH \
        # >     PKG_CONFIG_PATH
        PATH="$(koopa_paste --sep=':' "${clean_path_arr[@]}")"
        export PATH
        if koopa_is_linux && \
            [[ -x '/usr/bin/pkg-config' ]]
        then
            koopa_add_to_pkg_config_path_2 \
                '/usr/bin/pkg-config'
        fi
        # Activate packages installed in koopa 'opt/' directory.
        if koopa_is_array_non_empty "${build_opt_arr[@]:-}"
        then
            koopa_activate_build_opt_prefix "${build_opt_arr[@]}"
        fi
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
        "${dict[installer_fun]}" "$@"
        [[ "$#" -gt 0 ]] && koopa_dl 'configure args' "$*"
        koopa_dl \
            'CFLAGS' "${CFLAGS:-}" \
            'CPPFLAGS' "${CPPFLAGS:-}" \
            'LDFLAGS' "${LDFLAGS:-}" \
            'LDLIBS' "${LDLIBS:-}" \
            'LD_LIBRARY_PATH' "${LD_LIBRARY_PATH:-}" \
            'PATH' "${PATH:-}" \
            'PKG_CONFIG_PATH' "${PKG_CONFIG_PATH:-}"
        return 0
    ) 2>&1 | "${app[tee]}" "${dict[log_file]}"
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

