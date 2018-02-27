command -v conda >/dev/null 2>&1 || { echo >&2 "conda missing"; return 1; }

# https://bioconda.github.io/#set-up-channels
# (conda config --add channels r)
conda config --add channels defaults
conda config --add channels conda-forge
conda config --add channels bioconda

conda update --all --name root --channel defaults
