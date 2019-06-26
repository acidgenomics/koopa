#!/bin/sh
# shellcheck disable=SC2236

# Put useful conda environments in PATH.
# Modified 2019-06-25.

_koopa_is_installed conda || return 0

# Early return if local conda environments aren't configured.
prefix="$(_koopa_conda_prefix)"

# Early return if conda local environment directory is empty.
if [ ! -d "$prefix" ] || [ -z "$(ls "$prefix")" ]
then
    unset -v prefix
    return
fi

env_list="$(_koopa_conda_env_list)"

_koopa_add_conda_env_to_path pandoc "$env_list"
_koopa_add_conda_env_to_path texlive-core "$env_list"

unset -v env_list
