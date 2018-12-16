#!/usr/bin/env bash
# Activate koopa in the current shell.



# NOTE: Don't attempt to enable strict mode (i.e. set -euo pipefail) here.
# Otherwise, you can get locked out of a remote SSH server.



# Don't re-activate for HPC interactive job.
if [[ -n ${HPC_INTERACTIVE_JOB+x} ]]; then
    exit 0
fi



# Check if this is a login and/or interactive shell.
[ "$0" = "-bash" ] && export LOGIN_BASH=1
echo "$-" | grep -q "i" && export INTERACTIVE_BASH=1



# Check for supported operating system.
# Alternatively can use `$(uname -s)`
case "$OSTYPE" in
    darwin* ) os="MACOS";;
     linux* ) os="LINUX";;
          * ) echo "Unsupported system: ${OSTYPE}"; exit 1;;
esac



# Fix systems missing $USER.
[ -z "$USER" ] && export USER="$(whoami)"



# Define useful OS variables.
# These are adapted from Mike McQuaid's dotfiles config.
# Apple macOS
[[ "$(uname -s)" == "Darwin" ]] && export MACOS=1 && export UNIX=1
# Linux
[[ "$(uname -s)" = "Linux" ]] && export LINUX=1 && export UNIX=1
# Microsoft Windows
uname -s | grep -q "_NT-" && export WINDOWS=1
# Ubuntu on Windows
grep -q "Microsoft" /proc/version 2>/dev/null && export UBUNTU_ON_WINDOWS=1
# Microsoft Azure VM
[[ $HOSTNAME =~ "azlabapp" ]] && export AZURE=1
# Harvard O2 cluster
if [[ $HMS_CLUSTER == "o2" ]] && \
   [[ $HOSTNAME =~ ".o2.rc.hms.harvard.edu" ]] && \
   [[ -d /n/data1/ ]]
then
    export HARVARD_O2=1
fi
# Harvard Odyssey cluster
if [[ $HOSTNAME =~ ".rc.fas.harvard.edu" ]] && \
   [[ -d /n/regal/ ]]
then
    export HARVARD_ODYSSEY=1
fi



# Check dependencies before proceeding.
# bash >= 4.
if [[ -z $BASH_VERSION ]]
then
    echo 'Failed to detect bash version ($BASH_VERSION).'
    echo "Check your configuration."
    exit 1
elif [[ $BASH_VERSION < 4 ]]
then
    echo "bash version: $BASH_VERSION"
    echo ""
    echo "koopa requires bash >= v4 to be installed."
    echo ""
    echo "Running macOS?"
    echo "Apple refuses to include a modern version due to the license."
    echo ""
    echo "Here's how to upgrade it using Homebrew:"
    echo "1. Install Homebrew."
    echo "   https://brew.sh/"
    echo "2. Install bash."
    echo "   brew install bash"
    echo "3. Update list of acceptable shells."
    echo "   Requires sudo."
    echo "   Add /usr/local/bin/bash to /etc/shells."
    echo "4. Update default shell."
    echo "   chsh -s /usr/local/bin/bash $USER"
    echo "5. Reload the shell and check bash version."
    echo '   echo $BASH_VERSION'
    exit 1
fi



# python (any version).
# Consider requiring >= 3 in a future update.
if ! quiet_which python
then
    echo "koopa requires python to be installed."
    exit 1
fi



# Now that we know Python is installed, we can return the platform string.
export KOOPA_PLATFORM="$( python -mplatform )"



# Export local user binaries, if directories exist.
dir="${HOME}/.local/bin"
if [[ -d "$dir" ]] && [[ ":$PATH:" != *":${dir}:"* ]]
then
    add_to_path_start "$dir"
fi

dir="${HOME}/bin"
if [[ -d "$dir" ]] && [[ ":$PATH:" != *":${dir}:"* ]]
then
    add_to_path_start "$dir"
fi
unset -v dir



# Export platform-agnostic binaries.
# These essentially are functions that we're exporting to PATH.
add_to_path_start "$KOOPA_BIN_DIR"



# Export additional OS-specific binaries.
# FIXME SIMPLIFY TO MACOS=1
if [[ "$KOOPA_PLATFORM" =~ "Darwin"* ]]
then
    # macOS
    add_to_path_start "${KOOPA_BIN_DIR}/macos"
fi



# Include Aspera Connect binaries in PATH, if defined.
if [[ -z ${ASPERACONNECT_EXE+x} ]]
then
    aspera_exe="${HOME}/.aspera/connect/bin/asperaconnect"
    if [[ -f "$aspera_exe" ]]
    then
        export ASPERACONNECT_EXE="$aspera_exe"
        unset -v aspera_exe
    else
        ASPERACONNECT_EXE=0
    fi
fi
if [[ -f "ASPERACONNECT_EXE" ]]
then
    aspera_bin_dir="$( dirname "$ASPERACONNECT_EXE" )"
    export PATH="${aspera_bin_dir}:${PATH}"
    unset -v aspera_bin_dir
fi



# Include bcbio toolkit binaries in PATH, if defined.
# Attempt to locate bcbio installation automatically on supported platforms.
if [[ -z ${BCBIO_EXE+x} ]]
then
    if [[ -n "$HARVARD_O2" ]]
    then
        export BCBIO_EXE="/n/app/bcbio/tools/bin/bcbio_nextgen.py"
    elif [[ -n "$HARVARD_ODYSSEY" ]]
    then
        export BCBIO_EXE="/n/regal/hsph_bioinfo/bcbio_nextgen/bin/bcbio_nextgen.py"
    fi
fi
if [[ -n ${BCBIO_EXE+x} ]]
then
    # Check that path is valid.
    if [[ -f "$BCBIO_EXE" ]]
    then
        bcbio_bin_dir="$( dirname "$BCBIO_EXE" )"
        export PATH="${bcbio_bin_dir}:${PATH}"
        unset -v PYTHONHOME PYTHONPATH
        unset -v bcbio_bin_dir
    else
        printf "bcbio does not exist at:\n${BCBIO_EXE}\n"
        # Don't exit here as this can cause SSH lockout.
    fi
fi



# Activate Conda.
# Note that it's no longer recommended to export conda in PATH.
# Attempt to locate automatically when not manually defined.
# Priority:
# 1. User anaconda3
# 2. User miniconda3
# 3. Shared anaconda3
# 4. Shared miniconda3
if [[ -z ${CONDA_EXE+x} ]]
then
    if [[ -f "${HOME}/anaconda3/bin/conda" ]]
    then
        export CONDA_EXE="${HOME}/anaconda3/bin/conda"
    elif [[ -f "${HOME}/miniconda3/bin/conda" ]]
    then
        export CONDA_EXE="${HOME}/miniconda3/bin/conda"
    elif [[ -f "/usr/local/bin/anaconda3/bin/conda" ]]
    then
        export CONDA_EXE="/usr/local/bin/anaconda3/bin/conda"
    
    elif [[ -f "/usr/local/bin/miniconda3/bin/conda" ]]
    then
        export CONDA_EXE="/usr/local/bin/miniconda3/bin/conda"
    fi
fi
if [[ -n ${CONDA_EXE+x} ]]
then
    # Check that path is valid.
    if [[ -f "$CONDA_EXE" ]]
    then
        conda_bin_dir="$( dirname "$CONDA_EXE" )"
        source "${conda_bin_dir}/activate"
        unset -v conda_bin_dir
    else
        printf "conda does not exist at:\n${CONDA_EXE}\n"
        # Don't exit here as this can cause SSH lockout.
    fi
fi



# Load an SSH key automatically, using SSH_KEY global variable.
# NOTE: SCP will fail unless this is interactive only.
# ssh-agent will prompt for password if there's one set.
# To change SSH key passphrase: ssh-keygen -p
if [[ -n "$INTERACTIVE_BASH" ]] && [[ -n "$LINUX" ]]
then
    # If the user hasn't requested a specific SSH key, look for the default.
    if [[ -z ${SSH_KEY+x} ]]
    then
        export SSH_KEY="${HOME}/.ssh/id_rsa"
    fi
    if [ -r "$SSH_KEY" ]; then
        # This step is necessary to start the ssh agent.
        eval "$(ssh-agent -s)"
        # Now we're ready to add the key.
        ssh-add "$SSH_KEY"
    fi
fi



# Count CPUs for Make jobs.
if [[ -n "$MACOS" ]]
then
    export CPUCOUNT="$(sysctl -n hw.ncpu)"
elif [[ -n "$LINUX" ]]
then
    export CPUCOUNT="$(getconf _NPROCESSORS_ONLN)"
else
    export CPUCOUNT=1
fi



# Current date (e.g. 2018-01-01).
export TODAY=$(date +%Y-%m-%d)

# R environmental variables.
export R_DEFAULT_PACKAGES="stats,graphics,grDevices,utils,datasets,methods,base"

# Genome build versions.
export ENSEMBL_RELEASE="94"
export ENSEMBL_RELEASE_URL="ftp://ftp.ensembl.org/pub/release-${ENSEMBL_RELEASE}"
export GENCODE_RELEASE="29"
export FLYBASE_RELEASE_DATE="FB2018_05"
export FLYBASE_RELEASE_VERSION="r6.24"
export FLYBASE_RELEASE_URL="ftp://ftp.flybase.net/releases/${FLYBASE_RELEASE_DATE}/dmel_${FLYBASE_RELEASE_VERSION}"
export WORMBASE_RELEASE_VERSION="WS266"
