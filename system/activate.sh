#!/usr/bin/env sh

# Activate koopa in the current shell.

# How to check if a variable exists across shell types.
# https://unix.stackexchange.com/questions/212183

# Early return if already activated.
[[ -v $KOOPA_PLATFORM ]] && exit 0

# Check for supported operating system.
# Alternatively, can match against $OSTYPE.
# FIXME This won't work for fish...
case "$(uname -s)" in
    Darwin ) export MACOS=1 && export UNIX=1;;
     Linux ) export LINUX=1 && export UNIX=1;;
         * ) echo "Unsupported operating system."; return 1;;
esac

KOOPA_VERSION="0.2.3"
KOOPA_DATE="2019-01-01"

# Always check for bash, even if it's not the current shell.
# https://stackoverflow.com/questions/16989598
# https://stackoverflow.com/questions/4023830
# SC2071: < is for string comparisons. Use -lt instead.
bash_version="$BASH_VERSINFO[0]"
if [[ -z "$bash_version" ]]
then
    bash_version=$(bash --version | head -n1 | cut -f 4 -d " " | cut -d "-" -f 1  | cut -d "(" -f 1)
fi
if [[ ${bash_version:0:1} -lt 4 ]]
then
    echo "bash version: $bash_version"
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
    echo '   bash --version'
    return 1
fi
# unset -v bash_version

if [[ "$shell" == "bash" ]] || [[ "$shell" == "zsh" ]]
then
    export KOOPA_VERSION
    export KOOPA_DATE
    export KOOPA_EXE
    export KOOPA_BIN_DIR
    export KOOPA_BASE_DIR
    export KOOPA_FUNCTIONS_DIR
    export KOOPA_SYSTEM_DIR
fi

quiet_which() {
    command -v "$1" >/dev/null 2>&1
}

# PATH modifiers
# https://github.com/MikeMcQuaid/dotfiles/blob/master/shrc.sh

remove_from_path() {
    [ -d "$1" ] || return
    # Doesn't work for first item in the PATH.
    export PATH=${PATH//:$1/}
}

add_to_path_start() {
    [ -d "$1" ] || return
    remove_from_path "$1"
    export PATH="$1:$PATH"
}

add_to_path_end() {
    [ -d "$1" ] || return
    remove_from_path "$1"
    export PATH="$PATH:$1"
}

force_add_to_path_start() {
    remove_from_path "$1"
    export PATH="$1:$PATH"
}

# python (any version).
# Consider requiring >= 3 in a future update.
if ! quiet_which python
then
    echo "koopa requires python."
    return 1
fi

# Now that we know Python is installed, we can return the platform string.
KOOPA_PLATFORM="$( python -mplatform )"
export KOOPA_PLATFORM

# Don't re-activate for a subshell (i.e. an HPC interactive job).
# if [ -n ${HPC_INTERACTIVE_QUEUE+x} ]
# then
#     return 0
# fi

# Check if this is a login and/or interactive shell.
[[ "$0" == "-bash" ]] && export LOGIN_BASH=1
echo "$-" | grep -q "i" && export INTERACTIVE_BASH=1

# Load secrets.
# shellcheck source=/dev/null
[[ -f "${HOME}/.secrets" ]] && source "${HOME}/.secrets"

# Fix systems missing $USER.
[[ -z "$USER" ]] && USER="$(whoami)" && export USER

# Microsoft Azure VM.
[[ $HOSTNAME =~ "azlabapp" ]] && export AZURE=1

# Harvard O2 cluster
if [[ $HMS_CLUSTER == "o2" ]] && \
   [[ $HOSTNAME =~ .o2.rc.hms.harvard.edu ]] && \
   [[ -d /n/data1/ ]]
then
    export HARVARD_O2=1
fi

# Harvard Odyssey cluster
if [[ $HOSTNAME =~ .rc.fas.harvard.edu ]] && \
   [[ -d /n/regal/ ]]
then
    export HARVARD_ODYSSEY=1
fi

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
if [[ -n $MACOS ]]
then
    add_to_path_start "${KOOPA_BIN_DIR}/macos"
fi

# Include Aspera Connect binaries in PATH, if defined.
if [[ -z $ASPERACONNECT_EXE ]]
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
if [[ -z $BCBIO_EXE ]]
then
    if [[ -n $HARVARD_O2 ]]
    then
        export BCBIO_EXE="/n/app/bcbio/tools/bin/bcbio_nextgen.py"
    elif [[ -n $HARVARD_ODYSSEY ]]
    then
        export BCBIO_EXE="/n/regal/hsph_bioinfo/bcbio_nextgen/bin/bcbio_nextgen.py"
    fi
fi
if [[ -n $BCBIO_EXE ]]
then
    # Check that path is valid.
    if [[ -f "$BCBIO_EXE" ]]
    then
        bcbio_bin_dir="$( dirname "$BCBIO_EXE" )"
        export PATH="${bcbio_bin_dir}:${PATH}"
        unset -v PYTHONHOME PYTHONPATH
        unset -v bcbio_bin_dir
    else
        printf "bcbio does not exist at:\n%s\n" "$BCBIO_EXE"
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
if [[ -z $CONDA_EXE ]]
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
if [[ -n $CONDA_EXE ]]
then
    # Check that path is valid.
    if [[ -f "$CONDA_EXE" ]]
    then
        # Activate the default environment automatically, if requested.
        # Note that this will get redefined as "base" when conda is activated,
        # so define as an internal variable here.
        if [[ -n $CONDA_DEFAULT_ENV ]]
        then
            conda_env="$CONDA_DEFAULT_ENV"
        fi
        conda_bin_dir="$( dirname "$CONDA_EXE" )"
        # shellcheck source=/dev/null
        source "${conda_bin_dir}/activate"
        if [[ -n $conda_env ]]
        then
            conda activate "$conda_env"
        fi
        unset -v conda_bin_dir conda_env
    else
        printf "conda does not exist at:\n%s\n" "$CONDA_EXE"
        # Don't exit here, as this can cause SSH lockout.
    fi
fi

# Load an SSH key automatically, using SSH_KEY global variable.
# NOTE: SCP will fail unless this is interactive only.
# ssh-agent will prompt for password if there's one set.
# To change SSH key passphrase: ssh-keygen -p
if [[ -n $INTERACTIVE_BASH ]] && [[ -n $LINUX ]]
then
    # If the user hasn't requested a specific SSH key, look for the default.
    if [[ -z $SSH_KEY ]]
    then
        export SSH_KEY="${HOME}/.ssh/id_rsa"
    fi
    if [[ -r "$SSH_KEY" ]]; then
        # This step is necessary to start the ssh agent.
        eval "$(ssh-agent -s)"
        # Now we're ready to add the key.
        ssh-add "$SSH_KEY"
    fi
fi

# Count CPUs for Make jobs.
if [[ -n $MACOS ]]
then
    CPUCOUNT="$(sysctl -n hw.ncpu)"
elif [[ -n $LINUX ]]
then
    CPUCOUNT="$(getconf _NPROCESSORS_ONLN)"
else
    CPUCOUNT=1
fi
export CPUCOUNT

# Current date (e.g. 2018-01-01).
TODAY=$(date +%Y-%m-%d)
export TODAY

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
