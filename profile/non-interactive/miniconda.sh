# https://conda.io/miniconda.html

if [[ -d "$HOME/miniconda2" ]]; then
    export CONDA_DIR="$HOME/miniconda2"
elif [[ -d "$HOME/miniconda3" ]]; then
    export CONDA_DIR="$HOME/miniconda3"
fi

if [[ -n "$CONDA_DIR" ]]; then
    export CONDA_VERSION=$($CONDA_DIR/bin/conda --version)
    # Ensure load script is sourced for v4.4+
    if echo "$CONDA_VERSION" | grep -q "conda 4.4"; then
        . "$CONDA_DIR/etc/profile.d/conda.sh"
    fi
fi
