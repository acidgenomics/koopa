#!/bin/sh
# shellcheck disable=SC2039



# Avoid setting to `/usr/local/cellar`, as this can conflict with Homebrew.
# Updated 2019-06-27.
_koopa_cellar_prefix() {
    local prefix

    if [ -w "$KOOPA_HOME" ]
    then
        prefix="${KOOPA_HOME}/cellar"
    else
        prefix="${XDG_DATA_HOME}/koopa/cellar"
    fi

    echo "$prefix"
}



# Updated 2019-06-27.
_koopa_conda_env_list() {
    _koopa_is_installed conda || return 1
    conda env list --json
}



# Note that we're allowing env_list passthrough as second positional variable,
# to speed up loading upon activation.
# Updated 2019-06-27.
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



# Updated 2019-06-27.
_koopa_conda_prefix() {
    local prefix
    if [ -w "$KOOPA_HOME" ]
    then
        prefix="${KOOPA_HOME}/conda"
    else
        prefix="${XDG_DATA_HOME}/koopa/conda"
    fi
    echo "$prefix"
}



# Create an internal conda environment.
# Updated 2019-07-10.
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
