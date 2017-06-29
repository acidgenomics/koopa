command -v conda >/dev/null 2>&1 || { echo >&2 "conda missing"; exit 1; }

conda config --add channels conda-forge
conda config --add channels defaults
conda config --add channels r
conda config --add channels bioconda
conda update conda
conda update --all
