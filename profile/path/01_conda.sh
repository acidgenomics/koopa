# https://conda.io/miniconda.html
if [[ -d "$HOME/miniconda2" ]]; then
    echo "seqcloud only supports miniconda3"
fi
if [[ -d "$HOME/miniconda3" ]]; then
    conda_dir="$HOME/miniconda3"
    # export LD_LIBRARY_PATH="$conda_dir/lib:$LD_LIBRARY_PATH"
    export PATH="$conda_dir/bin:$PATH"
    export PKG_CONFIG_PATH="$conda_dir/lib/pkgconfig:$PKG_CONFIG_PATH"
fi
