#!/bin/sh

# Put useful conda environments in PATH.
# Updated 2019-10-21.

_koopa_is_installed conda || return 0

_koopa_add_conda_env_to_path pandoc
# > _koopa_add_conda_env_to_path texlive-core
