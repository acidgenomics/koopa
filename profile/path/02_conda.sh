# https://conda.io/miniconda.html
if [[ -d "$HOME/miniconda2" ]]; then
    export PATH="$HOME/miniconda2/bin:$PATH"
    export PKG_CONFIG_PATH=~/miniconda2/lib/pkgconfig:$PKG_CONFIG_PATH
fi
if [[ -d "$HOME/miniconda3" ]]; then
    export PATH="$HOME/miniconda3/bin:$PATH"
    export PKG_CONFIG_PATH=~/miniconda3/lib/pkgconfig:$PKG_CONFIG_PATH
fi
