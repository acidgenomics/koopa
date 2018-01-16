# https://conda.io/miniconda.html

if [[ -d "$HOME/miniconda2" ]]; then
    export CONDA_DIR="$HOME/miniconda2"
elif [[ -d "$HOME/miniconda3" ]]; then
    export CONDA_DIR="$HOME/miniconda3"
fi
