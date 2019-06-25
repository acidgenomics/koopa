#!/bin/sh
# shellcheck disable=SC2236

# Put useful conda environments in PATH.
# Modified 2019-06-25.

_koopa_is_installed conda || return

# Skip on macOS, where we can use Homebrew instead.
_koopa_is_linux || return

# Early return if conda prefix directory is empty.
prefix="$(koopa conda-prefix)"
if [ -z "$(ls "$prefix")" ]
then
    unset -v prefix
    return
fi

env_list="$(conda env list --json)"

_koopa_add_conda_env_to_path pandoc "$env_list"
_koopa_add_conda_env_to_path texlive-core "$env_list"

unset -v env_list
