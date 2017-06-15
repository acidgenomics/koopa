# https://conda.io/miniconda.html
if [[ -d "$HOME/miniconda2" ]]; then
    echo "seqcloud only supports miniconda3"
fi
if [[ -d "$HOME/miniconda3" ]]; then
    export CONDA_DIR="$HOME/miniconda3"
    export PATH="$CONDA_DIR/bin:$PATH"
    export LD_RUN_PATH="$CONDA_DIR/lib:$LD_RUN_PATH"
    export PKG_CONFIG_PATH="$CONDA_DIR/lib/pkgconfig:$PKG_CONFIG_PATH"
fi



# [fix]
# Setting LD_LIBRARY_PATH isn't recommended.
# https://conda.io/docs/building/shared-libraries.html#shared-libraries-in-linux-and-os-x
# https://conda.io/docs/building/environment-vars.html
# Setting this fixes some R compilation issues but messes with Orchestra modules.
# Look for another solution. Does LD_RUN_PATH fix the issue?
