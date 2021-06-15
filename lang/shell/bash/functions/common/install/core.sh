#!/usr/bin/env bash

koopa:::configure_app_packages() { # {{{1
    # """
    # Configure language application.
    # @note Updated 2021-06-14.
    # """
    local dict
    declare -A dict=(
        [link_app]=1
        [name_fancy]=''
        [prefix]=''
        [version]=''
        [which_app]=''
    )
    while (("$#"))
    do
        case "$1" in
            --name=*)
                dict[name]="${1#*=}"
                shift 1
                ;;
            --name-fancy=*)
                dict[name_fancy]="${1#*=}"
                shift 1
                ;;
            --no-link)
                dict[link_app]=0
                shift 1
                ;;
            --prefix=*)
                dict[prefix]="${1#*=}"
                shift 1
                ;;
            --version=*)
                dict[version]="${1#*=}"
                shift 1
                ;;
            --which-app=*)
                dict[which_app]="${1#*=}"
                shift 1
                ;;
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
    dict[activate_fun]="koopa::activate_${dict[name]}"
    koopa::is_function "${dict[activate_fun]}" && "${dict[activate_fun]}"
    if [[ -z "${dict[prefix]}" ]]
    then
        if [[ -z "${dict[version]}" ]]
        then
            if [[ -z "${dict[which_app]}" ]]
            then
                dict[which_app]="${dict[name]}"
            fi
            dict[version]="$(koopa::get_version "${dict[which_app]}")"
        fi
        dict[prefix]="$("${dict[pkg_prefix_fun]}" "${dict[version]}")"
    fi
    koopa::configure_start "${dict[name_fancy]}" "${dict[prefix]}"
    if [[ ! -d "${dict[prefix]}" ]]
    then
        koopa::sys_mkdir "${dict[prefix]}"
        koopa::sys_set_permissions "$(koopa::dirname "${dict[prefix]}")"
    fi
    if [[ "${dict[link_app]}" -eq 1 ]]
    then
        koopa::link_into_opt "${dict[prefix]}" "${dict[name]}-packages"
    fi
    koopa::is_function "${dict[activate_fun]}" && "${dict[activate_fun]}"
    koopa::configure_success "${dict[name_fancy]}" "${dict[prefix]}"
    return 0
}

koopa::find_app_version() { # {{{1
    # """
    # Find the latest application version.
    # @note Updated 2021-05-25.
    # """
    local find name prefix sort tail x
    koopa::assert_has_args "$#"
    find="$(koopa::locate_find)"
    sort="$(koopa::locate_sort)"
    tail="$(koopa::locate_tail)"
    name="${1:?}"
    prefix="$(koopa::app_prefix)"
    koopa::assert_is_dir "$prefix"
    prefix="${prefix}/${name}"
    koopa::assert_is_dir "$prefix"
    x="$( \
        "$find" "$prefix" \
            -mindepth 1 \
            -maxdepth 1 \
            -type 'd' \
        | "$sort" \
        | "$tail" -n 1 \
    )"
    [[ -d "$x" ]] || return 1
    x="$(koopa::basename "$x")"
    koopa::print "$x"
    return 0
}

koopa::install_app() { # {{{1
    # """
    # Install application into a versioned directory structure.
    # @note Updated 2021-06-07.
    #
    # The 'dict' array approach has the benefit of avoiding passing unwanted
    # local variables to the internal installer function call below.
    # """
    local arr dict link_args pkgs pos rm str tee
    koopa::assert_has_args "$#"
    koopa::assert_has_no_envs
    tee="$(koopa::locate_tee)"
    declare -A dict=(
        [arch]="$(koopa::arch)"
        [homebrew_opt]=''
        [installer]=''
        [link_app]=1
        [link_include_dirs]=''
        [make_prefix]="$(koopa::make_prefix)"
        [name_fancy]=''
        [opt]=''
        [path_harden]=1
        [platform]=''
        [prefix]=''
        [reinstall]=0
        [shared]=0
        [version]=''
    )
    koopa::is_shared_install && dict[shared]=1
    pos=()
    while (("$#"))
    do
        case "$1" in
            --homebrew-opt=*)
                dict[homebrew_opt]="${1#*=}"
                shift 1
                ;;
            --installer=*)
                dict[installer]="${1#*=}"
                shift 1
                ;;
            --link-include-dirs=*)
                dict[link_include_dirs]="${1#*=}"
                shift 1
                ;;
            --name=*)
                dict[name]="${1#*=}"
                shift 1
                ;;
            --name-fancy=*)
                dict[name_fancy]="${1#*=}"
                shift 1
                ;;
            --no-link)
                dict[link_app]=0
                shift 1
                ;;
            --no-path-harden)
                dict[path_harden]=0
                shift 1
                ;;
            --no-shared)
                dict[shared]=0
                shift 1
                ;;
            --opt=*)
                dict[opt]="${1#*=}"
                shift 1
                ;;
            --platform=*)
                dict[platform]="${1#*=}"
                shift 1
                ;;
            --prefix=*)
                dict[prefix]="${1#*=}"
                shift 1
                ;;
            --reinstall | \
            --force)
                dict[reinstall]=1
                shift 1
                ;;
            --version=*)
                dict[version]="${1#*=}"
                shift 1
                ;;
            --verbose)
                set -x
                shift 1
                ;;
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
    fi
    koopa::install_start \
        "${dict[name_fancy]}" \
        "${dict[version]}" \
        "${dict[prefix]}"
    if [[ "${dict[reinstall]}" -eq 1 ]] && [[ -d "${dict[prefix]}" ]]
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
    # Ensure configuration is minimal before proceeding, when desirable.
    if [[ "${dict[path_harden]}" -eq 1 ]]
    then
        declare -A conf_bak=(
            [LD_LIBRARY_PATH]="${LD_LIBRARY_PATH:-}"
            [PATH]="${PATH:-}"
            [PKG_CONFIG_PATH]="${PKG_CONFIG_PATH:-}"
        )
        unset -v LD_LIBRARY_PATH
        # Ensure clean 'PATH'.
        arr=(
            '/usr/bin'
            '/bin'
            '/usr/sbin'
            '/sbin'
        )
        str="$(koopa::paste0 ':' "${arr[@]}")"
        PATH="$str"
        export PATH
        # Ensure clean 'PKG_CONFIG_PATH'.
        if koopa::is_linux
        then
            arr=(
                "/usr/lib/${dict[arch]}-linux-gnu/pkgconfig"
                '/usr/lib/pkgconfig'
                '/usr/share/pkgconfig'
            )
            str="$(koopa::paste0 ':' "${arr[@]}")"
            PKG_CONFIG_PATH="$str"
            export PKG_CONFIG_PATH
        else
            unset -v PKG_CONFIG_PATH
        fi
    fi
    # Activate packages installed in Homebrew opt.
    if [[ -n "${dict[homebrew_opt]}" ]]
    then
        IFS=',' read -r -a pkgs <<< "${dict[homebrew_opt]}"
        koopa::activate_homebrew_opt_prefix "${pkgs[@]}"
    fi
    # Activate packages installed in Koopa opt.
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
        export INSTALL_LINK_APP="${dict[link_app]}"
        export INSTALL_NAME="${dict[name]}"
        export INSTALL_PREFIX="${dict[prefix]}"
        export INSTALL_VERSION="${dict[version]}"
        "${dict[function]}" "$@"
    ) 2>&1 | "$tee" "$(koopa::tmp_log_file)"
    koopa::rm "${dict[tmp_dir]}"
    if [[ "${dict[shared]}" -eq 1 ]]
    then
        koopa::sys_set_permissions -r "${dict[prefix]}"
        koopa::sys_set_permissions "$(koopa::dirname "${dict[prefix]}")"
        koopa::link_into_opt "${dict[prefix]}" "${dict[name]}"
    fi
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
    fi
    if [[ "${dict[shared]}" -eq 1 ]] && koopa::is_linux
    then
        koopa::update_ldconfig
    fi
    # Reset global variables, if applicable.
    if [[ "${dict[path_harden]}" -eq 1 ]]
    then
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
    fi
    koopa::install_success "${dict[name_fancy]}" "${dict[prefix]}"
    return 0
}

koopa::link_app() { # {{{1
    # """
    # Symlink application into build directory.
    # @note Updated 2021-05-25.
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
    # @section cp flags:
    # * -f, --force
    # * -R, -r, --recursive
    # * -s, --symbolic-link
    #
    # @examples
    # koopa::link_app emacs 26.3
    # """
    local app_prefix app_subdirs cp_flags find include_dirs make_prefix name
    local pos sort version
    find="$(koopa::locate_find)"
    sort="$(koopa::locate_sort)"
    include_dirs=''
    version=''
    pos=()
    while (("$#"))
    do
        case "$1" in
            --include-dirs=*)
                include_dirs="${1#*=}"
                shift 1
                ;;
            --name=*)
                name="${1#*=}"
                shift 1
                ;;
            --version=*)
                version="${1#*=}"
                shift 1
                ;;
            --)
                shift 1
                break
                ;;
            --*|-*)
                koopa::invalid_arg "$1"
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    [[ -n "${1:-}" ]] && name="$1"
    [[ -z "$version" ]] && version="$(koopa::find_app_version "$name")"
    koopa::assert_has_no_envs
    make_prefix="$(koopa::make_prefix)"
    app_prefix="$(koopa::app_prefix)/${name}/${version}"
    koopa::assert_is_dir "$app_prefix" "$make_prefix"
    if koopa::is_macos
    then
        koopa::stop "Linking into '${make_prefix}' is not supported on macOS."
    fi
    koopa::alert "Linking '${app_prefix}' in '${make_prefix}'."
    koopa::sys_set_permissions -r "$app_prefix"
    koopa::delete_broken_symlinks "$app_prefix" "$make_prefix"
    app_subdirs=()
    if [[ -n "$include_dirs" ]]
    then
        IFS=',' read -r -a app_subdirs <<< "$include_dirs"
        app_subdirs=("${app_subdirs[@]/^/${app_prefix}}")
        for i in "${!app_subdirs[@]}"
        do
            app_subdirs[$i]="${app_prefix}/${app_subdirs[$i]}"
        done
    else
        readarray -t app_subdirs <<< "$( \
            "$find" "$app_prefix" \
                -mindepth 1 \
                -maxdepth 1 \
                -type 'd' \
                -print \
            | "$sort" \
        )"
    fi
    # Copy as symbolic links.
    cp_flags=(
        '-s'
        '-t' "${make_prefix}"
    )
    koopa::is_shared_install && cp_flags+=('-S')
    koopa::cp "${cp_flags[@]}" "${app_subdirs[@]}"
    if koopa::is_linux && koopa::is_shared_install
    then
        koopa::update_ldconfig
    fi
    return 0
}

koopa::link_into_opt() { # {{{1
    # """
    # Link into koopa opt prefix.
    # @note Updated 2021-06-11.
    # """
    koopa::assert_has_args_eq "$#" 2
    local opt_prefix source_dir target_dir
    source_dir="${1:?}"
    opt_prefix="$(koopa::opt_prefix)"
    [[ ! -d "$opt_prefix" ]] && koopa::mkdir "$opt_prefix"
    target_dir="${opt_prefix}/${2:?}"
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
    # @note Updated 2021-01-04.
    # """
    if koopa::is_macos
    then
        koopa::alert_note 'App pruning not yet supported on macOS.'
        return 0
    fi
    koopa::r_script 'pruneApps' "$@"
    return 0
}

koopa::uninstall_app() { # {{{1
    # """
    # Uninstall an application.
    # @note Updated 2021-06-11.
    # """
    local dict pos rm
    declare -A dict=(
        [app_prefix]="$(koopa::app_prefix)"
        [koopa_prefix]="$(koopa::koopa_prefix)"
        [link_app]=''
        [make_prefix]="$(koopa::make_prefix)"
        [name_fancy]=''
        [opt_prefix]="$(koopa::opt_prefix)"
        [prefix]=''
        [shared]=0
    )
    pos=()
    while (("$#"))
    do
        case "$1" in
            --name=*)
                dict[name]="${1#*=}"
                shift 1
                ;;
            --name-fancy=*)
                dict[name_fancy]="${1#*=}"
                shift 1
                ;;
            --no-link)
                dict[link_app]=0
                shift 1
                ;;
            --prefix=*)
                dict[prefix]="${1#*=}"
                shift 1
                ;;
            *)
                koopa::invalid_arg "$1"
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    koopa::assert_has_no_args "$#"
    if [[ -z "${dict[prefix]}" ]]
    then
        dict[prefix]="${dict[app_prefix]}/${dict[name]}"
    fi
    if [[ ! -d "${dict[prefix]}" ]]
    then
        koopa::alert_is_not_installed "${dict[name_fancy]}" "${dict[prefix]}"
        return 0
    fi
    if koopa::str_match_regex "${dict[prefix]}" "^${dict[koopa_prefix]}"
    then
        dict[shared]=1
    fi
    if [[ "${dict[shared]}" -eq 1 ]]
    then
        rm='koopa::sys_rm'
    else
        rm='koopa::rm'
    fi
    if [[ -z "${dict[link_app]}" ]]
    then
        if [[ "${dict[shared]}" -eq 0 ]] || koopa::is_macos
        then
            dict[link_app]=0
        else
            dict[link_app]=1
        fi
    fi
    if [[ -z "${dict[name_fancy]}" ]]
    then
        dict[name_fancy]="${dict[name]}"
    fi
    koopa::uninstall_start "${dict[name_fancy]}" "${dict[prefix]}"
    "$rm" \
        "${dict[prefix]}" \
        "${dict[opt_prefix]}/${dict[name]}"
    if [[ "${dict[link_app]}" -eq 1 ]]
    then
        koopa::alert "Deleting broken symlinks in '${dict[make_prefix]}'."
        koopa::delete_broken_symlinks "${dict[make_prefix]}"
    fi
    koopa::uninstall_success "${dict[name_fancy]}"
    return 0
}

koopa::unlink_app() { # {{{1
    # """
    # Unlink an application.
    # @note Updated 2021-06-07.
    # """
    local make_prefix
    make_prefix="$(koopa::make_prefix)"
    if koopa::is_macos
    then
        koopa::alert_note "Linking into '${make_prefix}' is not \
supported on macOS."
        return 0
    fi
    koopa::r_script 'unlinkApp' "$@"
    return 0
}
