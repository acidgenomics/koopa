#!/bin/sh
# shellcheck disable=SC2039

# Conda functions.
# Modified 2019-06-27.



# Modified 2019-06-27.
_koopa_add_conda_env_to_path() {
    local env_name
    local env_list
    local prefix

    _koopa_is_installed conda || return 1

    env_name="$1"
    env_list="${2:-}"

    prefix="$(_koopa_conda_env_prefix "$env_name" "$env_list")"
    [ -n "$prefix" ] || return 1
    prefix="${prefix}/bin"
    [ -d "$prefix" ] || return 1

    _koopa_add_to_path_start "$prefix"
}



# Create an internal conda environment.
# Modified 2019-07-10.
_koopa_create_conda_env() {
    _koopa_assert_is_installed conda

    local name
    name="$1"

    local app
    app="${2:-$name}"

    local channel
    channel="${3:-conda-forge}"

    local prefix
    prefix="$(_koopa_conda_prefix)"

    conda create -qy \
        -p "${prefix}/envs/${name}" \
        -c "$channel" \
        "$app"
}



# Modified 2019-06-27.
_koopa_conda_env_list() {
    _koopa_is_installed conda || return 1
    conda env list --json
}



# Note that we're allowing env_list passthrough as second positional variable,
# to speed up loading upon activation.
# Modified 2019-06-27.
_koopa_conda_env_prefix() {
    local env_name
    local env_list
    local prefix
    local path

    _koopa_is_installed conda || return 1

    env_name="$1"
    env_list="${2:-}"
    prefix="$(_koopa_conda_prefix)"

    if [ -z "$env_list" ]
    then
        env_list="$(_koopa_conda_env_list)"
    fi

    # Restrict to environments that match internal koopa installs.
    # Early return if no environments are installed.
    env_list="$(echo "$env_list" | grep "$prefix")"
    [ -z "$env_list" ] && return 1

    path="$( \
        echo "$env_list" | \
        grep "/envs/${env_name}" \
    )"
    [ -z "$path" ] && return 1

    echo "$path" | sed -E 's/^.*"(.+)".*$/\1/'
}



# Modified 2019-06-27.
_koopa_link_conda_env() {
    local env_name
    local env_prefix
    local build_prefix

    env_name="$1"
    env_prefix="$(koopa conda-prefix)/envs/${env_name}"
    build_prefix="$(koopa build-prefix)"

    printf "Linking %s in %s.\n" "$env_prefix" "$build_prefix"

    _koopa_build_set_permissions "$env_prefix"

    find "$env_prefix" \
        -maxdepth 1 \
        -mindepth 1 \
        ! -name "*conda*" \
        -print0 |
        xargs -0 -I {} cp -frsv {} "$build_prefix/".

    _koopa_build_set_permissions "$build_prefix"
    _koopa_has_sudo && _koopa_update_ldconfig
}

