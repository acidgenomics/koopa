# https://conda.io/miniconda.html
if [[ -d "$HOME/miniconda2" ]]; then
    echo "seqcloud only supports miniconda3"
fi
if [[ -d "$HOME/miniconda3" ]]; then
    conda_dir="$HOME/miniconda3"
    export PATH="$conda_dir/bin:$PATH"
    export PKG_CONFIG_PATH="$conda_dir/lib/pkgconfig:$PKG_CONFIG_PATH"
    
    # [fix] Setting LD_LIBRARY_PATH isn't recommended. 
    # https://conda.io/docs/building/shared-libraries.html#shared-libraries-in-linux-and-os-x
    # export LD_LIBRARY_PATH="$conda_dir/lib:$LD_LIBRARY_PATH"
    # If R has problems compiling, look for another solution.
fi
