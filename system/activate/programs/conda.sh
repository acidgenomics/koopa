#!/bin/sh
# shellcheck disable=SC2236

# Activate Conda
# Modified 2019-06-21.

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
# 1. User anaconda3
#    ~/anaconda3
# 2. User miniconda3
#    ~/miniconda3
# 3. Shared anaconda3
#    /usr/local/anaconda3
# 4. Shared miniconda3
#    /usr/local/miniconda3

if [ -z "${CONDA_EXE:-}" ]
then
    if [ -f "${HOME}/anaconda3/bin/conda" ]
    then
        export CONDA_EXE="${HOME}/anaconda3/bin/conda"
    elif [ -f "${HOME}/miniconda3/bin/conda" ]
    then
        export CONDA_EXE="${HOME}/miniconda3/bin/conda"
    elif [ -f "/usr/local/anaconda3/bin/conda" ]
    then
        export CONDA_EXE="/usr/local/anaconda3/bin/conda"
    elif [ -f "/usr/local/miniconda3/bin/conda" ]
    then
        export CONDA_EXE="/usr/local/miniconda3/bin/conda"
    fi
fi

if [ -z "${CONDA_EXE:-}" ]
then
    # Early return if we don't detect an installation.
    return 0
elif [ ! -x "$CONDA_EXE" ]
then
    # Early return with error if conda installation is set but not accessible.
    printf "conda does not exist at:\n%s\n" "$CONDA_EXE"
    return 1
fi

# Now we're ready to activate.
conda_bin_dir="$(dirname "$CONDA_EXE")"

# Note that the activation script must run again inside a tmux session.
# shellcheck source=/dev/null
. "${conda_bin_dir}/activate"

unset -v conda_bin_dir conda_env
