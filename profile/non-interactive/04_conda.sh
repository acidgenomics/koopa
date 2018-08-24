# Conda

# If unset, attempt to locate the installation automatically
if [[ -z "$CONDA_DIR" ]]; then
    if [[ -d "${HOME}/anaconda3" ]]; then
        # Anaconda
        # https://www.anaconda.com
        export CONDA_DIR="$HOME/anaconda3"
    elif [[ -d "${HOME}/miniconda3" ]]; then
        # Miniconda
        # https://conda.io/miniconda.html
        export CONDA_DIR="${HOME}/miniconda3"
    fi
fi

# Activate
if [[ -d "$CONDA_DIR" ]]; then
    # . "${CONDA_DIR}/etc/profile.d/conda.sh"
    source "${CONDA_DIR}/bin/activate"
fi
