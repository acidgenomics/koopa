# https://bioconda.github.io/#set-up-channels
command -v conda >/dev/null 2>&1 || { echo >&2 "conda missing"; return 1; }

conda config --add channels defaults
conda config --add channels conda-forge
conda config --add channels bioconda

conda update --channel=defaults conda
conda update --all --name root --channel defaults
