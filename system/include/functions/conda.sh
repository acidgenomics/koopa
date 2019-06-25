#!/bin/sh

# Conda functions.
# Modified 2019-06-25.



# Modified 2019-06-25.
_koopa_add_conda_env_to_path() {
    _koopa_is_installed conda || return 1

    local env_name
    env_name="$1"

    local env_list
    env_list="${2:-}"

    local prefix
    prefix="$(_koopa_conda_env_prefix "$env_name" "$env_list")"
    [ ! -z "$prefix" ] || return 1
    prefix="${prefix}/bin"
    [ -d "$prefix" ] || return 1

    _koopa_add_to_path_start "$prefix"
}



# Modified 2019-06-25.
_koopa_create_conda_env() {
    _koopa_assert_is_installed conda

    local name
    name="$1"

    local apps
    apps="${2:-$name}"
    
    local channel
    channel="${3:-conda-forge}"
    
    local prefix
    prefix="$(_koopa_conda_prefix)"

    conda create -qy \
        -p "${prefix}/envs/${name}" \
        -c $channel \
        $apps
}



# Modified 2019-06-25.
_koopa_conda_env_list() {
    _koopa_is_installed conda || return 1
    conda env list --json
}



# Note that we're allowing env_list passthrough as second positional variable,
# to speed up loading upon activation.
# Modified 2019-06-25.
_koopa_conda_env_prefix() {
    _koopa_is_installed conda || return 1

    local env_name
    env_name="$1"

    local env_list
    env_list="${2:-}"

    local prefix
    prefix="$(_koopa_conda_prefix)"

    if [ -z "$env_list" ]
    then
        env_list="$(_koopa_conda_env_list)"
    fi

    # Restrict to environments that match internal koopa installs.
    # Early return if no environments are installed.
    env_list="$(echo "$env_list" | grep "$prefix")"
    [ -z "$env_list" ] && return 1

    local path
    path="$( \
        echo "$env_list" | \
        grep "/envs/${env_name}" \
    )"
    [ -z "$path" ] && return 1

    echo "$path" | sed -E 's/^.*"(.+)".*$/\1/'
}

