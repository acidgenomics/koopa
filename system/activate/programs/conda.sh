#!/bin/sh
# shellcheck disable=SC2236

# Activate Conda
# Modified 2019-06-24.

# It's no longer recommended to directly export conda in `$PATH`.
# Instead source the `activate` script.
#
# Note that this code will attempt to locate the installation automatically,
# unless `$CONDA_EXE` is set.
#
# Note that an environment will only be activated when `$CONDA_DEFAULT_ENV` is
# set prior to running this code. Attempts to activate "base" will be ignored.



# Conda doesn't currently support ksh, and fish support is buggy.
# Only attempt to autoload for bash or zsh.
echo "$(koopa shell)" | grep -Eq "^(bash|zsh)$" || return

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
    fi

    if [ ! -z "${conda_home:-}" ]
    then
        export CONDA_EXE="${conda_home}/bin/conda"
        unset -v conda_home
    fi
fi

# Early return if we don't detect an installation.
[ -z "${CONDA_EXE:-}" ] && return

# Early return with error if conda installation is set but not accessible.
if [ ! -x "$CONDA_EXE" ]
then
    printf "conda does not exist at:\n%s\n" "$CONDA_EXE"
    return 1
fi

# Now we're ready to activate.
conda_bin_dir="$(dirname "$CONDA_EXE")"

# Note that the activation script must run again inside a tmux session.
# shellcheck source=/dev/null
. "${conda_bin_dir}/activate"

unset -v conda_bin_dir
