#!/usr/bin/env bash

koopa::linux_delete_broken_cellar_symlinks() { # {{{1
    # """
    # Delete broken cellar symlinks.
    # @note Updated 2020-11-18.
    # """
    koopa::assert_has_no_args "$#"
    koopa::assert_is_linux
    koopa::delete_broken_symlinks "$(koopa::make_prefix)"
    return 0
}

koopa::linux_find_cellar_symlinks() { # {{{1
    # """
    # Find cellar symlinks.
    # @note Updated 2020-11-17.
    # """
    local cellar_prefix koopa_prefix make_prefix file links name version
    koopa::assert_has_args "$#"
    koopa::assert_has_args_le "$#" 2
    koopa::assert_is_linux
    koopa::assert_is_installed find sort tail
    name="${1:?}"
    version="${2:-}"
    koopa_prefix="$(koopa::prefix)"
    make_prefix="$(koopa::make_prefix)"
    # Automatically detect version, if left unset.
    cellar_prefix="$(koopa::cellar_prefix)/${name}"
    koopa::assert_is_dir "$cellar_prefix"
    if [[ -n "$version" ]]
    then
        cellar_prefix="${cellar_prefix}/${version}"
    else
        cellar_prefix="$( \
            find "$cellar_prefix" -maxdepth 1 -type d \
            | sort \
            | tail -n 1 \
        )"
    fi
    # Pipe GNU find into array.
    readarray -t links <<< "$( \
        find -L "$make_prefix" \
            -type f \
            -path "${cellar_prefix}/*" \
            ! -path "$koopa_prefix" \
            -print0 \
        | sort -z \
    )"
    # Replace the cellar prefix with our build prefix.
    for file in "${links[@]}"
    do
        koopa::print "${file//$cellar_prefix/$make_prefix}"
    done
    return 0
}

koopa::linux_link_cellar() { # {{{1
    # """
    # Symlink cellar into build directory.
    # @note Updated 2020-11-18.
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
    # koopa::link_cellar emacs 26.3
    # """
    local cellar_prefix cellar_subdirs cp_flags include_dirs make_prefix name \
        pos version
    koopa::assert_is_linux
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
    koopa::assert_has_no_envs
    make_prefix="$(koopa::make_prefix)"
    koopa::assert_is_dir "$make_prefix"
    cellar_prefix="$(koopa::cellar_prefix)"
    koopa::assert_is_dir "$cellar_prefix"
    cellar_prefix="${cellar_prefix}/${name}"
    koopa::assert_is_dir "$cellar_prefix"
    [[ -z "$version" ]] && version="$(koopa::find_cellar_version "$name")"
    cellar_prefix="${cellar_prefix}/${version}"
    koopa::assert_is_dir "$cellar_prefix"
    koopa::h2 "Linking '${cellar_prefix}' in '${make_prefix}'."
    koopa::sys_set_permissions -r "$cellar_prefix"
    koopa::delete_broken_symlinks "$cellar_prefix"
    koopa::delete_broken_symlinks "$make_prefix"
    cellar_subdirs=()
    if [[ -n "$include_dirs" ]]
    then
        IFS=',' read -r -a cellar_subdirs <<< "$include_dirs"
        cellar_subdirs=("${cellar_subdirs[@]/^/${cellar_prefix}}")
        for i in "${!cellar_subdirs[@]}"
        do
            cellar_subdirs[$i]="${cellar_prefix}/${cellar_subdirs[$i]}"
        done
    else
        readarray -t cellar_subdirs <<< "$( \
            find "$cellar_prefix" \
                -mindepth 1 \
                -maxdepth 1 \
                -type d \
                -print \
            | sort \
        )"
    fi
    # Copy as symbolic links.
    cp_flags=(
        '-s'
        '-t' "${make_prefix}"
    )
    koopa::is_shared_install && cp_flags+=('-S')
    koopa::cp "${cp_flags[@]}" "${cellar_subdirs[@]}"
    # Note that this step will fail on macOS.
    koopa::is_shared_install && koopa::update_ldconfig
    koopa::success "Successfully linked '${name}'."
    return 0
}
