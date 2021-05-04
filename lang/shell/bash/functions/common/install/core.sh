#!/usr/bin/env bash

koopa::find_app_version() { # {{{1
    # """
    # Find the latest application version.
    # @note Updated 2020-11-22.
    # """
    local name prefix x
    koopa::assert_has_args "$#"
    name="${1:?}"
    prefix="$(koopa::app_prefix)"
    koopa::assert_is_dir "$prefix"
    prefix="${prefix}/${name}"
    koopa::assert_is_dir "$prefix"
    x="$( \
        find "$prefix" \
            -mindepth 1 \
            -maxdepth 1 \
            -type d \
        | sort \
        | tail -n 1 \
    )"
    koopa::assert_is_dir "$x"
    x="$(basename "$x")"
    koopa::print "$x"
    return 0
}

koopa::install_app() { # {{{1
    # """
    # Install application into a versioned directory structure.
    # @note Updated 2021-04-29.
    # """
    local include_dirs link_args link_app make_prefix name name_fancy \
        prefix reinstall script script_name script_prefix tmp_dir version
    koopa::assert_has_args "$#"
    koopa::assert_has_no_envs
    include_dirs=
    link_app=1
    name_fancy=
    reinstall=0
    script_name=
    script_prefix="$(koopa::prefix)/include/install"
    version=
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
            --name-fancy=*)
                name_fancy="${1#*=}"
                shift 1
                ;;
            --no-link)
                link_app=0
                shift 1
                ;;
            --reinstall|--force)
                reinstall=1
                shift 1
                ;;
            --script-name=*)
                script_name="${1#*=}"
                shift 1
                ;;
            --script-prefix=*)
                script_prefix="${1#*=}"
                shift 1
                ;;
            --version=*)
                version="${1#*=}"
                shift 1
                ;;
            --verbose)
                set -x
                shift 1
                ;;
            "")
                shift 1
                ;;
            *)
                koopa::invalid_arg "$1"
                ;;
        esac
    done
    koopa::assert_has_no_args "$#"
    [[ -z "$name_fancy" ]] && name_fancy="$name"
    [[ -z "$script_name" ]] && script_name="$name"
    [[ -z "$version" ]] && version="$(koopa::variable "$name")"
    if koopa::is_macos
    then
        koopa::assert_is_installed brew
        link_app=0
    fi
    prefix="$(koopa::app_prefix)/${name}/${version}"
    make_prefix="$(koopa::make_prefix)"
    [[ "$reinstall" -eq 1 ]] && koopa::sys_rm "$prefix"
    if [[ -d "$prefix" ]]
    then
        koopa::alert_note "${name_fancy} already installed at '${prefix}'."
        return 0
    fi
    koopa::install_start "$name_fancy" "$version" "$prefix"
    tmp_dir="$(koopa::tmp_dir)"
    (
        koopa::cd "$tmp_dir"
        # This is intended primarily for Bash, Fish, Zsh install scripts.
        export INSTALL_LINK_APP="$link_app"
        export INSTALL_NAME="$name"
        export INSTALL_PREFIX="$prefix"
        export INSTALL_VERSION="$version"
        # FIXME SWITCH TO RUNNING 'koopa:::install_XXX' instead of sourcing
        # an external script file.
        koopa::stop 'FIXME'
        script="${script_prefix}/${script_name}.sh"
        koopa::assert_is_file "$script"
        # shellcheck source=/dev/null
        . "$script"
    ) 2>&1 | tee "$(koopa::tmp_log_file)"
    koopa::rm "$tmp_dir"
    koopa::sys_set_permissions -r "$prefix"
    koopa::link_into_opt "$prefix" "$name"
    if [[ "$link_app" -eq 1 ]]
    then
        koopa::delete_broken_symlinks "$make_prefix"
        link_args=(
            "--name=${name}"
            "--version=${version}"
        )
        if [[ -n "$include_dirs" ]]
        then
            link_args+=("--include-dirs=${include_dirs}")
        fi
        # We're including the 'true' catch here to avoid cp issues on Arch.
        koopa::link_app "${link_args[@]}" || true
    fi
    if koopa::is_shared_install && koopa::is_installed ldconfig
    then
        sudo ldconfig
    fi
    koopa::install_success "$name_fancy" "$prefix"
    return 0
}

koopa::link_app() { # {{{1
    # """
    # Symlink application into build directory.
    # @note Updated 2021-04-26.
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
    local app_prefix app_subdirs cp_flags include_dirs make_prefix name \
        pos version
    include_dirs=
    version=
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
            find "$app_prefix" -mindepth 1 -maxdepth 1 -type d -print \
            | sort \
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
    # @note Updated 2021-02-15.
    # """
    koopa::assert_has_args_eq "$#" 2
    local opt_prefix source_dir target_dir
    source_dir="${1:?}"
    opt_prefix="$(koopa::opt_prefix)"
    [[ ! -d "$opt_prefix" ]] && koopa::mkdir "$opt_prefix"
    target_dir="${opt_prefix}/${2:?}"
    koopa::alert "Linking '${source_dir}' in '${target_dir}'."
    [[ ! -d "$source_dir" ]] && koopa::mkdir "$source_dir"
    koopa::rm "$target_dir"
    koopa::sys_set_permissions "$opt_prefix"
    koopa::ln "$source_dir" "$target_dir"
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
    koopa::rscript 'pruneApps' "$@"
    return 0
}

koopa::unlink_app() { # {{{1
    # """
    # Unlink an application.
    # @note Updated 2021-01-04.
    # """
    if koopa::is_macos
    then
        koopa::alert_note 'App links are not supported on macOS.'
        return 0
    fi
    koopa::rscript 'unlinkApp' "$@"
    return 0
}
