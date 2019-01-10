#!/bin/sh
# shellcheck disable=SC2236

# SC2236: zsh doesn't handle `-n` flag in place of `! -z` correctly in POSIX
# mode using `[` instead of `[[`.



# Activate koopa in the current shell.

# POSIX sh tricks
# http://www.etalabs.net/sh_tricks.html



# Early return if already activated.
[ ! -z "$KOOPA_PLATFORM" ] && return



# Check for supported operating system.
# Alternatively, can match against $OSTYPE.
case "$(uname -s)" in
    Darwin) export MACOS=1 && export UNIX=1;;
     Linux) export LINUX=1 && export UNIX=1;;
         *) echo "Unsupported operating system."; return 1;;
esac



# Always check for bash, even if it's not the current shell.
# See also:
# - https://stackoverflow.com/questions/16989598
# - https://stackoverflow.com/questions/4023830
# SC2128: Expanding an array without an index only gives the first element.
# shellcheck disable=SC2128
if [ -z "$BASH_VERSINFO" ]
then
    bash_version=$(bash --version | head -n1 | cut -f 4 -d " " | cut -d "-" -f 1  | cut -d "(" -f 1)
else
    # SC2039: In POSIX sh, array references are undefined.
    # shellcheck disable=SC2039
    bash_version="${BASH_VERSINFO[0]}"
fi
# SC2039: In POSIX sh, string indexing is undefined.
# Bash alternate: "${bash_version:0:1}"
# SC2071: < is for string comparisons. Use -lt instead.
bash_version="$(printf '%s' "$bash_version" | cut -c1)"
if [ "$bash_version" -lt 4 ]
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
    echo "   bash --version"
    return 1
fi
unset -v bash_version



quiet_which() {
    command -v "$1" >/dev/null 2>&1
}



# PATH modifiers.
# https://github.com/MikeMcQuaid/dotfiles/blob/master/shrc.sh

add_to_path_start() {
    [ -d "$1" ] || return
    export PATH="$1:$PATH"
}

add_to_path_end() {
    [ -d "$1" ] || return
    export PATH="$PATH:$1"
}



# Check python (any version).
# Consider requiring >= 3 in a future update.
if ! quiet_which python
then
    echo "koopa requires python."
    return 1
fi



# Now that we know Python is installed, we can return the platform string.
KOOPA_PLATFORM="$( python -mplatform )"
export KOOPA_PLATFORM



# Check if this is an interactive shell.
echo "$-" | grep -q "i" && export INTERACTIVE=1



# Load secrets.
# shellcheck source=/dev/null
[ -f "${HOME}/.secrets" ] && . "${HOME}/.secrets"



# Fix systems missing $USER.
[ -z "$USER" ] && USER="$(whoami)" && export USER



# Detect specific instances by the hostname.
case "$(uname -n)" in
                 azlabapp) export AZURE=1;;
       rc.fas.harvard.edu) export HARVARD_ODYSSEY=1;;
    o2.rc.hms.harvard.edu) export HARVARD_O2=1;;
                        *) ;;
esac



# Export local user binaries, if directories exist.
# Bash alternate: [[ ":$PATH:" != *":${dir}:"* ]]
dir="${HOME}/.local/bin"
if [ -d "$dir" ]
then
    case "$PATH" in 
        "$dir") ;;
             *) add_to_path_start "$dir";;
    esac
fi
dir="${HOME}/bin"
if [ -d "$dir" ]
then
    case "$PATH" in 
        "$dir") ;;
             *) add_to_path_start "$dir";;
    esac
fi
unset -v dir



# Export platform-agnostic binaries.
# These essentially are functions that we're exporting to PATH.
add_to_path_start "$KOOPA_BIN_DIR"



# Export additional OS-specific binaries.
if [ ! -z "$MACOS" ]
then
    add_to_path_start "${KOOPA_BIN_DIR}/macos"
fi



# Include Aspera Connect binaries in PATH, if defined.
if [ -z "$ASPERACONNECT_EXE" ]
then
    aspera_exe="${HOME}/.aspera/connect/bin/asperaconnect"
    if [ -f "$aspera_exe" ]
    then
        export ASPERACONNECT_EXE="$aspera_exe"
        unset -v aspera_exe
    else
        ASPERACONNECT_EXE=0
    fi
fi
if [ -f "ASPERACONNECT_EXE" ]
then
    aspera_bin_dir="$( dirname "$ASPERACONNECT_EXE" )"
    export PATH="${aspera_bin_dir}:${PATH}"
    unset -v aspera_bin_dir
fi



# Include bcbio toolkit binaries in PATH, if defined.
# Attempt to locate bcbio installation automatically on supported platforms.
if [ -z "$BCBIO_EXE" ]
then
    if [ ! -z "$HARVARD_O2" ]
    then
        export BCBIO_EXE="/n/app/bcbio/tools/bin/bcbio_nextgen.py"
    elif [ ! -z "$HARVARD_ODYSSEY" ]
    then
        export BCBIO_EXE="/n/regal/hsph_bioinfo/bcbio_nextgen/bin/bcbio_nextgen.py"
    fi
fi
if [ ! -z "$BCBIO_EXE" ]
then
    # Check that path is valid.
    if [ -f "$BCBIO_EXE" ]
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
#
# Conda doesn't currently support ksh.

# Note that it's no longer recommended to export conda in PATH.
# Attempt to locate automatically when not manually defined.
#
# Note that conda will only be activated when a non-base default environment
# is declared.
if [ ! -z "$CONDA_DEFAULT_ENV" ]
then
    # "$shell" variable inherits from koopa call.
    # SC2154: shell is referenced but not assigned.
    # shellcheck disable=SC2154
    if [ "$shell" = "bash" ] || [ "$shell" = "zsh" ]
    then
        if [ -z "$CONDA_EXE" ]
        then
            # Attempt to detect conda path automatically, if not set.
            # Priority:
            # 1. User anaconda3
            # 2. User miniconda3
            # 3. Shared anaconda3
            # 4. Shared miniconda3
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
                # Activate the default environment automatically, if requested.
                # Note that this will get redefined as "base" when conda is
                # activated, so define as an internal variable here.
                conda_env="$CONDA_DEFAULT_ENV"
                conda_bin_dir="$( dirname "$CONDA_EXE" )"
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
    else
        printf "conda is not supported in %s shell." "$shell"
    fi
fi



# Load an SSH key automatically, using SSH_KEY global variable.
# NOTE: SCP will fail unless this is interactive only.
# ssh-agent will prompt for password if there's one set.
# To change SSH key passphrase: ssh-keygen -p
if [ ! -z "$INTERACTIVE" ] && [ ! -z "$LINUX" ]
then
    # If the user hasn't requested a specific SSH key, look for the default.
    if [ -z "$SSH_KEY" ]
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
if [ ! -z "$MACOS" ]
then
    CPUCOUNT="$(sysctl -n hw.ncpu)"
elif [ ! -z "$LINUX" ]
then
    CPUCOUNT="$(getconf _NPROCESSORS_ONLN)"
else
    CPUCOUNT=1
fi
export CPUCOUNT

# Current date (e.g. 2018-01-01).
# Alternatively, can use `%F`.
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
