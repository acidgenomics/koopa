#!/bin/sh

# Activate Conda.
# Updated 2019-06-29.

# Note that conda must be reactivated inside of tmux.

# It's no longer recommended to directly export conda in `$PATH`.
# Instead source the `activate` script.
#
# Note that this code will attempt to locate the installation automatically,
# unless `$CONDA_EXE` is set.
#
# Note that an environment will only be activated when `$CONDA_DEFAULT_ENV` is
# set prior to running this code. Attempts to activate "base" will be ignored.

# Conda doesn't currently support ksh, and fish support is buggy.
_koopa_shell | grep -Eq "^(bash|zsh)$" || return 0

# Attempt to detect the installation path automatically, if necessary.
# Use `$CONDA_EXE` to manually set the path, for non-standard installs.

# Priority:
# - ~/.local/anaconda3
# - ~/.local/miniconda3
# - ~/anaconda3
# - ~/miniconda3
# - /usr/local/anaconda3
# - /usr/local/miniconda3

if [ -z "${CONDA_EXE:-}" ]
then
    if [ -d "${HOME}/.local/anaconda3" ]
    then
        conda_home="${HOME}/.local/anaconda3"
    elif [ -d "${HOME}/.local/miniconda3" ]
    then
        conda_home="${HOME}/.local/miniconda3"
    elif [ -d "${HOME}/anaconda3" ]
    then
        conda_home="${HOME}/anaconda3"
    elif [ -d "${HOME}/miniconda3" ]
    then
        conda_home="${HOME}/miniconda3"
    elif [ -d "/usr/local/anaconda3" ]
    then
        conda_home="/usr/local/anaconda3"
    elif [ -d "/usr/local/miniconda3" ]
    then
        conda_home="/usr/local/miniconda3"
    else
        conda_home=
    fi

    if [ -d "${conda_home}" ]
    then
        export CONDA_EXE="${conda_home}/bin/conda"
    else
        CONDA_EXE=
    fi
    unset -v conda_home
fi

# Run activation script, if accessible.
if [ -x "$CONDA_EXE" ]
then
    # Fix for unbound variables in activate/deactivate scripts.
    if [ -n "${KOOPA_TEST:-}" ]
    then
        set +u
    fi

    bin_dir="$(dirname "$CONDA_EXE")"
    # shellcheck source=/dev/null
    . "${bin_dir}/activate"
    unset -v bin_dir

    # Keep conda accessible but close out of base environment.
    # > conda deactivate

    if [ -n "${KOOPA_TEST:-}" ]
    then
        set -u
    fi
else
    unset -v CONDA_EXE
fi
