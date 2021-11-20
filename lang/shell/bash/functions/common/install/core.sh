#!/usr/bin/env bash

koopa::configure_app_packages() { # {{{1
    # """
    # Configure language application.
    # @note Updated 2021-11-18.
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
                koopa::invalid_arg "$1"
                ;;
        esac
    done
    if [[ -z "${dict[name_fancy]}" ]]
    then
        dict[name_fancy]="${dict[name]}"
    fi
    dict[pkg_prefix_fun]="koopa::${dict[name]}_packages_prefix"
    koopa::assert_is_function "${dict[pkg_prefix_fun]}"
    if [[ -z "${dict[prefix]}" ]]
    then
        if [[ -z "${dict[version]}" ]]
        then
            dict[version]="$(koopa::get_version "${dict[which_app]}")"
        fi
        dict[prefix]="$("${dict[pkg_prefix_fun]}" "${dict[version]}")"
    fi
    koopa::alert_configure_start "${dict[name_fancy]}" "${dict[prefix]}"
    if [[ ! -d "${dict[prefix]}" ]]
    then
        koopa::sys_mkdir "${dict[prefix]}"
        koopa::sys_set_permissions "$(koopa::dirname "${dict[prefix]}")"
    fi
    if [[ "${dict[link_app]}" -eq 1 ]]
    then
        koopa::link_app_into_opt "${dict[prefix]}" "${dict[name]}-packages"
    fi
    koopa::alert_configure_success "${dict[name_fancy]}" "${dict[prefix]}"
    return 0
}

koopa::find_app_version() { # {{{1
    # """
    # Find the latest application version.
    # @note Updated 2021-11-11.
    # """
    local app dict
    koopa::assert_has_args_eq "$#" 1
    declare -A app=(
        [sort]="$(koopa::locate_sort)"
        [tail]="$(koopa::locate_tail)"
    )
    declare -A dict=(
        [app_prefix]="$(koopa::app_prefix)"
        [name]="${1:?}"
    )
    dict[prefix]="${dict[app_prefix]}/${dict[name]}"
    koopa::assert_is_dir "${dict[prefix]}"
    dict[hit]="$( \
        koopa::find \
            --max-depth=1 \
            --min-depth=1 \
            --prefix="${dict[prefix]}" \
            --type='d' \
        | "${app[sort]}" \
        | "${app[tail]}" -n 1 \
    )"
    [[ -d "${dict[hit]}" ]] || return 1
    dict[hit_bn]="$(koopa::basename "${dict[hit]}")"
    koopa::print "${dict[hit_bn]}"
    return 0
}

# FIXME Need to rethink our auto-prefix and auto-version approach here.
# FIXME Need to rename this inside of function calls
# FIXME Consider improving error messages when user attempts to redefine
# an internally defined value (e.g. '--version' when not allowed).

koopa::install_app() { # {{{1
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
        [link_app]=1
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
    # FIXME Need to improve our variable checks here.
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
        koopa::alert_install_start "${dict[name_fancy]}" "${dict[prefix]}"
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
        koopa::alert_install_start "${dict[name_fancy]}"
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
            if koopa::is_array_non_empty "${link_include_arr[@]:-}"
            then
                for link_include in "${link_include_arr[@]}"
                do
                    link_args+=("--include=${link_include}")
                done
            fi
            # Including the 'true' catch here to avoid 'cp' issues on Arch.
            koopa::link_app "${link_args[@]}" || true
        elif [[ "${dict[auto_prefix]}" -eq 1 ]]
        then
            koopa::link_app_into_opt "${dict[prefix]}" "${dict[name]}"
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
        koopa::alert_install_success "${dict[name_fancy]}" "${dict[prefix]}"
    else
        koopa::alert_install_success "${dict[name_fancy]}"
    fi
    return 0
}

koopa::install_app_packages() { # {{{1
    # """
    # Install application packages.
    # @note Updated 2021-11-17.
    # """
    local name name_fancy pos
    koopa::assert_has_args "$#"
    declare -A dict
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
            # Internally defined arguments -------------------------------------
            '--prefix='* | \
            '--prefix' | \
            '--version='* | \
            '--version' | \
            '--link' | \
            '--no-link' | \
            '--no-prefix-check' | \
            '--prefix-check')
                koopa::invalid_arg "$1"
                ;;
            # Other ------------------------------------------------------------
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    # FIXME Need to check that variables are defined here.
    dict[prefix_fun]="koopa::${dict[name]}_packages_prefix"
    koopa::assert_is_function "${dict[prefix_fun]}"
    koopa::install_app \
        --name-fancy="${dict[name_fancy]} packages" \
        --name="${dict[name]}-packages" \
        --no-link \
        --no-prefix-check \
        --prefix="$("${dict[prefix_fun]}")" \
        --version='rolling' \
        "$@"
    return 0
}

# FIXME Don't make this internal, rename the function.
koopa::install_gnu_app() { # {{{1
    koopa::assert_has_args "$#"
    koopa::install_app \
        --installer='gnu-app' \
        "$@"
    return 0
}

koopa::link_app() { # {{{1
    # """
    # Symlink application into make directory.
    # @note Updated 2021-11-16.
    #
    # If you run into permissions issues during link, check the build prefix
    # permissions. Ensure group is not 'root', and that group has write access.
    #
    # This can be reset easily with 'koopa::sys_set_permissions'.
    #
    # Note that Debian symlinks 'man' to 'share/man', which is non-standard.
    # This is currently corrected in 'install-debian-base', but top-level
    # symlink checks may need to be added here in a future update.
    #
    # @section cp arguments:
    # * -f, --force
    # * -R, -r, --recursive
    # * -s, --symbolic-link
    #
    # @examples
    # > koopa::link_app 'emacs' '26.3'
    # """
    local cp_args cp_source cp_target dict i include pos
    koopa::assert_has_args "$#"
    koopa::assert_has_no_envs
    declare -A dict=(
        [make_prefix]="$(koopa::make_prefix)"
        [version]=''
    )
    include=()
    pos=()
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--include='*)
                include+=("${1#*=}")
                shift 1
                ;;
            '--include')
                include+=("${2:?}")
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
            '--version='*)
                dict[version]="${1#*=}"
                shift 1
                ;;
            '--version')
                dict[version]="${2:?}"
                shift 2
                ;;
            # Other ------------------------------------------------------------
            '-'*)
                koopa::invalid_arg "$1"
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    koopa::assert_has_args_le "$#" 1
    if [[ -n "${1:-}" ]]
    then
        dict[name]="${1:?}"
    fi
    if [[ -z "${dict[version]}" ]]
    then
        dict[version]="$(koopa::find_app_version "${dict[name]}")"
    fi
    dict[app_prefix]="$(koopa::app_prefix)/${dict[name]}/${dict[version]}"
    koopa::assert_is_dir "${dict[app_prefix]}" "${dict[make_prefix]}"
    koopa::link_app_into_opt "${dict[app_prefix]}" "${dict[name]}"
    koopa::is_macos && return 0
    koopa::alert "Linking '${dict[app_prefix]}' in '${dict[make_prefix]}'."
    koopa::sys_set_permissions --recursive "${dict[app_prefix]}"
    koopa::delete_broken_symlinks "${dict[app_prefix]}" "${dict[make_prefix]}"
    cp_args=('--symbolic-link')
    koopa::is_shared_install && cp_args+=('--sudo')
    if koopa::is_array_non_empty "${include[@]:-}"
    then
        # Ensure we are using relative paths in following commands.
        include=("${include[@]/^/${dict[app_prefix]}}")
        for i in "${!include[@]}"
        do
            cp_source="${dict[app_prefix]}/${include[$i]}"
            cp_target="${dict[make_prefix]}/${include[$i]}"
            koopa::cp "${cp_args[@]}" "$cp_source" "$cp_target"
        done
    else
        readarray -t include <<< "$( \
            koopa::find \
                --max-depth=1 \
                --min-depth=1 \
                --prefix="${dict[app_prefix]}" \
                --sort \
                --type='d' \
        )"
        koopa::assert_is_array_non_empty "${include[@]:-}"
        cp_args+=("--target-directory=${dict[make_prefix]}")
        koopa::cp "${cp_args[@]}" "${include[@]}"
    fi
    return 0
}

# FIXME Need to rework using dict approach.
koopa::link_app_into_opt() { # {{{1
    # """
    # Link an application into koopa opt prefix.
    # @note Updated 2021-11-17.
    # """
    koopa::assert_has_args_eq "$#" 2
    local opt_prefix source_dir target_dir
    source_dir="${1:?}"
    opt_prefix="$(koopa::opt_prefix)"
    [[ ! -d "$opt_prefix" ]] && koopa::mkdir "$opt_prefix"
    target_dir="${opt_prefix}/${2:?}"
    # This happens during installation of app packages (e.g. Python).
    [[ "$source_dir" == "$target_dir" ]] && return 0
    koopa::alert "Linking '${source_dir}' in '${target_dir}'."
    [[ ! -d "$source_dir" ]] && koopa::mkdir "$source_dir"
    [[ -d "$target_dir" ]] && koopa::sys_rm "$target_dir"
    koopa::sys_set_permissions "$opt_prefix"
    koopa::sys_ln "$source_dir" "$target_dir"
    return 0
}

koopa::prune_apps() { # {{{1
    # """
    # Prune applications.
    # @note Updated 2021-08-14.
    # """
    if koopa::is_macos
    then
        koopa::alert_note 'App pruning not yet supported on macOS.'
        return 0
    fi
    koopa::r_koopa 'cliPruneApps' "$@"
    return 0
}

koopa::uninstall_app() { # {{{1
    # """
    # Uninstall an application.
    # @note Updated 2021-11-02.
    # """
    local app dict pos
    declare -A app
    declare -A dict=(
        [app_prefix]="$(koopa::app_prefix)"
        [function]=''
        [koopa_prefix]="$(koopa::koopa_prefix)"
        [link_app]=''
        [make_prefix]="$(koopa::make_prefix)"
        [name_fancy]=''
        [opt_prefix]="$(koopa::opt_prefix)"
        [platform]=''
        [prefix]=''
        [shared]=0
        [system]=0
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
            # Flags ------------------------------------------------------------
            '--link')
                dict[link_app]=1
                shift 1
                ;;
            '--no-link')
                dict[link_app]=0
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
    # FIXME Need to improve our checks that variable is set.
    [[ -z "${dict[name_fancy]}" ]] && dict[name_fancy]="${dict[name]}"
    if [[ "${dict[system]}" -eq 1 ]]
    then
        koopa::uninstall_start "${dict[name_fancy]}"
        dict[function]="$(koopa::snake_case_simple "${dict[name]}")"
        dict[function]="uninstall_${dict[function]}"
        if [[ -n "${dict[platform]}" ]]
        then
            dict[function]="${dict[platform]}_${dict[function]}"
        fi
        dict[function]="koopa:::${dict[function]}"
        if ! koopa::is_function "${dict[function]}"
        then
            koopa::stop 'Unsupported command.'
        fi
        "${dict[function]}" "$@"
        koopa::uninstall_success "${dict[name_fancy]}"
    else
        koopa::assert_has_no_args "$#"
        if [[ -z "${dict[prefix]}" ]]
        then
            dict[prefix]="${dict[app_prefix]}/${dict[name]}"
        fi
        if [[ ! -d "${dict[prefix]}" ]]
        then
            koopa::alert_is_not_installed \
                "${dict[name_fancy]}" \
                "${dict[prefix]}"
            return 0
        fi
        if koopa::str_match_regex \
            "${dict[prefix]}" \
            "^${dict[koopa_prefix]}"
        then
            dict[shared]=1
        fi
        koopa::uninstall_start "${dict[name_fancy]}" "${dict[prefix]}"
        if [[ "${dict[shared]}" -eq 1 ]]
        then
            app[rm]='koopa::sys_rm'
        else
            app[rm]='koopa::rm'
        fi
        "${app[rm]}" \
            "${dict[prefix]}" \
            "${dict[opt_prefix]}/${dict[name]}"
        if [[ -z "${dict[link_app]}" ]]
        then
            if [[ "${dict[shared]}" -eq 0 ]] || koopa::is_macos
            then
                dict[link_app]=0
            else
                dict[link_app]=1
            fi
        fi
        if [[ "${dict[link_app]}" -eq 1 ]]
        then
            koopa::alert "Deleting broken symlinks in '${dict[make_prefix]}'."
            koopa::delete_broken_symlinks "${dict[make_prefix]}"
        fi
        koopa::uninstall_success "${dict[name_fancy]}" "${dict[prefix]}"
    fi
    return 0
}

koopa::unlink_app() { # {{{1
    # """
    # Unlink an application.
    # @note Updated 2021-08-14.
    # """
    local make_prefix
    koopa::assert_has_args "$#"
    make_prefix="$(koopa::make_prefix)"
    if koopa::is_macos
    then
        koopa::alert_note "Linking into '${make_prefix}' is not \
supported on macOS."
        return 0
    fi
    koopa::r_koopa 'cliUnlinkApp' "$@"
    return 0
}

koopa::update_app() { # {{{1
    # """
    # Update application.
    # @note Updated 2021-11-16.
    # """
    local app clean_path_arr dict pkgs
    koopa::assert_has_args "$#"
    koopa::assert_has_no_envs
    declare -A app=(
        [tee]="$(koopa::locate_tee)"
    )
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
        [tmp_log_file]="$(koopa::tmp_log_file)"
        [version]=''
    )
    clean_path_arr=('/usr/bin' '/bin' '/usr/sbin' '/sbin')
    koopa::is_shared_install && dict[shared]=1
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
        "${dict[function]}"
    ) 2>&1 | "${app[tee]}" "${dict[tmp_log_file]}"
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
