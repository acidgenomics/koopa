#!/usr/bin/env bash

_koopa_find_cellar_version_dir() {  # {{{1
    # """
    # Find cellar installation directory.
    # @note Updated 2020-05-08.
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
    _koopa_print "$x"
}

_koopa_link_cellar() {  # {{{1
    # """
    # Symlink cellar into build directory.
    # @note Updated 2020-05-09.
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

    local name
    name="${1:?}"

    # Version is optional and will be detected automatically if necessary.
    local version
    version="${2:-}"

    local make_prefix
    make_prefix="$(_koopa_make_prefix)"
    _koopa_assert_is_dir "$make_prefix"

    local cellar_prefix
    cellar_prefix="$(_koopa_cellar_prefix)"
    _koopa_assert_is_dir "$cellar_prefix"
    cellar_prefix="${cellar_prefix}/${name}"
    _koopa_assert_is_dir "$cellar_prefix"

    # Detect the version automatically, if not specified.
    if [[ -n "$version" ]]
    then
        cellar_prefix="${cellar_prefix}/${version}"
    else
        cellar_prefix="$(_koopa_find_cellar_version_dir "$name" "$version")"
    fi
    _koopa_assert_is_dir "$cellar_prefix"

    _koopa_h2 "Linking '${cellar_prefix}' in '${make_prefix}'."
    _koopa_set_permissions --recursive "$cellar_prefix"
    _koopa_remove_broken_symlinks "$cellar_prefix"
    _koopa_remove_broken_symlinks "$make_prefix"

    local cp_flags
    # Can increase verbosity with '-v' here.
    cp_flags=("-f" "-r" "-s")

    if _koopa_is_shared_install
    then
        sudo cp "${cp_flags[@]}" "${cellar_prefix}/"* "${make_prefix}/".
        _koopa_update_ldconfig
    else
        cp "${cp_flags[@]}" "${cellar_prefix}/"* "${make_prefix}/".
    fi

    return 0
}
