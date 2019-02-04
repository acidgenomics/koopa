#!/bin/sh
# shellcheck disable=SC2236

# Activate Conda
#
# Conda doesn't currently support ksh, and fish support is buggy.
# Only attempt to autoload for bash or ksh.
#
# It's no longer recommended to export conda in PATH.
# Attempt to locate automatically when not manually defined.
#
# Attempt to detect conda path automatically, if not set.
#
# Priority:
#
# 1. User anaconda3
#    ~/anaconda3
# 2. User miniconda3
#    ~/miniconda3
# 3. Shared anaconda3
#    /usr/local/bin/anaconda3
# 4. Shared miniconda3
#    /usr/local/bin/miniconda3
#
# Note that an environment will only be activated when CONDA_DEFAULT_ENV
# is defined in the shell variables prior to this step.
#
# Use CONDA_EXE to manually set the path, for non-standard installs.
#
# "$shell" variable inherits from koopa call.
# SC2154: shell is referenced but not assigned.
# shellcheck disable=SC2154
if [ "$shell" = "bash" ] || [ "$shell" = "zsh" ]
then
    if [ -z "$CONDA_EXE" ]
    then
        if [ -f "${HOME}/anaconda3/bin/conda" ]
        then
            export CONDA_EXE="${HOME}/anaconda3/bin/conda"
        elif [ -f "${HOME}/miniconda3/bin/conda" ]
        then
            export CONDA_EXE="${HOME}/miniconda3/bin/conda"
        elif [ -f "/usr/local/bin/anaconda3/bin/conda" ]
        then
            export CONDA_EXE="/usr/local/bin/anaconda3/bin/conda"
        elif [ -f "/usr/local/bin/miniconda3/bin/conda" ]
        then
            export CONDA_EXE="/usr/local/bin/miniconda3/bin/conda"
        fi
    fi
    if [ ! -z "$CONDA_EXE" ]
    then
        # Check that path is valid.
        if [ -f "$CONDA_EXE" ]
        then
            conda_bin_dir="$( dirname "$CONDA_EXE" )"
            # Activate the default environment automatically, if requested.
            # Note that this will get redefined as "base" when conda is
            # activated, so define as an internal variable here.
            conda_env="$CONDA_DEFAULT_ENV"
            # shellcheck source=/dev/null
            . "${conda_bin_dir}/activate"
            if [ ! -z "$conda_env" ]
            then
                conda activate "$conda_env"
            fi
            unset -v conda_bin_dir conda_env
        else
            printf "conda does not exist at:\n%s\n" "$CONDA_EXE"
            # Don't exit here, as this can cause SSH lockout.
        fi
    fi
fi

