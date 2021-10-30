#!/usr/bin/env bash

koopa::link_app() { # {{{1
    # """
    # Symlink application into build directory.
    # @note Updated 2021-09-21.
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
            # Key-value pairs --------------------------------------------------
            '--include-dirs='*)
                include_dirs="${1#*=}"
                shift 1
                ;;
            '--include-dirs')
                include_dirs="${2:?}"
                shift 2
                ;;
            '--name='*)
                name="${1#*=}"
                shift 1
                ;;
            '--name')
                name="${2:?}"
                shift 2
                ;;
            '--version='*)
                version="${1#*=}"
                shift 1
                ;;
            '--version')
                version="${2:?}"
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
    [[ -n "${1:-}" ]] && name="$1"
    [[ -z "$version" ]] && version="$(koopa::find_app_version "$name")"
    koopa::assert_has_no_envs
    make_prefix="$(koopa::make_prefix)"
    app_prefix="$(koopa::app_prefix)/${name}/${version}"
    koopa::assert_is_dir "$app_prefix" "$make_prefix"
    koopa::link_into_opt "$app_prefix" "$name"
    koopa::is_macos && return 0
    koopa::alert "Linking '${app_prefix}' in '${make_prefix}'."
    koopa::sys_set_permissions --recursive "$app_prefix"
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
        # FIXME Rework using 'koopa::find'.
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
        '--symbolic-link'
        "--target-directory=${make_prefix}"
    )
    koopa::is_shared_install && cp_flags+=('--sudo')
    koopa::cp "${cp_flags[@]}" "${app_subdirs[@]}"
    return 0
}
