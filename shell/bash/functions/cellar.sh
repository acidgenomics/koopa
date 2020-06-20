#!/usr/bin/env bash

_koopa_find_cellar_version() {  # {{{1
    # """
    # Find cellar installation directory.
    # @note Updated 2020-06-20.
    # """
    local name
    name="${1:?}"
    local prefix
    prefix="$(_koopa_cellar_prefix)"
    _koopa_assert_is_dir "$prefix"
    prefix="${prefix}/${name}"
    _koopa_assert_is_dir "$prefix"
    local x
    x="$( \
        find "$prefix" \
            -mindepth 1 \
            -maxdepth 1 \
            -type d \
        | sort \
        | tail -n 1 \
    )"
    _koopa_assert_is_dir "$x"
    x="$(basename "$x")"
    _koopa_print "$x"
}

_koopa_install_cellar() {  # {{{1
    # """
    # Install cellar program.
    # @note Updated 2020-06-20.
    # """
    _koopa_assert_is_linux
    _koopa_assert_has_no_envs
    local link_cellar name name_fancy prefix reinstall tmp_dir version
    link_cellar=1
    name_fancy=
    reinstall=0
    version=
    while (("$#"))
    do
        case "$1" in
            --cellar-only)
                link_cellar=0
                shift 1
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
            *)
                _koopa_invalid_arg "$1"
                ;;
        esac
    done
    _koopa_assert_has_no_args "$@"
    [[ -z "$name_fancy" ]] && name_fancy="$name"
    [[ -z "$version" ]] && version="$(_koopa_variable "$name")"
    prefix="$(_koopa_cellar_prefix)/${name}/${version}"
    [[ "$reinstall" -eq 1 ]] && _koopa_rm "$prefix"
    _koopa_exit_if_dir "$prefix"
    _koopa_install_start "$name_fancy" "$version" "$prefix"
    tmp_dir="$(_koopa_tmp_dir)"
    (
        local gnu_mirror jobs
        # shellcheck disable=SC2034
        gnu_mirror="$(_koopa_gnu_mirror)"
        # shellcheck disable=SC2034
        jobs="$(_koopa_cpu_count)"
        _koopa_cd_tmp_dir "$tmp_dir"
        # shellcheck source=/dev/null
        source "$(_koopa_prefix)/os/linux/include/cellar/${name}.sh"
    ) 2>&1 | tee "$(_koopa_tmp_log_file)"
    rm -fr "$tmp_dir"
    [[ "$link_cellar" -eq 1 ]] && _koopa_link_cellar "$name" "$version"
    _koopa_install_success "$name_fancy"
    return 0
}

# FIXME Need to add option to link specific dirs, e.g. for aws-cli.
# dirs="bin,man"
# FIXME How to split into array by delim?
# FIXME ALLOW NAME TO BE POSITIONAL ARGUMENT.
_koopa_link_cellar() {  # {{{1
    # """
    # Symlink cellar into build directory.
    # @note Updated 2020-06-20.
    #
    # If you run into permissions issues during link, check the build prefix
    # permissions. Ensure group is not 'root', and that group has write access.
    #
    # This can be reset easily with '_koopa_set_permissions'.
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
    # _koopa_link_cellar emacs 26.3
    # """
    _koopa_assert_is_linux
    local cellar_prefix cellar_subdirs include_dirs make_prefix name version
    include_dirs=
    version=
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
            --version=*)
                version="${1#*=}"
                shift 1
                ;;
            --version)
                version="$2"
                shift 2
                ;;
            *)
                _koopa_invalid_arg "$1"
                ;;
        esac
    done
    _koopa_assert_has_no_args "$@"
    _koopa_assert_has_no_envs
    make_prefix="$(_koopa_make_prefix)"
    _koopa_assert_is_dir "$make_prefix"
    cellar_prefix="$(_koopa_cellar_prefix)"
    _koopa_assert_is_dir "$cellar_prefix"
    cellar_prefix="${cellar_prefix}/${name}"
    _koopa_assert_is_dir "$cellar_prefix"
    [[ -z "$version" ]] && version="$(_koopa_find_cellar_version "$name")"
    cellar_prefix="${cellar_prefix}/${version}"
    _koopa_assert_is_dir "$cellar_prefix"
    _koopa_h2 "Linking '${cellar_prefix}' in '${make_prefix}'."
    _koopa_set_permissions --recursive "$cellar_prefix"
    _koopa_remove_broken_symlinks "$cellar_prefix"
    _koopa_remove_broken_symlinks "$make_prefix"
    cellar_subdirs=()
    if [[ -n "$include_dirs" ]]
    then
        IFS=',' read -r -a cellar_subdirs <<< "$include_dirs"
        cellar_subdirs=("${cellar_subdirs[@]/^/${cellar_prefix}}")
    else
        while IFS= read -r -d $'\0'
        do
            cellar_subdirs+=("$REPLY")
        done < <( \
            find "$cellar_prefix" \
                -mindepth 1 \
                -maxdepth 1 \
                -type d \
                -print0 \
            | sort -z \
        )
    fi
    # FIXME
    echo "${cellar_subdirs[@]}"
    return 0
    # FIXME
    cp -frs "${cellar_subdirs[@]}" -t "${make_prefix}/"
    _koopa_is_shared_install && _koopa_update_ldconfig
    return 0
}
