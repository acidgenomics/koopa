#!/usr/bin/env bash

koopa::find_cellar_version() { # {{{1
    # """
    # Find cellar installation directory.
    # @note Updated 2020-06-30.
    # """
    koopa::assert_has_args "$#"
    local name
    name="${1:?}"
    local prefix
    prefix="$(koopa::cellar_prefix)"
    koopa::assert_is_dir "$prefix"
    prefix="${prefix}/${name}"
    koopa::assert_is_dir "$prefix"
    local x
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

koopa::install_cellar() { # {{{1
    # """
    # Install cellar program.
    # @note Updated 2020-06-29.
    # """
    koopa::assert_has_args "$#"
    koopa::assert_is_linux
    koopa::assert_has_no_envs
    local gnu_mirror include_dirs jobs link_args link_cellar make_prefix name \
        name_fancy pass_args prefix reinstall script_name script_path tmp_dir \
        version
    include_dirs=
    link_cellar=1
    name_fancy=
    reinstall=0
    script_name=
    version=
    # Define passthrough args array, for looping.
    pass_args=()
    while (("$#"))
    do
        case "$1" in
            --cellar-only)
                link_cellar=0
                pass_args+=("--cellar-only")
                shift 1
                ;;
            --include-dirs=*)
                include_dirs="${1#*=}"
                shift 1
                ;;
            --include-dirs)
                include_dirs="$2"
                shift 2
                ;;
            --name=*)
                name="${1#*=}"
                shift 1
                ;;
            --name)
                name="$2"
                shift 2
                ;;
            --name-fancy=*)
                name_fancy="${1#*=}"
                shift 1
                ;;
            --name-fancy)
                name_fancy="$2"
                shift 2
                ;;
            --reinstall)
                reinstall=1
                pass_args+=("--reinstall")
                shift 1
                ;;
            --script-name=*)
                script_name="${1#*=}"
                shift 1
                ;;
            --script-name)
                script_name="$2"
                shift 2
                ;;
            --version=*)
                version="${1#*=}"
                shift 1
                ;;
            --version)
                version="$2"
                shift 2
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
    prefix="$(koopa::cellar_prefix)/${name}/${version}"
    # shellcheck disable=SC2034
    make_prefix="$(koopa::make_prefix)"
    if [[ "$reinstall" -eq 1 ]]
    then
        koopa::rm "$prefix"
        koopa::remove_broken_symlinks "$make_prefix"
    fi
    koopa::exit_if_dir "$prefix"
    koopa::install_start "$name_fancy" "$version" "$prefix"
    tmp_dir="$(koopa::tmp_dir)"
    (
        # shellcheck disable=SC2034
        gnu_mirror="$(koopa::gnu_mirror)"
        # shellcheck disable=SC2034
        jobs="$(koopa::cpu_count)"
        koopa::cd_tmp_dir "$tmp_dir"
        script_path="$(koopa::prefix)/os/linux/include/cellar/${script_name}.sh"
        # shellcheck source=/dev/null
        source "$script_path" "${pass_args[@]:-}"
    ) 2>&1 | tee "$(koopa::tmp_log_file)"
    rm -fr "$tmp_dir"
    koopa::system_set_permissions --recursive "$prefix"
    if [[ "$link_cellar" -eq 1 ]]
    then
        link_args=(
            "--name=${name}"
            "--version=${version}"
        )
        if [[ -n "$include_dirs" ]]
        then
            link_args+=("--include-dirs=${include_dirs}")
        fi
        koopa::link_cellar "${link_args[@]}"
    fi
    koopa::install_success "$name_fancy"
    return 0
}

koopa::link_cellar() { # {{{1
    # """
    # Symlink cellar into build directory.
    # @note Updated 2020-06-20.
    #
    # If you run into permissions issues during link, check the build prefix
    # permissions. Ensure group is not 'root', and that group has write access.
    #
    # This can be reset easily with 'koopa::system_set_permissions'.
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
    koopa::assert_is_linux
    local cellar_prefix cellar_subdirs cp_flags include_dirs make_prefix name \
        pos verbose version
    include_dirs=
    verbose=0
    version=
    pos=()
    while (("$#"))
    do
        case "$1" in
            --include-dirs=*)
                include_dirs="${1#*=}"
                shift 1
                ;;
            --include-dirs)
                include_dirs="$2"
                shift 2
                ;;
            --name=*)
                name="${1#*=}"
                shift 1
                ;;
            --name)
                name="$2"
                shift 2
                ;;
            --verbose)
                verbose=1
                shift 1
                ;;
            --version=*)
                version="${1#*=}"
                shift 1
                ;;
            --version)
                version="$2"
                shift 2
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
    koopa::system_set_permissions --recursive "$cellar_prefix"
    koopa::remove_broken_symlinks "$cellar_prefix"
    koopa::remove_broken_symlinks "$make_prefix"
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
    cp_flags=("-frs")
    [[ "$verbose" -eq 1 ]] && cp_flags+=("-v")
    cp "${cp_flags[@]}" "${cellar_subdirs[@]}" -t "${make_prefix}/"
    koopa::is_shared_install && koopa::update_ldconfig
    return 0
}
