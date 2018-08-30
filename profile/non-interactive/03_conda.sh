# Conda
# If unset, attempt to locate the installation automatically.
if [[ -z "$CONDA_DIR" ]]; then
    if [[ -d "${HOME}/anaconda3/bin" ]]; then
        # Anaconda
        # https://www.anaconda.com
        export CONDA_DIR="$HOME/anaconda3/bin"
    elif [[ -d "${HOME}/miniconda3/bin" ]]; then
        # Miniconda
        # https://conda.io/miniconda.html
        export CONDA_DIR="${HOME}/miniconda3/bin"
    fi
fi
# Activate
if [[ -d "$CONDA_DIR" ]]; then
    source "${CONDA_DIR}/activate"
fi
