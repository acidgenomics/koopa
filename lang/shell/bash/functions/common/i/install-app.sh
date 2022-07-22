#!/usr/bin/env bash

# FIXME Need to add an override so 'koopa install r-packages' doesn't
# log into this directory.

# FIXME opt links are currently set with incorrect group permissions on
# Ubuntu, which causes an uninstall error.
# FIXME This can be accomplished with 'sudo chown -h 'ubuntu:sudo' *'

# FIXME This is now failing for 'koopa install r-packages' when using
# system R on Ubuntu. Need to rethink the prefix handling here, not using
# '--no-prefix-check'....the steps after the installer have issues here,
# including the opt linkage...

# FIXME Consider removing support for link-in-make option here.
# FIXME Need to add support for link in man here.

koopa_install_app() {
    # """
    # Install application in a versioned directory structure.
    # @note Updated 2022-07-19.
    # """
    local app bin_arr bool build_opt_arr clean_path_arr dict i opt_arr pos
    koopa_assert_has_args "$#"
    koopa_assert_has_no_envs
    declare -A app=(
        [tee]="$(koopa_locate_tee)"
    )
    [[ -x "${app[tee]}" ]] || return 1
    declare -A bool=(
        # When enabled, this will change permissions on the top level directory
        # of the automatically generated prefix.
        [auto_prefix]=0
        # Download pre-built binary from our S3 bucket. Inspired by the
        # Homebrew bottle approach.
        [binary]=0
        # Will any individual programs be linked into koopa 'bin/'?
        [link_in_bin]=0
        # When enabled, this will symlink all files into make prefix,
        # typically '/usr/local'.
        [link_in_make]=0
        # Create an unversioned symlink in koopa 'opt/' directory.
        [link_in_opt]=1
        # This override is useful for app packages configuration.
        [prefix_check]=1
        # Push completed build to AWS S3 bucket.
        [push]=0
        # This is useful for avoiding duplicate alert messages inside of
        # nested install calls (e.g. Emacs installer handoff to GNU app).
        [quiet]=0
        [reinstall]=0
        [update_ldconfig]=0
        [verbose]=0
        # When enabled, shortens git commit to 8 characters.
        [version_is_git_commit]=0
    )
    declare -A dict=(
        [app_prefix]="$(koopa_app_prefix)"
        [installer_bn]=''
        [installer_fun]='main'
        [installers_prefix]="$(koopa_installers_prefix)"
        [koopa_prefix]="$(koopa_koopa_prefix)"
        [make_prefix]="$(koopa_make_prefix)"
        [mode]='shared'
        [name]=''
        [platform]='common'
        [prefix]=''
        [tmp_dir]="$(koopa_tmp_dir)"
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
            # CLI user-accessible flags ----------------------------------------
            '--binary')
                bool[binary]=1
                shift 1
                ;;
            '--push')
                bool[push]=1
                shift 1
                ;;
            '--reinstall')
                bool[reinstall]=1
                shift 1
                ;;
            '--verbose')
                bool[verbose]=1
                shift 1
                ;;
            # Internal flags ---------------------------------------------------
            '--link-in-make')
                bool[link_in_make]=1
                shift 1
                ;;
            '--no-link-in-opt')
                bool[link_in_opt]=0
                shift 1
                ;;
            '--no-prefix-check')
                bool[prefix_check]=0
                shift 1
                ;;
            '--quiet')
                bool[quiet]=1
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
            '--version-is-git-commit')
                bool[version_is_git_commit]=1
                shift 1
                ;;
            # Configuration passthrough support --------------------------------
            # Inspired by CMake approach using '-D' prefix.
            '-D')
            pos+=("${2:?}")
                shift 2
                ;;
            # Other ------------------------------------------------------------
            '')
                shift 1
                ;;
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    koopa_assert_is_set '--name' "${dict[name]}"
    [[ "${bool[verbose]}" -eq 1 ]] && set -o xtrace
    [[ -z "${dict[version_key]}" ]] && dict[version_key]="${dict[name]}"
    dict[current_version]="$(\
        koopa_variable "${dict[version_key]}" 2>/dev/null || true \
    )"
    [[ -z "${dict[version]}" ]] && dict[version]="${dict[current_version]}"
    if [[ "${dict[version]}" != "${dict[current_version]}" ]]
    then
        bool[link_in_bin]=0
        bool[link_in_make]=0
        bool[link_in_opt]=0
    fi
    case "${dict[mode]}" in
        'shared')
            if [[ -z "${dict[prefix]}" ]]
            then
                bool[auto_prefix]=1
                dict[version2]="${dict[version]}"
                if [[ "${bool[version_is_git_commit]}" -eq 1 ]]
                then
                    dict[version2]="${dict[version2]:0:8}"
                fi
                dict[prefix]="${dict[app_prefix]}/${dict[name]}/\
${dict[version2]}"
            fi
            ;;
        'system')
            koopa_assert_is_admin
            bool[link_in_make]=0
            bool[link_in_opt]=0
            koopa_is_linux && bool[update_ldconfig]=1
            ;;
        'user')
            bool[link_in_make]=0
            bool[link_in_opt]=0
            ;;
    esac
    koopa_is_array_non_empty "${bin_arr[@]:-}" && bool[link_in_bin]=1
    [[ -d "${dict[prefix]}" ]] && \
        dict[prefix]="$(koopa_realpath "${dict[prefix]}")"
    [[ -z "${dict[installer_bn]}" ]] && dict[installer_bn]="${dict[name]}"
    dict[installer_file]="${dict[installers_prefix]}/${dict[platform]}/\
${dict[mode]}/install-${dict[installer_bn]}.sh"
    koopa_assert_is_file "${dict[installer_file]}"
    # shellcheck source=/dev/null
    source "${dict[installer_file]}"
    koopa_assert_is_function "${dict[installer_fun]}"
    if [[ -n "${dict[prefix]}" ]] && [[ "${bool[prefix_check]}" -eq 1 ]]
    then
        if [[ -d "${dict[prefix]}" ]]
        then
            if [[ "${bool[reinstall]}" -eq 1 ]]
            then
                if [[ "${bool[quiet]}" -eq 0 ]]
                then
                    koopa_alert_uninstall_start \
                        "${dict[name]}" "${dict[prefix]}"
                fi
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
                if [[ "${bool[quiet]}" -eq 0 ]]
                then
                    koopa_alert_is_installed \
                        "${dict[name]}" "${dict[prefix]}"
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
    if [[ "${bool[binary]}" -eq 0 ]] && \
        [[ -d "${dict[prefix]}" ]] && \
        [[ "${dict[mode]}" != 'system' ]]
    then
        dict[log_file]="${dict[prefix]}/.koopa-install.log"
    else
        dict[log_file]="$(koopa_tmp_log_file)"
    fi
    if [[ "${bool[quiet]}" -eq 0 ]]
    then
        if [[ -n "${dict[prefix]}" ]]
        then
            koopa_alert_install_start "${dict[name]}" "${dict[prefix]}"
        else
            koopa_alert_install_start "${dict[name]}"
        fi
    fi
    (
        koopa_cd "${dict[tmp_dir]}"
        if [[ "${bool[binary]}" -eq 1 ]]
        then
            [[ -n "${dict[prefix]}" ]] || return 1
            koopa_install_app_from_binary_package "${dict[prefix]}"
            return 0
        fi
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
        if [[ "${bool[update_ldconfig]}" -eq 1 ]]
        then
            koopa_linux_update_ldconfig
        fi
        # shellcheck disable=SC2030
        export INSTALL_NAME="${dict[name]}"
        # shellcheck disable=SC2030
        export INSTALL_PREFIX="${dict[prefix]}"
        # shellcheck disable=SC2030
        export INSTALL_VERSION="${dict[version]}"
        [[ "${bool[verbose]}" -eq 1 ]] && declare -x
        "${dict[installer_fun]}" "$@"
        [[ "${bool[verbose]}" -eq 1 ]] && declare -x
        return 0
    ) 2>&1 | "${app[tee]}" "${dict[log_file]}"
    koopa_rm "${dict[tmp_dir]}"
    case "${dict[mode]}" in
        'shared')
            if [[ "${bool[auto_prefix]}" -eq 1 ]]
            then
                koopa_sys_set_permissions "$(koopa_dirname "${dict[prefix]}")"
            fi
            koopa_sys_set_permissions --recursive "${dict[prefix]}"
            ;;
        'user')
            koopa_sys_set_permissions --recursive --user "${dict[prefix]}"
            ;;
    esac
    if [[ "${bool[link_in_opt]}" -eq 1 ]]
    then
        koopa_link_in_opt "${dict[prefix]}" "${dict[name]}"
    fi
    if [[ "${bool[link_in_bin]}" -eq 1 ]]
    then
        for i in "${!bin_arr[@]}"
        do
            koopa_link_in_bin \
                "${dict[prefix]}/bin/${bin_arr[i]}" \
                "$(koopa_basename "${bin_arr[i]}")"
        done
    fi
    if [[ "${bool[link_in_make]}" -eq 1 ]]
    then
        koopa_link_in_make --prefix="${dict[prefix]}"
    fi
    if [[ "${bool[update_ldconfig]}" -eq 1 ]]
    then
        koopa_linux_update_ldconfig
    fi
    if [[ "${bool[push]}" -eq 1 ]]
    then
        [[ "${dict[mode]}" == 'shared' ]] || return 1
        koopa_assert_is_set \
            '--name' "${dict[name]}" \
            '--prefix' "${dict[prefix]}"
        koopa_push_app_build "${dict[name]}"
    fi
    if [[ "${bool[quiet]}" -eq 0 ]]
    then
        if [[ -n "${dict[prefix]}" ]]
        then
            koopa_alert_install_success "${dict[name]}" "${dict[prefix]}"
        else
            koopa_alert_install_success "${dict[name]}"
        fi
    fi
    return 0
}
